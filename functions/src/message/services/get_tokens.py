from typing import List, Tuple
from src.core.utils.firebase_collections import FirebaseCollections
from src.core.models.user_model import UserModel
import logging

# Set up the logger
_logger = logging.getLogger()


def get_tokens(user_id: str) -> Tuple[List[str], str, str]:
    try:
        _logger.info(f"Fetching tokens for user ID: {user_id}")

        # Fetch user document snapshot
        user_data_snapshot = FirebaseCollections.users.document(user_id).get()

        # Check if the user document exists
        if not user_data_snapshot.exists:
            _logger.error(f"User ID {user_id} not found in Firestore.")
            return [], f"User ID {user_id} not found in Firestore."

        # Convert snapshot data to a dictionary
        user_data = user_data_snapshot.to_dict()
        _logger.debug(f"User data fetched: {user_data}")

        # Create a UserModel instance from the data
        user = UserModel.from_map(user_data)

        # Log success
        _logger.info(
            f"User tokens and phone fetched successfully for user ID: {user_id}"
        )

        return user.tokens, user.phone.phone_number, user.photo

    except Exception as e:
        # Log the error
        error_message = f"Error fetching tokens or phone for user ID: {user_id} - {e}"
        _logger.error(error_message)
        return [], error_message
