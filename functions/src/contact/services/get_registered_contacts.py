import logging
from firebase_admin import firestore
from typing import List
from src.contact.models.contact_model import ContactModel
from src.core.models.user_model import UserModel

logger = logging.getLogger()

db = firestore.client()


def has_seven_digit_match(phone_number1: str, phone_number2: str) -> bool:
    if len(phone_number1) < 7 or len(phone_number2) < 7:
        return False
    match_count = sum(
        1 for a, b in zip(phone_number1[::-1], phone_number2[::-1]) if a == b
    )
    return match_count >= 7


def is_direct_match(phone_number1: str, phone_number2: str) -> bool:
    return phone_number1 == phone_number2


def get_registered_contacts(contacts: List[ContactModel]) -> List[ContactModel]:

    logger.debug("Fetching users from Firestore")
    # Reference to the 'users' collection in Firestore
    users_ref = db.collection("users")

    # Fetch all users from Firestore
    results = users_ref.stream()

    # Transform results to UserModel instances
    users = [UserModel.from_map(user.to_dict()) for user in results]
    logger.debug(f"Fetched {len(users)} users from Firestore")

    # Create a dictionary to map phone numbers to user ids
    matched_contacts = []

    for contact in contacts:
        match_found = False
        for phone in contact.phone_numbers:
            if match_found:
                break
            for user in users:
                user_phone_number = user.phone.phone_number
                if is_direct_match(
                    phone.phone_number, user_phone_number
                ) or has_seven_digit_match(phone.phone_number, user_phone_number):
                    # Append a copy of the contact with the matched user id to the matched_contacts list
                    matched_contacts.append(
                        contact.copy_with(
                            id=user.id,
                            phone_numbers=[
                                phone.copy_with(
                                    phone_number=user.phone.phone_number,
                                    iso_code=user.phone.iso_code,
                                    dial_code=user.phone.dial_code,
                                )
                            ],
                            photo=user.photo,
                        ).to_json()
                    )
                    match_found = True
                    logger.debug(
                        f"Match found for contact {contact.id} with user {user.id}"
                    )
                    break

    logger.debug(f"Total matched contacts: {len(matched_contacts)}")
    return matched_contacts
