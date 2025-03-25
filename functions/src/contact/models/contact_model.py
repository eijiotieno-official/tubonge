import json
from typing import Any, Dict, List, Optional
from src.core.models.phone_model import Phone


class ContactModel:
    def __init__(
        self,
        name: str,
        phone_numbers: List[Phone],
        id: Optional[str] = None,
        photo: Optional[str] = None,  # New photo field
    ):
        self.name = name
        self.phone_numbers = phone_numbers
        self.id = id
        self.photo = photo  # Assign the photo field

    def copy_with(
        self,
        name: Optional[str] = None,
        phone_numbers: Optional[List[Phone]] = None,
        id: Optional[str] = None,
        photo: Optional[str] = None,  # New photo field for copy
    ) -> "ContactModel":
        return ContactModel(
            name=name or self.name,
            phone_numbers=phone_numbers or self.phone_numbers,
            id=id if id is not None else self.id,
            photo=photo if photo is not None else self.photo,  # Copy photo
        )

    def to_map(self) -> Dict[str, Any]:
        return {
            "name": self.name,
            "phoneNumbers": [phone.to_map() for phone in self.phone_numbers],
            "id": self.id,
            "photo": self.photo,  # Include photo in map
        }

    def to_json(self) -> str:
        return json.dumps(self.to_map())

    @staticmethod
    def from_json(data: str) -> "ContactModel":
        return ContactModel.from_map(json.loads(data))

    @staticmethod
    def from_map(data: Dict[str, Any]) -> "ContactModel":
        return ContactModel(
            name=data.get("name", ""),
            phone_numbers=[
                Phone.from_map(phone) for phone in data.get("phoneNumbers", [])
            ],
            id=data.get("id"),
            photo=data.get("photo"),  # Extract photo from map
        )
