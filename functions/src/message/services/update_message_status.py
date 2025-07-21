from src.core.utils.firebase_collections import FirebaseCollections
from src.message.models.message import Message, MessageStatus
import logging
import json

# Set up the logger with structured format
_logger = logging.getLogger(__name__)


def update_message_status(
    message: Message,
    new_status: MessageStatus,
) -> Message | None:
    """
    Updates the status of a message in Firestore.
    """
    try:
        _logger.info(
            f"[UPDATE_STATUS] Updating message {message.id} status from '{message.status}' to '{new_status}'"
        )

        # Create a copy of the message with the updated status
        updated_message = message.copy_with(status=new_status)
        _logger.debug(f"[UPDATE_STATUS] Updated message: {updated_message}")

        # Get a reference to the Firestore document
        message_ref = FirebaseCollections.messages(
            user_id=message.sender, chat_id=message.receiver
        ).document(message.id)

        # Convert the updated message object to a dictionary
        message_data = updated_message.to_map()
        _logger.debug(
            f"[UPDATE_STATUS] Firestore update data: {json.dumps(message_data, default=str)}"
        )

        # Update Firestore with the new data
        message_ref.update(message_data)
        _logger.info(
            f"[UPDATE_STATUS] Successfully updated message {message.id} status to '{new_status}'"
        )

        return updated_message

    except Exception as e:
        _logger.error(
            f"[UPDATE_STATUS] Error updating message {message.id} status: {str(e)}",
            exc_info=True,
        )
        return None
