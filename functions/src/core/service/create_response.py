from firebase_functions import https_fn
import json
import logging


logger = logging.getLogger()


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
    logger.info("Starting to create the response.")

    # Log the input parameters
    logger.debug(f"Input data: {data}")
    logger.debug(f"Status code: {status_code}")
    logger.debug(f"Error flag: {error}")

    # Prepare the response data
    response_data = {"error": data} if error else {"data": data}
    logger.info(f"Response payload prepared: {response_data}")

    # Log the response creation step
    logger.info(f"Creating response with status code {status_code}.")
    response = https_fn.Response(
        json.dumps(response_data),
        status=status_code,
        headers={
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
    )

    logger.info("Response created successfully.")
    return response
