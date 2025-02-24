from enum import Enum


class MessageType(Enum):
    text = "text"
    audio = "audio"
    image = "image"
    video = "video"
    voice = "voice"
    document = "document"
    none = "none"

    @staticmethod
    def from_type(message_type):
        try:
            return message_type.name
        except Exception as e:
            raise ValueError(f"Unknown MessageType: {message_type}") from e

    @staticmethod
    def to_type(string):
        try:
            return MessageType[string]
        except KeyError as e:
            raise ValueError(f"Unknown MessageType: {string}") from e
