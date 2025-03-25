import json
from typing import List, Optional


class UserModel:
    def __init__(
        self,
        id: str,
        email: str,
        photoUrl: str,
        name: str,
        tokens: List[str],
    ):
        self.id = id
        self.email = email
        self.photoUrl = photoUrl
        self.name = name
        self.tokens = tokens

    def copy_with(
        self,
        id: Optional[str] = None,
        email: Optional[str] = None,
        photoUrl: Optional[str] = None,
        name: Optional[str] = None,
        tokens: Optional[List[str]] = None,
    ) -> "UserModel":
        return UserModel(
            id=id if id is not None else self.id,
            email=email if email is not None else self.email,
            photoUrl=photoUrl if photoUrl is not None else self.photoUrl,
            name=name if name is not None else self.name,
            tokens=tokens if tokens is not None else self.tokens,
        )

    def to_map(self) -> dict:
        return {
            "id": self.id,
            "email": self.email.to_map(),
            "photoUrl": self.photoUrl,
            "name": self.name,
            "tokens": self.tokens,
        }

    @staticmethod
    def from_map(data: dict) -> "UserModel":
        return UserModel(
            id=data.get("id", ""),
            email=data.get("email"),
            photoUrl=data.get("photoUrl", ""),
            name=data.get("name", ""),
            tokens=data.get("tokens", []),
        )
