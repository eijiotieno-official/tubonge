import logging
import json
from firebase_functions import https_fn

logger = logging.getLogger()

from src.contact.models.contact_model import ContactModel
from src.contact.services.get_registered_contacts import get_registered_contacts
from src.core.service.create_response import create_response


@https_fn.on_request()
def request_registered_contacts(req: https_fn.Request) -> https_fn.Response:
    logger.info("Received request to get registered contacts")

    # Extract data from POST request body
    request_json = req.get_json(silent=True)
    if not request_json:
        logger.error("Invalid or missing JSON in request body")
        return create_response(
            {"error": "Invalid or missing JSON in request body"}, 400
        )

    logger.info(f"Extracted JSON from request body: {request_json}")

    # Check if "data" key exists and is not None
    data = request_json.get("data")
    if data is None:
        logger.error("Missing 'data' in request JSON")
        return create_response({"error": "Missing 'data' in request JSON"}, 400)

    # Check if "contacts" key exists in "data"
    contacts_data = data.get("contacts")
    if contacts_data is None:
        logger.error("Missing 'contacts' in request JSON data")
        return create_response(
            {"error": "Missing 'contacts' in request JSON data"}, 400
        )

    logger.info(f"Extracted contacts data: {contacts_data}")

    # Parse JSON strings in contacts_data
    try:
        contacts = [
            (
                ContactModel.from_map(json.loads(contact))
                if isinstance(contact, str)
                else ContactModel.from_map(contact)
            )
            for contact in contacts_data
        ]
    except (json.JSONDecodeError, AttributeError) as e:
        logger.error(f"Failed to parse contacts data: {e}")
        return create_response({"error": "Invalid contacts data format"}, 400)

    logger.info(f"Converted contacts data to ContactModel instances: {contacts}")

    registered_contacts = get_registered_contacts(contacts)
    logger.info(f"Retrieved registered contacts: {registered_contacts}")

    response = create_response(
        {
            "registeredContacts": registered_contacts,
        },
        200,
    )
    logger.info("Created response")

    return response
