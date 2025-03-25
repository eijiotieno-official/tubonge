import json
from typing import Optional

class Phone:
    def __init__(self, iso_code: str, dial_code: str, phone_number: str):
        self.iso_code = iso_code
        self.dial_code = dial_code
        self.phone_number = phone_number

    def copy_with(
        self,
        iso_code: Optional[str] = None,
        dial_code: Optional[str] = None,
        phone_number: Optional[str] = None,
    ) -> "Phone":
        return Phone(
            iso_code=iso_code if iso_code is not None else self.iso_code,
            dial_code=dial_code if dial_code is not None else self.dial_code,
            phone_number=phone_number if phone_number is not None else self.phone_number,
        )

    def to_map(self) -> dict:
        return {
            'isoCode': self.iso_code,
            'dialCode': self.dial_code,
            'phoneNumber': self.phone_number,
        }

    @staticmethod
    def from_map(data: dict) -> "Phone":
        if isinstance(data, str):
            return Phone(iso_code="", dial_code="", phone_number=data)
        return Phone(
            iso_code=data.get('isoCode', ''),
            dial_code=data.get('dialCode', ''),
            phone_number=data.get('phoneNumber', ''),
        )
