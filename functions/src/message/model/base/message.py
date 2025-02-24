from abc import ABC, abstractmethod
from datetime import datetime
from src.message.model.enum.message_status import MessageStatus
from src.message.model.enum.message_type import MessageType


class Message(ABC):
    def __init__(self, id, sender, receiver, type, status, time_sent):
        self.id = id
        self.sender = sender
        self.receiver = receiver
        self.type = type
        self.status = status
        self.time_sent = time_sent

    @abstractmethod
    def copy_with(
        self,
        id=None,
        sender=None,
        receiver=None,
        type=None,
        status=None,
        time_sent=None,
    ):
        pass

    @abstractmethod
    def to_map(self):
        pass

    @staticmethod
    def from_map(map):
        message_type = MessageType.to_type(map["type"])  # Converting type to enum

        if message_type == MessageType.text:
            return TextMessage.from_map(map)
        elif message_type == MessageType.image:
            return ImageMessage.from_map(map)
        elif message_type == MessageType.video:
            return VideoMessage.from_map(map)
        else:
            raise ValueError(f"Unknown MessageType: {message_type}")


class TextMessage(Message):
    def __init__(self, text, id, sender, receiver, status, time_sent):
        super().__init__(id, sender, receiver, MessageType.text, status, time_sent)
        self.text = text

    def to_map(self):
        return {
            "text": self.text,
            "id": self.id,
            "sender": self.sender,
            "receiver": self.receiver,
            "status": MessageStatus.from_type(self.status),
            "timeSent": self.time_sent,
            "type": MessageType.from_type(self.type),
        }

    @staticmethod
    def from_map(map):
        return TextMessage(
            text=map["text"],
            id=map["id"],
            sender=map["sender"],
            receiver=map["receiver"],
            status=MessageStatus.to_type(map["status"]),
            time_sent=map["timeSent"],
        )

    def copy_with(
        self,
        text=None,
        id=None,
        sender=None,
        receiver=None,
        type=None,
        status=None,
        time_sent=None,
    ):
        return TextMessage(
            text=text or self.text,
            id=id or self.id,
            sender=sender or self.sender,
            receiver=receiver or self.receiver,
            status=status or self.status,
            time_sent=time_sent or self.time_sent,
        )

    @staticmethod
    def empty():
        return TextMessage(
            text="",
            id="",
            sender="",
            receiver="",
            status=MessageStatus.none,
            time_sent=datetime.now(),
        )

    def is_not_empty(self):
        return bool(self.text and self.sender and self.receiver)

    def __str__(self):
        return f"TextMessage(text: {self.text})"


class ImageMessage(Message):
    def __init__(self, image_uri, id, sender, receiver, status, time_sent, text=None):
        super().__init__(id, sender, receiver, MessageType.image, status, time_sent)
        self.text = text
        self.image_uri = image_uri

    def to_map(self):
        return {
            "text": self.text,
            "imageUri": self.image_uri,
            "id": self.id,
            "sender": self.sender,
            "receiver": self.receiver,
            "status": MessageStatus.from_type(self.status),
            "timeSent": self.time_sent,
            "type": MessageType.from_type(self.type),
        }

    @staticmethod
    def from_map(map):
        return ImageMessage(
            text=map.get("text"),
            image_uri=map["imageUri"],
            id=map["id"],
            sender=map["sender"],
            receiver=map["receiver"],
            status=MessageStatus[map["status"]],
            time_sent=map["timeSent"],
        )

    def copy_with(
        self,
        text=None,
        image_uri=None,
        id=None,
        sender=None,
        receiver=None,
        type=None,
        status=None,
        time_sent=None,
    ):
        return ImageMessage(
            text=text or self.text,
            image_uri=image_uri or self.image_uri,
            id=id or self.id,
            sender=sender or self.sender,
            receiver=receiver or self.receiver,
            status=status or self.status,
            time_sent=time_sent or self.time_sent,
        )

    @staticmethod
    def empty():
        return ImageMessage(
            text=None,
            image_uri="",
            id="",
            sender="",
            receiver="",
            status=MessageStatus.none,
            time_sent=datetime.now(),
        )

    def is_not_empty(self):
        return bool(self.image_uri and self.sender and self.receiver)

    def __str__(self):
        return f"ImageMessage(imageUri: {self.image_uri}, text: {self.text})"


class VideoMessage(Message):
    def __init__(self, video_uri, id, sender, receiver, status, time_sent, text=None):
        super().__init__(id, sender, receiver, MessageType.video, status, time_sent)
        self.text = text
        self.video_uri = video_uri

    def to_map(self):
        return {
            "text": self.text,
            "videoUri": self.video_uri,
            "id": self.id,
            "sender": self.sender,
            "receiver": self.receiver,
            "status": MessageStatus.from_type(self.status),
            "timeSent": self.time_sent,
            "type": MessageType.from_type(self.type),
        }

    @staticmethod
    def from_map(map):
        return VideoMessage(
            text=map.get("text"),
            video_uri=map["videoUri"],
            id=map["id"],
            sender=map["sender"],
            receiver=map["receiver"],
            status=MessageStatus[map["status"]],
            time_sent=map["timeSent"],
        )

    def copy_with(
        self,
        text=None,
        video_uri=None,
        id=None,
        sender=None,
        receiver=None,
        type=None,
        status=None,
        time_sent=None,
    ):
        return VideoMessage(
            text=text or self.text,
            video_uri=video_uri or self.video_uri,
            id=id or self.id,
            sender=sender or self.sender,
            receiver=receiver or self.receiver,
            status=status or self.status,
            time_sent=time_sent or self.time_sent,
        )

    @staticmethod
    def empty():
        return VideoMessage(
            text=None,
            video_uri="",
            id="",
            sender="",
            receiver="",
            status=MessageStatus.none,
            time_sent=datetime.now(),
        )

    def is_not_empty(self):
        return bool(self.video_uri and self.sender and self.receiver)

    def __str__(self):
        return f"VideoMessage(videoUri: {self.video_uri}, text: {self.text})"


class AudioMessage(Message):
    def __init__(self, audio_title, audio_uri, id, sender, receiver, status, time_sent):
        super().__init__(id, sender, receiver, MessageType.audio, status, time_sent)
        self.audio_title = audio_title
        self.audio_uri = audio_uri

    def to_map(self):
        return {
            "audioTitle": self.audio_title,
            "audioUri": self.audio_uri,
            "id": self.id,
            "sender": self.sender,
            "receiver": self.receiver,
            "status": MessageStatus.from_type(self.status),
            "timeSent": self.time_sent,
            "type": MessageType.from_type(self.type),
        }

    @staticmethod
    def from_map(map):
        return AudioMessage(
            audio_title=map["audioTitle"],
            audio_uri=map["audioUri"],
            id=map["id"],
            sender=map["sender"],
            receiver=map["receiver"],
            status=MessageStatus[map["status"]],
            time_sent=map["timeSent"],
        )

    def copy_with(
        self,
        audio_title=None,
        audio_uri=None,
        id=None,
        sender=None,
        receiver=None,
        type=None,
        status=None,
        time_sent=None,
    ):
        return AudioMessage(
            audio_title=audio_title or self.audio_title,
            audio_uri=audio_uri or self.audio_uri,
            id=id or self.id,
            sender=sender or self.sender,
            receiver=receiver or self.receiver,
            status=status or self.status,
            time_sent=time_sent or self.time_sent,
        )

    @staticmethod
    def empty():
        return AudioMessage(
            audio_title="",
            audio_uri="",
            id="",
            sender="",
            receiver="",
            status=MessageStatus.none,
            time_sent=datetime.now(),
        )

    def is_not_empty(self):
        return all([self.audio_title, self.audio_uri, self.sender, self.receiver])

    def __str__(self):
        return (
            f"AudioMessage(audioTitle: {self.audio_title}, audioUri: {self.audio_uri})"
        )


class VoiceMessage(Message):
    def __init__(self, voice_uri, id, sender, receiver, status, time_sent):
        super().__init__(id, sender, receiver, MessageType.voice, status, time_sent)
        self.voice_uri = voice_uri

    def to_map(self):
        return {
            "voiceUri": self.voice_uri,
            "id": self.id,
            "sender": self.sender,
            "receiver": self.receiver,
            "status": MessageStatus.from_type(self.status),
            "timeSent": self.time_sent,
            "type": MessageType.from_type(self.type),
        }

    @staticmethod
    def from_map(map):
        return VoiceMessage(
            voice_uri=map["voiceUri"],
            id=map["id"],
            sender=map["sender"],
            receiver=map["receiver"],
            status=MessageStatus[map["status"]],
            time_sent=map["timeSent"],
        )

    def copy_with(
        self,
        voice_uri=None,
        id=None,
        sender=None,
        receiver=None,
        type=None,
        status=None,
        time_sent=None,
    ):
        return VoiceMessage(
            voice_uri=voice_uri or self.voice_uri,
            id=id or self.id,
            sender=sender or self.sender,
            receiver=receiver or self.receiver,
            status=status or self.status,
            time_sent=time_sent or self.time_sent,
        )

    @staticmethod
    def empty():
        return VoiceMessage(
            voice_uri="",
            id="",
            sender="",
            receiver="",
            status=MessageStatus.none,
            time_sent=datetime.now(),
        )

    def is_not_empty(self):
        return all([self.voice_uri, self.sender, self.receiver])

    def __str__(self):
        return f"VoiceMessage(voiceUri: {self.voice_uri})"


class DocumentMessage(Message):
    def __init__(
        self, document_title, document_uri, id, sender, receiver, status, time_sent
    ):
        super().__init__(id, sender, receiver, MessageType.document, status, time_sent)
        self.document_title = document_title
        self.document_uri = document_uri

    def to_map(self):
        return {
            "documentTitle": self.document_title,
            "documentUri": self.document_uri,
            "id": self.id,
            "sender": self.sender,
            "receiver": self.receiver,
            "status": MessageStatus.from_type(self.status),
            "timeSent": self.time_sent,
            "type": MessageType.from_type(self.type),
        }

    @staticmethod
    def from_map(map):
        return DocumentMessage(
            document_title=map["documentTitle"],
            document_uri=map["documentUri"],
            id=map["id"],
            sender=map["sender"],
            receiver=map["receiver"],
            status=MessageStatus[map["status"]],
            time_sent=map["timeSent"],
        )

    def copy_with(
        self,
        document_title=None,
        document_uri=None,
        id=None,
        sender=None,
        receiver=None,
        type=None,
        status=None,
        time_sent=None,
    ):
        return DocumentMessage(
            document_title=document_title or self.document_title,
            document_uri=document_uri or self.document_uri,
            id=id or self.id,
            sender=sender or self.sender,
            receiver=receiver or self.receiver,
            status=status or self.status,
            time_sent=time_sent or self.time_sent,
        )

    @staticmethod
    def empty():
        return DocumentMessage(
            document_title="",
            document_uri="",
            id="",
            sender="",
            receiver="",
            status=MessageStatus.none,
            time_sent=datetime.now(),
        )

    def is_not_empty(self):
        return (
            self.document_title and self.document_uri and self.sender and self.receiver
        )

    def __str__(self):
        return f"DocumentMessage(documentTitle: {self.document_title}, documentUri: {self.document_uri})"
