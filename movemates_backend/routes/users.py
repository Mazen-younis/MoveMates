from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from movemates_backend import models, schemas, database
import os

router = APIRouter(prefix="/users", tags=["Users"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Create a new user
@router.post("/", response_model=schemas.UserOut)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    existing_email = db.query(models.User).filter(models.User.email == user.email).first()
    existing_username = db.query(models.User).filter(models.User.username == user.username).first()

    if existing_email or existing_username:
        raise HTTPException(status_code=400, detail="Email or username already registered")

    hashed_pw = pwd_context.hash(user.password)
    new_user = models.User(
        name=user.name,
        username=user.username,
        email=user.email,
        password_hash=hashed_pw,
        date_of_birth=user.date_of_birth,
        location=user.location,
        skill_level=user.skill_level,
        sports=user.sports
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

# Login endpoint
@router.post("/login", response_model=schemas.UserResponse)
def login_user(login_data: schemas.LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(
        (models.User.email == login_data.username_or_email) |
        (models.User.username == login_data.username_or_email)
    ).first()

    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    if not pwd_context.verify(login_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return user

# Get all users
@router.get("/", response_model=list[schemas.UserOut])
def get_all_users(db: Session = Depends(get_db)):
    return db.query(models.User).all()

# Get a single user by ID
@router.get("/{user_id}", response_model=schemas.UserOut)
def get_user_by_id(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# Update full user profile (for editing all profile data from frontend)
@router.put("/{user_id}", response_model=schemas.UserResponse)
def update_user(user_id: int, user_update: schemas.UserUpdate, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = user_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(user, key, value)

    db.commit()
    db.refresh(user)
    return user

# Update partial profile fields (like preferences)
@router.put("/{user_id}/profile", response_model=schemas.UserResponse)
def update_user_profile(user_id: int, profile_data: schemas.ProfileUpdate, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = profile_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(user, key, value)

    db.commit()
    db.refresh(user)
    return user

# Get user rating
@router.get("/rating/{user_id}", response_model=schemas.UserRating)
def get_user_rating(user_id: int, db: Session = Depends(get_db)):
    ratings = db.query(models.Rating).filter(models.Rating.rated_id == user_id).all()
    if not ratings:
        return {"average": 0.0, "count": 0}
    avg = sum(r.rating for r in ratings) / len(ratings)
    return {"average": round(avg, 1), "count": len(ratings)}


@router.post("/rating/")
def rate_user(rating_data: schemas.RatingCreate, db: Session = Depends(get_db)):
    new_rating = models.Rating(
        rater_id=rating_data.rater_id,
        rated_id=rating_data.rated_id,
        rating=rating_data.rating,
        feedback=rating_data.feedback
    )
    db.add(new_rating)
    db.commit()
    db.refresh(new_rating)
    return {"message": "Rating submitted successfully!"}


# Fetch ratings for a user (received and given)
@router.get("/ratings/{user_id}")
def get_user_ratings(user_id: int, db: Session = Depends(get_db)):
    # Ratings received by this user
    received_ratings = (
        db.query(models.Rating, models.User.name.label("fromName"))
        .join(models.User, models.Rating.rater_id == models.User.id)
        .filter(models.Rating.rated_id == user_id)
        .all()
    )

    # Ratings given by this user
    given_ratings = (
        db.query(models.Rating, models.User.name.label("toName"))
        .join(models.User, models.Rating.rated_id == models.User.id)
        .filter(models.Rating.rater_id == user_id)
        .all()
    )

    # Serialize results
    def serialize_ratings(data, given=False):
        return [
            {
                "id": r.Rating.id,
                "fromId": r.Rating.rater_id,
                "fromName": r.fromName if not given else "You",
                "toId": r.Rating.rated_id,
                "toName": r.toName if given else "You",
                "rating": r.Rating.rating,
                "feedback": r.Rating.feedback or "",
                "date": r.Rating.created_at.isoformat() if r.Rating.created_at else None
            }
            for r in data
        ]

    return {
        "received": serialize_ratings(received_ratings, given=False),
        "given": serialize_ratings(given_ratings, given=True)
    }


# Upload profile picture endpoint
@router.post("/upload_profile_picture")
async def upload_profile_picture(file: UploadFile = File(...)):
    # 1. Save file to static folder
    file_location = f"static/profile_pics/{file.filename}"
    os.makedirs(os.path.dirname(file_location), exist_ok=True)
    with open(file_location, "wb") as f:
        f.write(await file.read())

    # 2. Use the configured API address when returning the image URL.
    # For physical devices, set BACKEND_PUBLIC_URL to the backend's reachable address.
    base_url = os.getenv("BACKEND_PUBLIC_URL", "http://127.0.0.1:8000").rstrip("/")
    public_url = f"{base_url}/{file_location}"

    return {"url": public_url}
