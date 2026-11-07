from sqlalchemy import Column, Integer, String, Text, Boolean, TIMESTAMP, ForeignKey, ARRAY, Date, Float
from sqlalchemy.orm import relationship
from .database import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)

    # Profile Info
    bio = Column(Text, nullable=True)
    gender = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    location = Column(String, nullable=True)
    phone_number = Column(String, nullable=True)
    profile_picture_url = Column(String, nullable=True)

    # Preferences
    favorite_times_to_play = Column(ARRAY(String), nullable=True)
    preferred_sports_partner = Column(String, nullable=True)
    notifications_enabled = Column(Boolean, default=True)

    # Sports Info
    skill_level = Column(String, nullable=True)
    sports = Column(ARRAY(String), nullable=True)

    # Timestamps
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)

    # Relationships
    games_created = relationship("Game", back_populates="creator")
    participations = relationship("Participant", back_populates="user")


class Game(Base):
    __tablename__ = "games"

    id = Column(Integer, primary_key=True, index=True)
    creator_id = Column(Integer, ForeignKey("users.id"))
    sport = Column(String, nullable=False)
    location = Column(Text)
    notes = Column(Text)
    date = Column(TIMESTAMP)
    needed_players = Column(Integer)
    skill_level = Column(String)
    gender_preference = Column(String)
    is_public = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)

    creator = relationship("User", back_populates="games_created")
    participants = relationship("Participant", back_populates="game")
    messages = relationship("Message", back_populates="game")


class Participant(Base):
    __tablename__ = "participants"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    game_id = Column(Integer, ForeignKey("games.id"))
    joined_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)

    user = relationship("User", back_populates="participations")
    game = relationship("Game", back_populates="participants")


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    sender_id = Column(Integer, ForeignKey("users.id"))
    recipient_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    game_id = Column(Integer, ForeignKey("games.id"), nullable=True)
    content = Column(String, index=True)
    timestamp = Column(TIMESTAMP, default=datetime.utcnow)
    read = Column(Boolean, default=False)

    sender = relationship("User", foreign_keys=[sender_id])
    recipient = relationship("User", foreign_keys=[recipient_id])
    game = relationship("Game", back_populates="messages")


class JoinRequest(Base):
    __tablename__ = "join_requests"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    game_id = Column(Integer, ForeignKey("games.id"))
    status = Column(String, default="pending")
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)

    user = relationship("User", backref="join_requests")
    game = relationship("Game", backref="join_requests")


class Rating(Base):
    __tablename__ = "ratings"

    id = Column(Integer, primary_key=True, index=True)
    rater_id = Column(Integer, ForeignKey("users.id"))
    rated_id = Column(Integer, ForeignKey("users.id"))
    rating = Column(Float)
    feedback = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP, default=datetime.utcnow)
