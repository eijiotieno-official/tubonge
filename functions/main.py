from firebase_admin import initialize_app
import logging

# Initialize Firebase app first
initialize_app()

# Set up logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Import functions at module level but don't execute them
# This allows Firebase Functions to discover and register them
from src.contact.functions.request_registered_contacts_fxn import (
    request_registered_contacts,
)
from src.message.functions.on_message_created_fxn import on_message_created

# Export the functions explicitly
__all__ = ["request_registered_contacts", "on_message_created"]
