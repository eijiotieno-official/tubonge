from firebase_functions.firestore_fn import (
    on_document_updated,
    Event,
    Change,
    DocumentSnapshot,
)
from src.message.model.base.message import *
from src.message.service.update_message_status import *
from src.message.service.create_copy_for_receiver import *
from src.message.service.get_tokens import *
from src.message.service.send_notification import *
from src.core.util.is_url import is_url
import logging

_logger = logging.getLogger()


@on_document_updated(document="users/{user_id}/chats/{chat_id}/messages/{message_id}")
def on_message_uri_updated(event: Event[Change[DocumentSnapshot]]) -> None:
    try:
        # Extract the before and after document data
        before_doc_data = event.data.before.to_dict()
        after_doc_data = event.data.after.to_dict()

        # Deserialize the messages
        before_message = Message.from_map(before_doc_data)
        after_message = Message.from_map(after_doc_data)

        _logger.info(f"Before: {before_message}, After: {after_message}")

        # Ensure it's NOT a TextMessage and proceed only if it's an ImageMessage or other type
        if not isinstance(
            after_message, TextMessage
        ):  # This ensures we're NOT dealing with TextMessage
            if after_message.status == MessageStatus.none:
                if isinstance(after_message, ImageMessage):  # Process ImageMessage
                    # Prepare payload for notification
                    if before_message.image_uri != after_message.image_uri:

                        # Only send notification if the image_uri is a valid URL
                        if is_url(after_message.image_uri):
                            # Get receiver tokens and send notification if found
                            tokens, name, photoUrl = get_tokens(
                                user_id=after_message.receiver
                            )

                            if not tokens:
                                _logger.warning(
                                    f"No tokens found for user: {after_message.receiver}"
                                )
                                return

                            payload = {
                                "data": {
                                    "sender_id": after_message.sender,
                                    "sender_name": name,
                                    "sender_photoUrl": photoUrl,
                                    "message_id": after_message.id,
                                    "message_text": after_message.text,
                                    "message_image": after_message.image_uri,
                                    "type": "image",
                                },
                            }

                            on_send(message=after_message, payload=payload, tokens=tokens)

                if isinstance(after_message, VideoMessage):  # Process VideoMessage
                    # Prepare payload for notification
                    if before_message.video_uri != after_message.video_uri:

                        # Only send notification if the video_uri is a valid URL
                        if is_url(after_message.video_uri):

                            # Get receiver tokens and send notification if found
                            tokens, name, photoUrl = get_tokens(
                                user_id=after_message.receiver
                            )

                            if not tokens:
                                _logger.warning(
                                    f"No tokens found for user: {after_message.receiver}"
                                )
                                return

                            payload = {
                                "data": {
                                    "sender_id": after_message.sender,
                                    "sender_name": name,
                                    "sender_photoUrl": photoUrl,
                                    "message_id": after_message.id,
                                    "message_text": after_message.text,
                                    "message_video": after_message.video_uri,
                                    "type": "video",
                                },
                            }

                            on_send(
                                message=after_message, payload=payload, tokens=tokens
                            )

    except Exception as e:
        _logger.error(f"Error processing message update: {e}", exc_info=True)
        return


def on_send(message: Message, payload: object, tokens: List[str]) -> None:
    try:
        # Create copy for the receiver and update message status
        updated_message = update_message_status(
            message=message, new_status=MessageStatus.sent
        )

        create_copy_for_receiver(message=updated_message)

        send_notifications(tokens=tokens, payload=payload)

    except Exception as e:
        _logger.error(f"Error in on_send function: {e}", exc_info=True)
