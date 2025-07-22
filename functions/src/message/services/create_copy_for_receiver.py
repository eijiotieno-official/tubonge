from firebase_admin import firestore
from src.message.models.message import Message


def create_copy_for_receiver(message: Message) -> None:
    """
    Creates a copy of a message for the receiver in their chat collection.
    """
    try:
        print(f"[CREATE_COPY] Creating copy for receiver {message.receiver}")

        db = firestore.client()

        # Create the copy in receiver's chat
        receiver_chat_ref = (
            db.collection("users")
            .document(message.receiver)
            .collection("chats")
            .document(message.sender)
        )

        # Add the message to the receiver's chat
        receiver_chat_ref.collection("messages").document(message.id).set(
            message.to_map()
        )

        print(
            f"[CREATE_COPY] Successfully created copy for receiver {message.receiver}"
        )

    except Exception as e:
        print(
            f"[CREATE_COPY] Error creating copy for receiver {message.receiver}: {str(e)}"
        )
        import traceback

        print(f"[CREATE_COPY] Traceback: {traceback.format_exc()}")
