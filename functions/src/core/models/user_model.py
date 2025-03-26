import json
from typing import List, Optional
from src.core.models.phone_model import Phone


class UserModel:
    def __init__(
        self,
        id: str,
        phone: Phone,
        photo: str,
        tokens: List[str],
    ):
        self.id = id
        self.phone = phone
        self.photo = photo
        self.tokens = tokens

    def copy_with(
        self,
        id: Optional[str] = None,
        phone: Optional[Phone] = None,
        photo: Optional[str] = None,
        tokens: Optional[List[str]] = None,
    ) -> "UserModel":
        return UserModel(
            id=id if id is not None else self.id,
            phone=phone if phone is not None else self.phone,
            photo=photo if photo is not None else self.photo,
            tokens=tokens if tokens is not None else self.tokens,
        )

    def to_map(self) -> dict:
        return {
            "id": self.id,
            "phone": self.phone.to_map(),
            "photo": self.photo,
            "tokens": self.tokens,
        }

    @staticmethod
    def from_map(data: dict) -> "UserModel":
        return UserModel(
            id=data.get("id", ""),
            phone=Phone.from_map(data.get("phone", {})),
            photo=data.get("photo", ""),
            tokens=data.get("tokens", []),
        )
