from src.core.utils.firebase_collections import FirebaseCollections
from src.message.models.message import Message
import logging
import json

# Set up logger with structured format
_logger = logging.getLogger(__name__)


def create_copy_for_receiver(message: Message):
    """
    Creates a copy of a message for the receiver's chat.
    """
    try:
        _logger.info(
            f"[COPY_RECEIVER] Creating copy for receiver {message.receiver} from sender {message.sender}"
        )

        message_ref = FirebaseCollections.messages(
            user_id=message.receiver, chat_id=message.sender
        ).document(message.id)

        message_data = message.to_map()
        _logger.debug(
            f"[COPY_RECEIVER] Message data: {json.dumps(message_data, default=str)}"
        )

        message_ref.set(message_data)
        _logger.info(
            f"[COPY_RECEIVER] Successfully created copy for message {message.id}"
        )

    except Exception as e:
        _logger.error(
            f"[COPY_RECEIVER] Error creating copy for message {message.id}: {str(e)}",
            exc_info=True,
        )
        raise
