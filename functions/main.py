from firebase_admin import initialize_app
import logging


logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

initialize_app()

from src.contact.functions.request_registered_contacts_fxn import *
