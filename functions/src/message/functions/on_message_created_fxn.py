from firebase_functions.firestore_fn import (
    on_document_created,
    Event,
    DocumentSnapshot,
)
from src.message.models.message import Message, TextMessage, MessageStatus
from src.message.services.get_tokens import get_tokens
from src.message.services.update_message_status import update_message_status
from src.message.services.send_notification import send_notifications
from src.message.services.create_copy_for_receiver import create_copy_for_receiver
import json


@on_document_created(document="users/{user_id}/chats/{chat_id}/messages/{message_id}")
def on_message_created(event: Event[DocumentSnapshot]) -> None:
    """
    Handles message creation events. Only processes original messages, not copies.
    """
    try:
        # Extract path parameters
        user_id = event.params.get("user_id")
        chat_id = event.params.get("chat_id")
        message_id = event.params.get("message_id")

        print(
            f"[MESSAGE_CREATED] Function triggered for message {message_id} in chat {chat_id} by user {user_id}"
        )

        # Retrieve document data
        doc_data = event.data.to_dict()
        if not doc_data:
            print(f"[MESSAGE_CREATED] No document data found for message {message_id}")
            return

        print(f"[MESSAGE_CREATED] Document data: {json.dumps(doc_data, default=str)}")

        # Check if this is an original message (sender's copy) or a receiver's copy
        # Original messages have status 'none', copies have status 'sent'
        message_status = doc_data.get("status", "none")

        if message_status != "none":
            print(
                f"[MESSAGE_CREATED] Skipping message {message_id} - status is '{message_status}' (likely a copy)"
            )
            return

        # Step 1: Create message object from document data
        message = Message.from_map(doc_data)
        print(
            f"[MESSAGE_CREATED] Processing {message.type} message from {message.sender} to {message.receiver}"
        )

        # Step 2: Handle TextMessage
        if isinstance(message, TextMessage):
            print(
                f"[MESSAGE_CREATED] Processing TextMessage: '{message.text[:50]}{'...' if len(message.text) > 50 else ''}'"
            )

            # Create copy for receiver first
            print(f"[MESSAGE_CREATED] Creating copy for receiver {message.receiver}")
            create_copy_for_receiver(
                message=message.copy_with(status=MessageStatus.sent)
            )

            # Update original message status
            print(f"[MESSAGE_CREATED] Updating original message status to 'sent'")
            update_message_status(message=message, new_status=MessageStatus.sent)

            # Get receiver tokens and send notifications
            print(f"[MESSAGE_CREATED] Fetching tokens for receiver {message.receiver}")
            tokens, phoneNumber, photo = get_tokens(user_id=message.receiver)

            if tokens:
                # Prepare payload for notifications
                payload = {
                    "data": {
                        "sender_id": message.sender,
                        "receiver_id": message.receiver,
                        "sender_phoneNumber": phoneNumber or "",
                        "sender_photo": photo or "",
                        "message_id": message.id,
                        "message_text": message.text,
                        "type": "text",
                    },
                }
                print(f"[MESSAGE_CREATED] Sending notification to {len(tokens)} tokens")
                print(
                    f"[MESSAGE_CREATED] Notification payload: {json.dumps(payload, default=str)}"
                )

                send_notifications(tokens=tokens, payload=payload)
            else:
                print(
                    f"[MESSAGE_CREATED] No tokens found for receiver {message.receiver}"
                )

            print(f"[MESSAGE_CREATED] Successfully processed message {message_id}")
        else:
            print(f"[MESSAGE_CREATED] Unsupported message type: {message.type}")

    except Exception as e:
        print(
            f"[MESSAGE_CREATED] Error processing message {event.params.get('message_id', 'unknown')}: {str(e)}"
        )
        import traceback

        print(f"[MESSAGE_CREATED] Traceback: {traceback.format_exc()}")
        return
