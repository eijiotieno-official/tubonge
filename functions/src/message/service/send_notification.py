from typing import List
from firebase_admin import messaging
import logging

# Set up logger
_logger = logging.getLogger()


def send_notifications(tokens: List[str], payload: object):
    """
    Sends a message to multiple device tokens using Firebase Cloud Messaging (FCM).

    :param tokens: List of device tokens to send the message to.
    :param payload: Dictionary containing the message payload.
    """
    _logger.info("Preparing to send notifications.")

    if not tokens:
        _logger.warning("No receiver tokens provided. Aborting notification sending.")
        return None

    try:
        message = messaging.MulticastMessage(tokens=tokens, data=payload)
        
        _logger.info(f"Message created: {message}")
        
        response = (messaging.send_multicast, message)
        
        _logger.info(f"Notification sent successfully.")
        return response
    except Exception as e:
        _logger.error(f"Error sending notification: {e}")
        return None
