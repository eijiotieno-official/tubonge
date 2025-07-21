from firebase_functions import https_fn
import json
import logging

# Set up logger with structured format
logger = logging.getLogger(__name__)


def create_response(data, status_code, error=False):
    """
    Create a structured JSON response.
    Args:
        data (str): The data or error message to include in the response.
        status_code (int): The HTTP status code of the response.
        error (bool): Whether the response is an error.
    Returns:
        https_fn.Response: A formatted HTTP response.
    """
    logger.debug(f"[CREATE_RESPONSE] Creating response with status {status_code}")

    # Log the input parameters
    logger.debug(f"[CREATE_RESPONSE] Input data: {data}")
    logger.debug(f"[CREATE_RESPONSE] Error flag: {error}")

    # Prepare the response data
    response_data = {"error": data} if error else {"data": data}
    logger.debug(f"[CREATE_RESPONSE] Response payload: {response_data}")

    # Create the response
    response = https_fn.Response(
        json.dumps(response_data),
        status=status_code,
        headers={
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
    )

    logger.debug(
        f"[CREATE_RESPONSE] Response created successfully with status {status_code}"
    )
    return response
