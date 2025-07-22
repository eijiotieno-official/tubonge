from firebase_admin import firestore
from typing import Tuple, List, Optional


def get_tokens(user_id: str) -> Tuple[List[str], Optional[str], Optional[str]]:
    """
    Retrieves FCM tokens, phone number, and photo for a given user ID.
    Returns a tuple of (tokens, phone_number, photo).
    """
    try:
        print(f"[GET_TOKENS] Fetching tokens for user: {user_id}")

        db = firestore.client()
        user_doc = db.collection("users").document(user_id).get()

        if not user_doc.exists:
            print(f"[GET_TOKENS] User document not found for user: {user_id}")
            return [], None, None

        user_data = user_doc.to_dict()
        tokens = user_data.get("tokens", [])
        phone_data = user_data.get("phone", {})
        phone_number = phone_data.get("phoneNumber") if phone_data else None
        photo = user_data.get("photo")

        print(f"[GET_TOKENS] Found {len(tokens)} tokens for user {user_id}")
        print(f"[GET_TOKENS] Phone number: {phone_number}, Photo: {photo}")

        return tokens, phone_number, photo

    except Exception as e:
        print(f"[GET_TOKENS] Error fetching tokens for user {user_id}: {str(e)}")
        import traceback

        print(f"[GET_TOKENS] Traceback: {traceback.format_exc()}")
        return [], None, None
