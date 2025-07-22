import json
from firebase_functions import https_fn

from src.contact.models.contact_model import ContactModel
from src.contact.services.get_registered_contacts import get_registered_contacts
from src.core.services.create_response import create_response


@https_fn.on_request()
def request_registered_contacts(req: https_fn.Request) -> https_fn.Response:
    """
    HTTP function to get registered contacts from a list of phone numbers.
    """
    try:
        print("[REQUEST_CONTACTS] Received request to get registered contacts")

        # Log request details for debugging
        print(f"[REQUEST_CONTACTS] Request method: {req.method}")
        print(f"[REQUEST_CONTACTS] Request headers: {dict(req.headers)}")
        print(f"[REQUEST_CONTACTS] Request URL: {req.url}")

        # Check if it's a POST request
        if req.method != "POST":
            print(
                f"[REQUEST_CONTACTS] Invalid request method: {req.method}. Expected POST"
            )
            return create_response(
                {"error": f"Invalid request method: {req.method}. Expected POST"}, 405
            )

        # Extract data from POST request body
        request_json = req.get_json(silent=True)
        if not request_json:
            # Log the raw request body for debugging
            try:
                raw_body = req.get_data(as_text=True)
                print(
                    f"[REQUEST_CONTACTS] Invalid or missing JSON in request body. Raw body: '{raw_body}'"
                )
            except Exception as e:
                print(f"[REQUEST_CONTACTS] Could not read request body: {str(e)}")

            return create_response(
                {"error": "Invalid or missing JSON in request body"}, 400
            )

        print(
            f"[REQUEST_CONTACTS] Request JSON: {json.dumps(request_json, default=str)}"
        )

        # Check if "data" key exists and is not None
        data = request_json.get("data")
        if data is None:
            print("[REQUEST_CONTACTS] Missing 'data' in request JSON")
            return create_response({"error": "Missing 'data' in request JSON"}, 400)

        # Check if "contacts" key exists in "data"
        contacts_data = data.get("contacts")
        if contacts_data is None:
            print("[REQUEST_CONTACTS] Missing 'contacts' in request JSON data")
            return create_response(
                {"error": "Missing 'contacts' in request JSON data"}, 400
            )

        print(f"[REQUEST_CONTACTS] Processing {len(contacts_data)} contacts")

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
            print(f"[REQUEST_CONTACTS] Parsed {len(contacts)} contact models")
        except (json.JSONDecodeError, AttributeError) as e:
            print(f"[REQUEST_CONTACTS] Failed to parse contacts data: {str(e)}")
            import traceback

            print(f"[REQUEST_CONTACTS] Traceback: {traceback.format_exc()}")
            return create_response({"error": "Invalid contacts data format"}, 400)

        # Get registered contacts
        registered_contacts = get_registered_contacts(contacts)
        print(
            f"[REQUEST_CONTACTS] Found {len(registered_contacts)} registered contacts"
        )

        response = create_response(
            {
                "registeredContacts": registered_contacts,
            },
            200,
        )

        print(
            f"[REQUEST_CONTACTS] Returning response with {len(registered_contacts)} contacts"
        )
        return response

    except Exception as e:
        print(f"[REQUEST_CONTACTS] Unexpected error: {str(e)}")
        import traceback

        print(f"[REQUEST_CONTACTS] Traceback: {traceback.format_exc()}")
        return create_response({"error": "Internal server error"}, 500)
