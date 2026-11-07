from movemates_backend.database import engine
from movemates_backend.models import Base


print("Creating tables...")
Base.metadata.create_all(bind=engine)
print("Done.")

