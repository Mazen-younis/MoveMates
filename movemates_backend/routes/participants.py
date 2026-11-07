from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from movemates_backend import models, schemas, database

router = APIRouter(prefix="/participants", tags=["Participants"])

# DB dependency
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/", response_model=schemas.ParticipantOut)
def join_game(participant: schemas.ParticipantCreate, db: Session = Depends(get_db)):
    db_game = db.query(models.Game).filter(models.Game.id == participant.game_id).first()
    if not db_game:
        raise HTTPException(status_code=404, detail="Game not found")

    existing_participant = db.query(models.Participant).filter(
        models.Participant.user_id == participant.user_id,
        models.Participant.game_id == participant.game_id
    ).first()
    if existing_participant:
        raise HTTPException(status_code=400, detail="User already joined this game")

    new_participant = models.Participant(
        user_id=participant.user_id,
        game_id=participant.game_id
    )
    db.add(new_participant)
    db.commit()
    db.refresh(new_participant)

    # Ensure group chat exists for this game
    if not db_game.group_chat:
        group_chat = models.GroupChat(game_id=participant.game_id)
        db.add(group_chat)
        db.commit()
        db.refresh(group_chat)
    else:
        group_chat = db_game.group_chat

    # Connect this participant to the group chat
    pgc_entry = models.ParticipantGroupChat(
        participant_id=new_participant.id,
        group_chat_id=group_chat.id
    )
    db.add(pgc_entry)
    db.commit()

    return new_participant


@router.get("/", response_model=list[schemas.ParticipantOut])
def get_all_participants(game_id: int, db: Session = Depends(get_db)):
    participants = db.query(models.Participant).filter(models.Participant.game_id == game_id).all()
    return participants


@router.post("/send_message/", response_model=schemas.MessageOut)
def send_message(message: schemas.MessageCreate, db: Session = Depends(get_db)):
    sender = db.query(models.User).filter(models.User.id == message.sender_id).first()
    recipient = db.query(models.User).filter(models.User.id == message.recipient_id).first()

    if not sender or not recipient:
        raise HTTPException(status_code=404, detail="Sender or recipient not found")

    game = db.query(models.Game).filter(models.Game.id == message.game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail="Game not found")

    new_message = models.Message(**message.dict())
    db.add(new_message)
    db.commit()
    db.refresh(new_message)

    return new_message


@router.get("/messages/{user_id}", response_model=list[schemas.MessageOut])
def get_user_messages(user_id: int, db: Session = Depends(get_db)):
    messages = db.query(models.Message).filter(
        (models.Message.sender_id == user_id) | (models.Message.recipient_id == user_id)
    ).all()
    return messages


@router.post("/request_join/", response_model=schemas.JoinRequestOut)
def request_to_join(join_request: schemas.JoinRequestCreate, db: Session = Depends(get_db)):
    db_game = db.query(models.Game).filter(models.Game.id == join_request.game_id).first()
    if not db_game:
        raise HTTPException(status_code=404, detail="Game not found")

    existing_request = db.query(models.JoinRequest).filter(
        models.JoinRequest.user_id == join_request.user_id,
        models.JoinRequest.game_id == join_request.game_id
    ).first()
    if existing_request:
        raise HTTPException(status_code=400, detail="Request already submitted")

    new_request = models.JoinRequest(
        user_id=join_request.user_id,
        game_id=join_request.game_id
    )

    db.add(new_request)
    db.commit()
    db.refresh(new_request)

    # Fetch the user to get the username
    user = db.query(models.User).filter(models.User.id == join_request.user_id).first()

    # Build and return the detailed response
    return schemas.JoinRequestOut(
        id=new_request.id,
        user_id=new_request.user_id,
        username=user.username if user else "Unknown",
        game_id=new_request.game_id,
        game_sport=db_game.sport if db_game else "Unknown",
        game_location=db_game.location if db_game else "Unknown",
        status=new_request.status,
        created_at=new_request.created_at
    )


@router.post("/approve_request/{request_id}", response_model=schemas.JoinRequestOut)
def approve_join_request(request_id: int, db: Session = Depends(get_db)):
    join_request = db.query(models.JoinRequest).filter(models.JoinRequest.id == request_id).first()
    if not join_request:
        raise HTTPException(status_code=404, detail="Join request not found")

    if join_request.game_id is None:
        raise HTTPException(status_code=400, detail="Join request has no game_id")

    if join_request.status != "pending":
        raise HTTPException(status_code=400, detail="Request already processed")

    join_request.status = "approved"
    db.commit()

    participant = models.Participant(user_id=join_request.user_id, game_id=join_request.game_id)
    db.add(participant)
    db.commit()
    db.refresh(participant)

    game = db.query(models.Game).filter(models.Game.id == join_request.game_id).first()
    if game:
        game.needed_players -= 1
        if game.needed_players <= 0:
            db.delete(game)
        db.commit()

    user = db.query(models.User).filter(models.User.id == join_request.user_id).first()

    return schemas.JoinRequestOut(
        id=join_request.id,
        user_id=join_request.user_id,
        username=user.username if user else "Unknown",
        game_id=join_request.game_id,
        game_sport=game.sport if game else "Unknown",
        game_location=game.location if game else "Unknown",
        status=join_request.status,
        created_at=join_request.created_at
    )


@router.get("/game/{game_id}", response_model=list[schemas.UserOut])
def get_participants_for_game(game_id: int, db: Session = Depends(get_db)):
    game = db.query(models.Game).filter(models.Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail="Game not found")

    participants = (
        db.query(models.User)
        .join(models.Participant, models.User.id == models.Participant.user_id)
        .filter(models.Participant.game_id == game_id)
        .all()
    )
    return participants


@router.get("/creator_join_requests/{creator_id}", response_model=list[schemas.JoinRequestOut])
def get_join_requests_for_creator(creator_id: int, db: Session = Depends(get_db)):
    games = db.query(models.Game).filter(models.Game.creator_id == creator_id).all()
    game_ids = [game.id for game in games]

    join_requests = db.query(models.JoinRequest).filter(models.JoinRequest.game_id.in_(game_ids)).all()

    result = []
    for req in join_requests:
        user = db.query(models.User).filter(models.User.id == req.user_id).first()
        game = db.query(models.Game).filter(models.Game.id == req.game_id).first()

        detailed_req = schemas.JoinRequestOut(
            id=req.id,
            user_id=req.user_id,
            username=user.username if user else "Unknown",
            game_id=req.game_id,
            game_sport=game.sport if game else "Unknown",
            game_location=game.location if game else "Unknown",
            status=req.status,
            created_at=req.created_at
        )
        result.append(detailed_req)

    return result


@router.get("/user/{user_id}/join_requests", response_model=list[schemas.JoinRequestOut])
def get_join_requests_sent_by_user(user_id: int, db: Session = Depends(get_db)):
    join_requests = db.query(models.JoinRequest).filter(models.JoinRequest.user_id == user_id).all()
    
    result = []
    for req in join_requests:
        game = db.query(models.Game).filter(models.Game.id == req.game_id).first()
        detailed_req = schemas.JoinRequestOut(
            id=req.id,
            user_id=req.user_id,
            username=db.query(models.User).filter(models.User.id == req.user_id).first().username,
            game_id=req.game_id,
            game_sport=game.sport if game else "Unknown",
            game_location=game.location if game else "Unknown",
            status=req.status,
            created_at=req.created_at
        )
        result.append(detailed_req)
    
    return result
