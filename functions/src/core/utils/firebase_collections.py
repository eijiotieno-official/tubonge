from google.cloud import firestore

# Use lazy initialization to avoid deployment timeouts
_db = None


def get_db():
    """Lazy initialization of Firestore client"""
    global _db
    if _db is None:
        _db = firestore.Client()
    return _db


class FirebaseCollections:
    @staticmethod
    def get_users_collection():
        """Get users collection reference with lazy initialization"""
        return get_db().collection("users")

    @staticmethod
    def chats(user_id: str) -> firestore.CollectionReference:
        """
        Returns the collection reference for chats of a specific user.
        """
        return (
            FirebaseCollections.get_users_collection()
            .document(user_id)
            .collection("chats")
        )

    @staticmethod
    def messages(user_id: str, chat_id: str) -> firestore.CollectionReference:
        """
        Returns the collection reference for messages in a specific chat of a user.
        """
        return (
            FirebaseCollections.chats(user_id).document(chat_id).collection("messages")
        )
