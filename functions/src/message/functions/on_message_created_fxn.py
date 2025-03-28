from firebase_functions.firestore_fn import (
    on_document_created,
    Event,
    DocumentSnapshot,
)
from src.message.models.message import *
from src.message.services.get_tokens import *
from src.message.services.update_message_status import *
from src.message.services.send_notification import *
from src.message.services.create_copy_for_receiver import *
import logging

# Set up logger
_logger = logging.getLogger()


@on_document_created(document="users/{user_id}/chats/{chat_id}/messages/{message_id}")
def on_message_created(event: Event[DocumentSnapshot]) -> None:

    try:
        _logger.info("Function on_message_created triggered.")

        # Retrieve document data
        doc_data = event.data.to_dict()
        _logger.info(f"Document data received: {doc_data}")

        # Step 1: Create message object from document data
        message = Message.from_map(doc_data)

        # Step 2: Handle TextMessage
        if isinstance(message, TextMessage):
            _logger.info("Message is a TextMessage.")

            # Create Firestore document
            create_copy_for_receiver(
                message=message.copy_with(status=MessageStatus.sent)
            )

            # Update message status
            update_message_status(message=message, new_status=MessageStatus.sent)

            # Get receiver tokens and send notifications
            tokens, phoneNumber, photo = get_tokens(user_id=message.receiver)

            # Prepare payload for notifications
            payload = {
                "data": {
                    "sender_id": message.sender,
                    "receiver_id": message.receiver,
                    "sender_phoneNumber": phoneNumber,
                    "sender_photo": photo,
                    "message_id": message.id,
                    "message_text": message.text,
                    "type": "text",
                },
            }
            _logger.info(f"Notification payload: {payload}")

            if tokens:
                send_notifications(tokens=tokens, payload=payload)

    except Exception as e:
        _logger.error(f"Error: {e}")
        return
