from django.shortcuts import get_object_or_404
from .models import User


def get_user_by_id(*, user_id: int) -> User:
    """
    Retrieve a user by their ID.
    """
    return get_object_or_404(User, id=user_id)


def get_user_by_phone(*, phone_number: str) -> User:
    """
    Retrieve a user by their phone number.
    """
    return get_object_or_404(User, phone_number=phone_number)


def user_get_login_data(*, phone_number: str):
    """
    Get user instance for login processing.
    """
    try:
        return User.objects.get(phone_number=phone_number, is_active=True)
    except User.DoesNotExist:
        return None
