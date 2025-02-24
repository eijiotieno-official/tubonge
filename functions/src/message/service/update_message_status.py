from functions.src.core.util.firebase_collections import *
from src.message.model.base.message import *
from src.message.model.enum.message_status import *
import logging

# Set up the logger
_logger = logging.getLogger()


def update_message_status(
    message: Message,
    new_status: MessageStatus,
) -> Message | None:
    try:
        # Log the incoming message details
        _logger.info(
            f"Attempting to update message status for Message ID: {message.id} with new status: {new_status}"
        )

        # Create a copy of the message with the updated status
        updated_message = message.copy_with(status=new_status)

        # Log the updated message
        _logger.debug(f"Updated Message: {updated_message}")

        # Get a reference to the Firestore document
        message_ref = FirebaseCollections.messages(
            user_id=message.sender, chat_id=message.receiver
        ).document(message.id)

        # Convert the updated message object to a dictionary
        message_data = updated_message.to_map()

        # Log the data that will be updated in Firestore
        _logger.debug(
            f"Data to be updated in Firestore for Message ID {message.id}: {message_data}"
        )

        # Update Firestore with the new data
        _logger.info(f"Updating Firestore document for Message ID: {message.id}")
        message_ref.update(message_data)

        # Log successful update
        _logger.info(
            f"Message status updated successfully for Message ID: {message.id} to status: {new_status}"
        )

        return updated_message

    except Exception as e:
        # Log the error with message details
        _logger.error(
            f"Error updating message status for Message ID: {message.id} - Error: {e}",
            exc_info=True,  # This will include the full stack trace for debugging
        )
        return None
