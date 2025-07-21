from firebase_admin import initialize_app
import logging
import sys

# Initialize Firebase app first
initialize_app()

# Set up structured logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)

# Set specific log levels for different modules
logging.getLogger("firebase_functions").setLevel(logging.WARNING)
logging.getLogger("firebase_admin").setLevel(logging.WARNING)
logging.getLogger("google.cloud").setLevel(logging.WARNING)

logger = logging.getLogger(__name__)
logger.info("Firebase Functions initialized with structured logging")

# Import functions at module level but don't execute them
# This allows Firebase Functions to discover and register them
from src.contact.functions.request_registered_contacts_fxn import (
    request_registered_contacts,
)
from src.message.functions.on_message_created_fxn import on_message_created

# Export the functions explicitly
__all__ = ["request_registered_contacts", "on_message_created"]
