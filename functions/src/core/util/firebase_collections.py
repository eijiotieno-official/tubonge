from google.cloud import firestore

# Initialize Firestore client
db = firestore.Client()


class FirebaseCollections:
    # Firestore collection references
    users = db.collection("users")

    @staticmethod
    def chats(user_id: str) -> firestore.CollectionReference:
        """
        Returns the collection reference for chats of a specific user.
        """
        return FirebaseCollections.users.document(user_id).collection("chats")

    @staticmethod
    def messages(user_id: str, chat_id: str) -> firestore.CollectionReference:
        """
        Returns the collection reference for messages in a specific chat of a user.
        """
        return FirebaseCollections.chats(user_id).document(chat_id).collection("messages")
