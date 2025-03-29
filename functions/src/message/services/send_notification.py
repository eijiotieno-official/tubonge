from typing import List, Dict
from firebase_admin import messaging
import logging
import os

# Set up logger
logger = logging.getLogger(__name__)


def send_notifications(tokens: List[str], payload: Dict[str, object]):
    """
    Sends a message to multiple device tokens using Firebase Cloud Messaging (FCM).
    :param tokens: List of device tokens to send the message to.
    :param payload: Dictionary containing the message payload.
    :return: The response from sending the multicast message, or None if an error occurred.
    """
    logger.info("Preparing to send notifications.")

    # Check if running in emulator
    is_emulator = os.environ.get("FUNCTIONS_EMULATOR") == "true"

    if is_emulator:
        logger.info("Running in emulator mode - skipping actual FCM send")
        logger.info(f"Would have sent to tokens: {tokens}")
        logger.info(f"With payload: {payload}")

        # Create a mock response for emulator environment
        class MockResponse:
            def __init__(self):
                self.success_count = len(tokens)
                self.failure_count = 0
                self.responses = []

        return MockResponse()

    # Actual FCM sending logic for production
    try:
        # Convert all payload values to strings, handle None values
        string_payload = {}
        for k, v in payload.items():
            if v is None:
                string_payload[k] = ""  # Empty string for None values
            else:
                string_payload[k] = str(v)

        message = messaging.MulticastMessage(tokens=tokens, data=string_payload)
        logger.info(f"Message created: {message}")
        response = messaging.send_multicast(message)
        logger.info(f"Notification sent successfully. Response: {response}")
        return response
    except Exception as e:
        logger.error(f"Error sending notification: {e}")
        return None
