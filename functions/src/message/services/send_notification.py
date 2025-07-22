from typing import List, Dict
from firebase_admin import messaging


def send_notifications(tokens: List[str], payload: Dict[str, object]):
    """
    Sends a message to multiple device tokens using Firebase Cloud Messaging (FCM).
    """
    try:
        # Actual FCM sending logic for production
        print(f"[SEND_NOTIFICATION] Sending FCM notifications to {len(tokens)} tokens")

        # Convert all payload values to strings, handle None values
        string_payload = {}
        for k, v in payload.items():
            if v is None:
                string_payload[k] = ""  # Empty string for None values
            else:
                string_payload[k] = str(v)

        message = messaging.MulticastMessage(tokens=tokens, data=string_payload)
        print(f"[SEND_NOTIFICATION] FCM message created: {message}")

        # Use send_each_for_multicast instead of deprecated send_multicast
        response = messaging.send_each_for_multicast(message)

        print(
            f"[SEND_NOTIFICATION] FCM notification sent successfully. Success: {response.success_count}, Failures: {response.failure_count}"
        )

        if response.failure_count > 0:
            print(
                f"[SEND_NOTIFICATION] {response.failure_count} notifications failed to send"
            )

        return response

    except Exception as e:
        print(f"[SEND_NOTIFICATION] Error sending notifications: {str(e)}")
        import traceback

        print(f"[SEND_NOTIFICATION] Traceback: {traceback.format_exc()}")
        return None
