from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_, desc
from movemates_backend import models, schemas, database
from typing import List
from pydantic import BaseModel

router = APIRouter(prefix="/private_messages", tags=["Private Messages"])


def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Model for mark_read request body
class MessageReadUpdate(BaseModel):
    message_id: int


@router.post("/send", response_model=schemas.MessageOut)
def send_private_message(message: schemas.MessageCreate, db: Session = Depends(get_db)):
    if not message.recipient_id:
        raise HTTPException(status_code=400, detail="Recipient ID is required for private messages")

    new_message = models.Message(
        sender_id=message.sender_id,
        recipient_id=message.recipient_id,
        content=message.content,
        game_id=message.game_id
    )

    db.add(new_message)
    db.commit()
    db.refresh(new_message)

    return new_message


@router.get("/user/{user_id}", response_model=List[schemas.PrivateChatSummary])
def get_private_chat_summaries(user_id: int, db: Session = Depends(get_db)):
    messages = db.query(models.Message).filter(
        or_(
            models.Message.sender_id == user_id,
            models.Message.recipient_id == user_id
        )
    ).order_by(desc(models.Message.timestamp)).all()

    seen = set()
    summaries = []

    for msg in messages:
        other_id = msg.recipient_id if msg.sender_id == user_id else msg.sender_id
        if other_id in seen:
            continue
        seen.add(other_id)

        other_user = db.query(models.User).filter(models.User.id == other_id).first()
        if not other_user:
            continue

        summaries.append({
            "id": other_user.id,
            "name": other_user.username,
            "lastMessage": msg.content,
            "timestamp": msg.timestamp.strftime("%d.%m.%Y, %H:%M")
        })

    return summaries


@router.get("/{user_id_1}/{user_id_2}", response_model=List[schemas.MessageOut])
def get_conversation(user_id_1: int, user_id_2: int, db: Session = Depends(get_db)):
    messages = db.query(models.Message).filter(
        ((models.Message.sender_id == user_id_1) & (models.Message.recipient_id == user_id_2)) |
        ((models.Message.sender_id == user_id_2) & (models.Message.recipient_id == user_id_1))
    ).order_by(models.Message.timestamp.asc()).all()

    return [
        {
            "id": msg.id,
            "content": msg.content,
            "game_id": msg.game_id,
            "recipient_id": msg.recipient_id,
            "sender_id": msg.sender_id,
            "timestamp": msg.timestamp.isoformat() + "Z",  # <- always ISO8601!
            "read": msg.read
        }
        for msg in messages
    ]


@router.post("/start_chat/")
def start_private_chat(user_id: int, game_id: int, db: Session = Depends(get_db)):
    game = db.query(models.Game).filter(models.Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail="Game not found")

    creator_id = game.creator_id

    if user_id == creator_id:
        raise HTTPException(status_code=400, detail="You cannot start a chat with yourself")

    existing_message = db.query(models.Message).filter(
        ((models.Message.sender_id == user_id) & (models.Message.recipient_id == creator_id)) |
        ((models.Message.sender_id == creator_id) & (models.Message.recipient_id == user_id))
    ).first()

    if existing_message:
        return {"message": "Chat already exists", "existing": True}

    intro_message = models.Message(
        sender_id=user_id,
        recipient_id=creator_id,
        content="Hey! I just requested to join your event",
        game_id=game_id
    )

    db.add(intro_message)
    db.commit()

    return {"message": "Chat started", "existing": False}


@router.post("/mark_read/")
def mark_private_message_as_read(update: MessageReadUpdate, db: Session = Depends(get_db)):
    message_id = update.message_id
    message = db.query(models.Message).filter(models.Message.id == message_id).first()
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")
    message.read = True
    db.commit()
    return {"status": "success"}


@router.delete("/chat/{user1_id}/{user2_id}")
def delete_private_chat(user1_id: int, user2_id: int, db: Session = Depends(get_db)):
    """
    Deletes all messages in the private chat between user1 and user2.
    """
    messages = db.query(models.Message).filter(
        ((models.Message.sender_id == user1_id) & (models.Message.recipient_id == user2_id)) |
        ((models.Message.sender_id == user2_id) & (models.Message.recipient_id == user1_id))
    ).all()

    if not messages:
        raise HTTPException(status_code=404, detail="No chat found")

    for msg in messages:
        db.delete(msg)

    db.commit()
    return {"detail": "Chat deleted successfully"}
