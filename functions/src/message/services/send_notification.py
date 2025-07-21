from typing import List, Dict
from firebase_admin import messaging
import logging
import os
import json

# Set up logger with structured format
logger = logging.getLogger(__name__)


def send_notifications(tokens: List[str], payload: Dict[str, object]):
    """
    Sends a message to multiple device tokens using Firebase Cloud Messaging (FCM).
    """
    try:
        logger.info(
            f"[SEND_NOTIFICATION] Preparing to send notifications to {len(tokens)} tokens"
        )

        # Check if running in emulator
        is_emulator = os.environ.get("FUNCTIONS_EMULATOR") == "true"

        if is_emulator:
            logger.info(
                "[SEND_NOTIFICATION] Running in emulator mode - skipping actual FCM send"
            )
            logger.debug(f"[SEND_NOTIFICATION] Would have sent to tokens: {tokens}")
            logger.debug(
                f"[SEND_NOTIFICATION] With payload: {json.dumps(payload, default=str)}"
            )

            # Create a mock response for emulator environment
            class MockResponse:
                def __init__(self):
                    self.success_count = len(tokens)
                    self.failure_count = 0
                    self.responses = []

            logger.info(
                f"[SEND_NOTIFICATION] Mock notification sent successfully to {len(tokens)} tokens"
            )
            return MockResponse()

        # Actual FCM sending logic for production
        logger.info(
            f"[SEND_NOTIFICATION] Sending FCM notifications to {len(tokens)} tokens"
        )

        # Convert all payload values to strings, handle None values
        string_payload = {}
        for k, v in payload.items():
            if v is None:
                string_payload[k] = ""  # Empty string for None values
            else:
                string_payload[k] = str(v)

        message = messaging.MulticastMessage(tokens=tokens, data=string_payload)
        logger.debug(f"[SEND_NOTIFICATION] FCM message created: {message}")

        response = messaging.send_multicast(message)
        logger.info(
            f"[SEND_NOTIFICATION] FCM notification sent successfully. Success: {response.success_count}, Failures: {response.failure_count}"
        )

        if response.failure_count > 0:
            logger.warning(
                f"[SEND_NOTIFICATION] {response.failure_count} notifications failed to send"
            )

        return response

    except Exception as e:
        logger.error(
            f"[SEND_NOTIFICATION] Error sending notifications: {str(e)}", exc_info=True
        )
        return None
