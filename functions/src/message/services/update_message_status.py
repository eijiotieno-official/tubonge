from firebase_admin import firestore
from src.message.models.message import Message, MessageStatus


def update_message_status(message: Message, new_status: MessageStatus) -> None:
    """
    Updates the status of a message in Firestore.
    """
    try:
        print(
            f"[UPDATE_STATUS] Updating message {message.id} status to {new_status.value}"
        )

        db = firestore.client()

        # Update the message status in sender's chat
        message_ref = (
            db.collection("users")
            .document(message.sender)
            .collection("chats")
            .document(message.receiver)
            .collection("messages")
            .document(message.id)
        )

        message_ref.update({"status": new_status.value})

        print(
            f"[UPDATE_STATUS] Successfully updated message {message.id} status to {new_status.value}"
        )

    except Exception as e:
        print(f"[UPDATE_STATUS] Error updating message {message.id} status: {str(e)}")
        import traceback

        print(f"[UPDATE_STATUS] Traceback: {traceback.format_exc()}")
