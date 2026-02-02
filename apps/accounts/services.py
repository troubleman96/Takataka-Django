from django.db import transaction
from django.contrib.auth import authenticate, login
from .models import User


@transaction.atomic
def user_create(
    *,
    email: str,
    phone_number: str,
    first_name: str,
    last_name: str,
    password: str,
    role: str = User.Role.HOUSEHOLD,
    ward_id: int = None
) -> User:
    """
    Service to handle user registration.
    """
    user = User.objects.create_user(
        email=email,
        phone_number=phone_number,
        first_name=first_name,
        last_name=last_name,
        password=password,
        role=role,
        ward_id=ward_id
    )
    return user


@transaction.atomic
def user_update(
    *,
    user: User,
    **data
) -> User:
    """
    Service to update user profile information.
    """
    non_side_effect_fields = ['first_name', 'last_name', 'email', 'phone_number', 'ward']
    
    for field in non_side_effect_fields:
        if field in data:
            setattr(user, field, data[field])
    
    user.save()
    return user


@transaction.atomic
def user_change_password(
    *,
    user: User,
    new_password: str
):
    """
    Service to change user password.
    """
    user.set_password(new_password)
    user.save()
    return user


def user_verify_otp(
    *,
    phone_number: str,
    otp: str
) -> bool:
    """
    Placeholder for OTP verification logic.
    For now, we'll assume '1234' is always valid for testing.
    """
    return otp == '1234'
