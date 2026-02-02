from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.db import models
from apps.core.models import TimeStampedModel
from .managers import UserManager


class User(AbstractBaseUser, PermissionsMixin, TimeStampedModel):
    """
    Custom user model with role-based access.
    """
    
    class Role(models.TextChoices):
        ADMIN = 'admin', 'Administrator'
        WARD_OFFICER = 'ward_officer', 'Ward Officer'
        COLLECTOR = 'collector', 'Money Collector'
        DRIVER = 'driver', 'Driver'
        HOUSEHOLD = 'household', 'Household User'
    
    first_name = models.CharField(max_length=20)
    last_name = models.CharField(max_length=20)
    phone_number = models.CharField(max_length=20, unique=True, db_index=True)
    email = models.EmailField(max_length=100, unique=True, db_index=True)
    role = models.CharField(max_length=30, choices=Role.choices, default=Role.HOUSEHOLD)
    ward = models.ForeignKey('locations.Ward', on_delete=models.SET_NULL, 
                            null=True, blank=True, related_name='users')
    is_active = models.BooleanField(default=True)
    is_verified = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)
    last_login = models.DateTimeField(null=True, blank=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name', 'phone_number']

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return f"{self.get_full_name()} ({self.role})"

    def get_full_name(self):
        return f"{self.first_name} {self.last_name}"

    @property
    def is_admin(self):
        return self.role == self.Role.ADMIN

    @property
    def is_ward_officer(self):
        return self.role == self.Role.WARD_OFFICER

    @property
    def is_collector(self):
        return self.role == self.Role.COLLECTOR

    @property
    def is_driver(self):
        return self.role == self.Role.DRIVER

    @property
    def is_household_user(self):
        return self.role == self.Role.HOUSEHOLD
