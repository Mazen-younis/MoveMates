from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime,date
from pydantic import BaseModel

# User Schemas
class UserCreate(BaseModel):
    name: str
    username: str
    email: EmailStr
    password: str
    skill_level: Optional[str]
    sports: Optional[List[str]]
    date_of_birth: Optional[date] = None
    location: Optional[str] = None

class UserOut(BaseModel):
    id: int
    name: str
    username: str
    email: EmailStr
    skill_level: Optional[str]
    bio: Optional[str] = None
    gender: Optional[str] = None
    sports: Optional[List[str]] = None
    date_of_birth: Optional[date]
    location: Optional[str]
    created_at: datetime

    class Config:
        orm_mode = True

class ProfileUpdate(BaseModel):
    bio: Optional[str] = None
    gender: Optional[str] = None
    preferred_sports_partner: Optional[str] = None
    favorite_times_to_play: Optional[List[str]] = None
    phone_number: Optional[str] = None
    notifications_enabled: Optional[bool] = True
    profile_picture_url: Optional[str] = None
    date_of_birth: Optional[date] = None
    sports: Optional[List[str]] = None
    location: Optional[str] = None
    skill_level: Optional[str] = None

class UserResponse(BaseModel):
    id: int
    name: str
    username: str
    email: EmailStr
    skill_level: Optional[str]
    sports: Optional[List[str]]

    # Profile fields
    preferred_sports_partner: Optional[str]
    favorite_times_to_play: Optional[List[str]]
    phone_number: Optional[str]
    notifications_enabled: Optional[bool]
    profile_picture_url: Optional[str]
    date_of_birth: Optional[date]
    location: Optional[str]
    created_at: datetime
    bio: Optional[str] = None
    gender: Optional[str] = None
    sports: Optional[List[str]] = None


    class Config:
        from_attributes = True


# Game Schemas
class GameBase(BaseModel):
    sport: str
    location: str
    date: datetime
    needed_players: int
    skill_level: Optional[str]
    gender_preference: Optional[str]
    is_public: bool

class GameCreate(GameBase):
    creator_id: int

class GameOut(GameBase):
    id: int
    creator_id: int
    created_at: datetime

    class Config:
        orm_mode = True


# Participant Schemas
class ParticipantCreate(BaseModel):
    user_id: int
    game_id: int

class ParticipantOut(BaseModel):
    id: int
    user_id: int
    game_id: int

    class Config:
        orm_mode = True




# Message Schemas
class MessageBase(BaseModel):
    content: str
    game_id: Optional[int] = None
    recipient_id: Optional[int] = None

class MessageCreate(BaseModel):
    content: str
    game_id: Optional[int] = None
    recipient_id: Optional[int] = None
    sender_id: int

class MessageOut(BaseModel):
    id: int
    content: str
    game_id: Optional[int] = None
    recipient_id: Optional[int] = None
    sender_id: int
    timestamp: datetime
    read: bool

    class Config:
        orm_mode = True


class PrivateChatSummary(BaseModel):
    id: int
    name: str
    lastMessage: str
    timestamp: str

    class Config:
        orm_mode = True
        


class MessageReadUpdate(BaseModel):
    message_id: int



class LoginRequest(BaseModel):
    username_or_email: str
    password: str



# JoinRequest Schemas
class JoinRequestCreate(BaseModel):
    user_id: int
    game_id: int

class JoinRequestOut(BaseModel):
    id: int
    user_id: int
    username: str
    game_id: int
    game_sport: Optional[str] = None
    game_location: Optional[str] = None
    status: str
    created_at: datetime

    class Config:
        orm_mode = True

class UserRating(BaseModel):
    average: float
    count: int

class UserUpdate(BaseModel):
    name: Optional[str] = None
    username: Optional[str] = None
    email: Optional[str] = None
    skill_level: Optional[str] = None
    sports: Optional[List[str]] = None
    bio: Optional[str] = None
    gender: Optional[str] = None
    preferred_sports_partner: Optional[str] = None
    favorite_times_to_play: Optional[List[str]] = None
    phone_number: Optional[str] = None
    notifications_enabled: Optional[bool] = None
    profile_picture_url: Optional[str] = None
    date_of_birth: Optional[date] = None
    location: Optional[str] = None


class RatingCreate(BaseModel):
    rater_id: int
    rated_id: int
    rating: float
    feedback: Optional[str] = None
