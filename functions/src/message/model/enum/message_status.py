from enum import Enum


class MessageStatus(Enum):
    sent = "sent"
    delivered = "delivered"
    seen = "seen"
    none = "none"

    @staticmethod
    def from_type(message_status):
        try:
            return message_status.name
        except Exception as e:
            raise ValueError(f"Unknown MessageStatus: {message_status}") from e

    @staticmethod
    def to_type(string):
        try:
            return MessageStatus[string]
        except KeyError as e:
            raise ValueError(f"Unknown MessageStatus: {string}") from e
