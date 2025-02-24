from functions.src.core.util.firebase_collections import FirebaseCollections
from src.message.model.base.message import Message
import logging


_logger = logging.getLogger()


def create_copy_for_receiver(message: Message):
    try:
        message_ref = FirebaseCollections.messages(
            user_id=message.receiver, chat_id=message.sender
        ).document(message.id)

        message_data = message.to_map()

        message_ref.set(message_data)

        _logger.info("Message data updated in Firestore.")

    except Exception as e:

        _logger.error(f"Error updating Firestore with message data: {e}")
