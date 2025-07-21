from typing import List, Tuple
from src.core.utils.firebase_collections import FirebaseCollections
from src.core.models.user_model import UserModel
import logging
import json

# Set up the logger with structured format
_logger = logging.getLogger(__name__)


def get_tokens(user_id: str) -> Tuple[List[str], str, str]:
    """
    Fetches FCM tokens and user info for a given user ID.
    """
    try:
        _logger.info(f"[GET_TOKENS] Fetching tokens for user {user_id}")

        # Fetch user document snapshot using lazy initialization
        user_data_snapshot = (
            FirebaseCollections.get_users_collection().document(user_id).get()
        )

        # Check if the user document exists
        if not user_data_snapshot.exists:
            _logger.error(f"[GET_TOKENS] User {user_id} not found in Firestore")
            return [], f"User {user_id} not found", ""

        # Convert snapshot data to a dictionary
        user_data = user_data_snapshot.to_dict()
        _logger.debug(f"[GET_TOKENS] User data: {json.dumps(user_data, default=str)}")

        # Create a UserModel instance from the data
        user = UserModel.from_map(user_data)

        # Log success
        _logger.info(
            f"[GET_TOKENS] Successfully fetched {len(user.tokens)} tokens for user {user_id}"
        )
        _logger.debug(
            f"[GET_TOKENS] Phone: {user.phone.phone_number}, Photo: {user.photo}"
        )

        return user.tokens, user.phone.phone_number, user.photo

    except Exception as e:
        error_message = (
            f"[GET_TOKENS] Error fetching tokens for user {user_id}: {str(e)}"
        )
        _logger.error(error_message, exc_info=True)
        return [], f"Error: {str(e)}", ""
