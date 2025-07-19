from abc import ABC, abstractmethod
from datetime import datetime
from enum import Enum


class MessageType(Enum):
    text = "text"
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

    def __str__(self):
        return f"TextMessage(text: {self.text})"
