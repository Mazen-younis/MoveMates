from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from movemates_backend.routes import games, participants, users, private_messages
from movemates_backend.database import Base, engine
from movemates_backend import models

app = FastAPI()

# Allow frontend/mobile apps to access this backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve static files (like profile pictures)
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def root():
    return {"message": "MoveMates backend is running"}

# Include API routes
app.include_router(users.router)
app.include_router(games.router)
app.include_router(participants.router)
app.include_router(private_messages.router)

# Create DB tables (including JoinRequest)
Base.metadata.create_all(bind=engine)
