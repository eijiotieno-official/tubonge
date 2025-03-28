import re


def is_url(string):
    """
    Check if a given string is a valid URL starting with http or https.

    :param string: The string to check.
    :return: True if the string is a valid URL, False otherwise.
    """
    url_pattern = re.compile(
        r"^(https?://)"  # Must start with http:// or https://
        r"([a-zA-Z0-9-]+\.)*[a-zA-Z0-9-]+"  # Domain or subdomain
        r"(:[0-9]{1,5})?"  # Optional port
        r"(\/[^\s]*)?$"  # Optional path
    )
    return bool(url_pattern.match(string))
