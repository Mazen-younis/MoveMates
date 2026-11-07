import pytz

from dateutil import parser
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from movemates_backend import models, database
from movemates_backend import schemas

router = APIRouter(prefix="/games", tags=["Games"])

# DB dependency
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/")
def get_all_games(db: Session = Depends(get_db)):
    return db.query(models.Game).all()


@router.post("/", response_model=schemas.GameOut)
def create_game(game: schemas.GameCreate, db: Session = Depends(get_db)):
    new_game = models.Game(**game.dict())
    db.add(new_game)
    db.commit()
    db.refresh(new_game)
    return new_game


@router.get("/search/", response_model=list[schemas.GameOut])
def search_games(
    city: str | None = None,
    skill_level: str | None = None,
    sport: str | None = None,
    db: Session = Depends(get_db)
):
    query = db.query(models.Game)

    if city:
        query = query.filter(models.Game.city.ilike(f"%{city}%"))
    if skill_level:
        query = query.filter(models.Game.skill_level == skill_level)
    if sport:
        query = query.filter(models.Game.sport.ilike(f"%{sport}%"))

    return query.all()

@router.put("/{game_id}", response_model=schemas.GameOut)
def update_game(game_id: int, game: schemas.GameCreate, db: Session = Depends(get_db)):
    db_game = db.query(models.Game).filter(models.Game.id == game_id).first()
    
    if not db_game:
        raise HTTPException(status_code=404, detail="Game not found")
    
    # Update the game fields
    db_game.sport = game.sport
    db_game.location = game.location
    db_game.date = game.date
    db_game.needed_players = game.needed_players
    db_game.skill_level = game.skill_level
    db_game.gender_preference = game.gender_preference
    db_game.is_public = game.is_public
    
    db.commit()
    db.refresh(db_game)
    
    return db_game

@router.get("/created_by/{user_id}", response_model=list[schemas.GameOut])
def get_games_created_by_user(user_id: int, db: Session = Depends(get_db)):
    games = db.query(models.Game).filter(models.Game.creator_id == user_id).all()
    return games


@router.delete("/delete/{game_id}")
def delete_game(game_id: int, db: Session = Depends(get_db)):
    game = db.query(models.Game).filter(models.Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail="Game not found")
    
    db.delete(game)
    db.commit()
    return {"message": "Game deleted successfully"}
