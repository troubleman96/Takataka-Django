# Code Templates & Examples

## 1. Abstract Base Models (apps/core/models.py)

```python
from django.db import models
from django.utils import timezone


class TimeStampedModel(models.Model):
    """
    Abstract base model with created_at and updated_at timestamps.
    """
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
        ordering = ['-created_at']


class SoftDeleteModel(models.Model):
    """
    Abstract base model for soft delete functionality.
    """
    is_deleted = models.BooleanField(default=False, db_index=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        abstract = True

    def delete(self, using=None, keep_parents=False, soft=True):
        """
        Soft delete by default. Use soft=False for hard delete.
        """
        if soft:
            self.is_deleted = True
            self.deleted_at = timezone.now()
            self.save()
        else:
            super().delete(using=using, keep_parents=keep_parents)

    def restore(self):
        """
        Restore a soft-deleted instance.
        """
        self.is_deleted = False
        self.deleted_at = None
        self.save()


class SoftDeleteManager(models.Manager):
    """
    Manager that excludes soft-deleted objects by default.
    """
    def get_queryset(self):
        return super().get_queryset().filter(is_deleted=False)

    def all_with_deleted(self):
        return super().get_queryset()

    def deleted_only(self):
        return super().get_queryset().filter(is_deleted=True)
```

## 2. Custom User Model (apps/accounts/models.py)

```python
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
```

## 3. User Manager (apps/accounts/managers.py)

```python
from django.contrib.auth.models import BaseUserManager


class UserManager(BaseUserManager):
    """
    Custom manager for User model.
    """
    
    def create_user(self, email, password=None, **extra_fields):
        """
        Create and save a regular user.
        """
        if not email:
            raise ValueError('Users must have an email address')
        
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        """
        Create and save a superuser.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('is_verified', True)
        extra_fields.setdefault('role', 'admin')

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)
```

## 4. Example Service (apps/households/services.py)

```python
from django.db import transaction
from django.core.exceptions import ValidationError
from .models import Household, HouseMember
from apps.accounts.selectors import get_user_by_id
from apps.locations.selectors import get_ward_by_id


@transaction.atomic
def create_household(
    *,
    user_id: int,
    phone_number: str,
    house_number: int,
    ward_id: int,
    street_id: int = None
) -> Household:
    """
    Create a new household.
    
    Args:
        user_id: ID of the user creating the household
        phone_number: Contact phone number
        house_number: House number
        ward_id: Ward ID
        street_id: Street ID (optional)
    
    Returns:
        Household: Created household instance
        
    Raises:
        ValidationError: If validation fails
    """
    # Validate user exists
    user = get_user_by_id(user_id=user_id)
    
    # Validate ward exists
    ward = get_ward_by_id(ward_id=ward_id)
    
    # Check if household already exists for this user
    if Household.objects.filter(user_id=user_id).exists():
        raise ValidationError("User already has a household registered")
    
    # Create household
    household = Household.objects.create(
        user=user,
        phone_number=phone_number,
        house_number=house_number,
        ward=ward,
        street_id=street_id
    )
    
    return household


@transaction.atomic
def add_house_member(
    *,
    household_id: int,
    full_name: str,
    date_of_birth: str = None,
    gender: str = None,
    relationship: str,
    created_by_id: int
) -> HouseMember:
    """
    Add a member to a household.
    
    Args:
        household_id: ID of the household
        full_name: Full name of the member
        date_of_birth: Date of birth (optional)
        gender: Gender (optional)
        relationship: Relationship to household head
        created_by_id: ID of user creating the record
    
    Returns:
        HouseMember: Created house member instance
    """
    from .selectors import get_household_by_id
    
    # Validate household exists
    household = get_household_by_id(household_id=household_id)
    
    # Create house member
    member = HouseMember.objects.create(
        household=household,
        full_name=full_name,
        date_of_birth=date_of_birth,
        gender=gender,
        relationship=relationship,
        created_by_id=created_by_id
    )
    
    return member


@transaction.atomic
def update_household(
    *,
    household_id: int,
    phone_number: str = None,
    house_number: int = None,
    ward_id: int = None,
    street_id: int = None
) -> Household:
    """
    Update household information.
    
    Args:
        household_id: ID of the household to update
        phone_number: New phone number (optional)
        house_number: New house number (optional)
        ward_id: New ward ID (optional)
        street_id: New street ID (optional)
    
    Returns:
        Household: Updated household instance
    """
    from .selectors import get_household_by_id
    
    household = get_household_by_id(household_id=household_id)
    
    if phone_number is not None:
        household.phone_number = phone_number
    if house_number is not None:
        household.house_number = house_number
    if ward_id is not None:
        household.ward_id = ward_id
    if street_id is not None:
        household.street_id = street_id
    
    household.save()
    return household
```

## 5. Example Selector (apps/households/selectors.py)

```python
from django.core.exceptions import ObjectDoesNotExist
from django.db.models import QuerySet, Prefetch
from .models import Household, HouseMember


def get_household_by_id(*, household_id: int) -> Household:
    """
    Get a household by ID with related data.
    
    Args:
        household_id: ID of the household
    
    Returns:
        Household: Household instance
        
    Raises:
        ObjectDoesNotExist: If household not found
    """
    try:
        return Household.objects.select_related(
            'user', 'ward', 'street'
        ).get(id=household_id)
    except Household.DoesNotExist:
        raise ObjectDoesNotExist(f"Household with id {household_id} not found")


def get_households_for_ward(*, ward_id: int) -> QuerySet[Household]:
    """
    Get all households in a specific ward.
    
    Args:
        ward_id: ID of the ward
    
    Returns:
        QuerySet: Households in the ward
    """
    return Household.objects.filter(
        ward_id=ward_id
    ).select_related('user', 'ward', 'street').order_by('house_number')


def get_household_with_members(*, household_id: int) -> Household:
    """
    Get a household with all its members.
    
    Args:
        household_id: ID of the household
    
    Returns:
        Household: Household instance with prefetched members
    """
    return Household.objects.prefetch_related(
        Prefetch(
            'house_members',
            queryset=HouseMember.objects.select_related('created_by')
        )
    ).select_related('user', 'ward', 'street').get(id=household_id)


def get_user_households(*, user_id: int) -> QuerySet[Household]:
    """
    Get all households owned by a user.
    
    Args:
        user_id: ID of the user
    
    Returns:
        QuerySet: User's households
    """
    return Household.objects.filter(
        user_id=user_id
    ).select_related('ward', 'street')


def search_households(
    *,
    query: str = None,
    ward_id: int = None,
    street_id: int = None
) -> QuerySet[Household]:
    """
    Search households with filters.
    
    Args:
        query: Search query (name, phone)
        ward_id: Filter by ward
        street_id: Filter by street
    
    Returns:
        QuerySet: Filtered households
    """
    queryset = Household.objects.select_related('user', 'ward', 'street')
    
    if query:
        queryset = queryset.filter(
            models.Q(user__first_name__icontains=query) |
            models.Q(user__last_name__icontains=query) |
            models.Q(phone_number__icontains=query)
        )
    
    if ward_id:
        queryset = queryset.filter(ward_id=ward_id)
    
    if street_id:
        queryset = queryset.filter(street_id=street_id)
    
    return queryset.order_by('-created_at')
```

## 6. Example View (apps/households/views.py)

```python
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.paginator import Paginator
from django.http import JsonResponse

from .forms import HouseholdForm, HouseMemberForm
from .services import create_household, add_house_member, update_household
from .selectors import (
    get_household_by_id,
    get_households_for_ward,
    get_household_with_members,
    search_households
)


@login_required
def household_list(request):
    """
    List all households (with filters).
    """
    # Get filter parameters
    ward_id = request.GET.get('ward')
    search_query = request.GET.get('q')
    
    # Get households based on user role
    if request.user.is_admin:
        households = search_households(
            query=search_query,
            ward_id=ward_id
        )
    elif request.user.is_ward_officer:
        households = get_households_for_ward(ward_id=request.user.ward_id)
        if search_query:
            households = households.filter(
                user__first_name__icontains=search_query
            )
    else:
        # Regular household user sees only their own
        households = Household.objects.filter(user=request.user)
    
    # Pagination
    paginator = Paginator(households, 20)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'page_obj': page_obj,
        'search_query': search_query,
        'selected_ward': ward_id,
    }
    return render(request, 'households/household_list.html', context)


@login_required
def household_detail(request, household_id):
    """
    View household details with members.
    """
    try:
        household = get_household_with_members(household_id=household_id)
        
        # Check permissions
        if not request.user.is_admin and not request.user.is_ward_officer:
            if household.user != request.user:
                messages.error(request, "You don't have permission to view this household")
                return redirect('households:list')
        
        context = {
            'household': household,
        }
        return render(request, 'households/household_detail.html', context)
    
    except ObjectDoesNotExist:
        messages.error(request, "Household not found")
        return redirect('households:list')


@login_required
def household_create(request):
    """
    Create a new household.
    """
    if request.method == 'POST':
        form = HouseholdForm(request.POST)
        if form.is_valid():
            try:
                household = create_household(
                    user_id=request.user.id,
                    phone_number=form.cleaned_data['phone_number'],
                    house_number=form.cleaned_data['house_number'],
                    ward_id=form.cleaned_data['ward'].id,
                    street_id=form.cleaned_data.get('street').id if form.cleaned_data.get('street') else None
                )
                messages.success(request, "Household created successfully!")
                return redirect('households:detail', household_id=household.id)
            except ValidationError as e:
                messages.error(request, str(e))
    else:
        form = HouseholdForm()
    
    context = {'form': form}
    return render(request, 'households/household_form.html', context)


@login_required
def household_update(request, household_id):
    """
    Update household information.
    """
    try:
        household = get_household_by_id(household_id=household_id)
        
        # Check permissions
        if household.user != request.user and not request.user.is_admin:
            messages.error(request, "You don't have permission to edit this household")
            return redirect('households:detail', household_id=household_id)
        
        if request.method == 'POST':
            form = HouseholdForm(request.POST, instance=household)
            if form.is_valid():
                updated_household = update_household(
                    household_id=household_id,
                    phone_number=form.cleaned_data['phone_number'],
                    house_number=form.cleaned_data['house_number'],
                    ward_id=form.cleaned_data['ward'].id,
                    street_id=form.cleaned_data.get('street').id if form.cleaned_data.get('street') else None
                )
                messages.success(request, "Household updated successfully!")
                return redirect('households:detail', household_id=updated_household.id)
        else:
            form = HouseholdForm(instance=household)
        
        context = {
            'form': form,
            'household': household
        }
        return render(request, 'households/household_form.html', context)
    
    except ObjectDoesNotExist:
        messages.error(request, "Household not found")
        return redirect('households:list')


@login_required
def add_member(request, household_id):
    """
    Add a member to a household.
    """
    try:
        household = get_household_by_id(household_id=household_id)
        
        # Check permissions
        if household.user != request.user and not request.user.is_admin:
            messages.error(request, "You don't have permission to add members to this household")
            return redirect('households:detail', household_id=household_id)
        
        if request.method == 'POST':
            form = HouseMemberForm(request.POST)
            if form.is_valid():
                member = add_house_member(
                    household_id=household_id,
                    full_name=form.cleaned_data['full_name'],
                    date_of_birth=form.cleaned_data.get('date_of_birth'),
                    gender=form.cleaned_data.get('gender'),
                    relationship=form.cleaned_data['relationship'],
                    created_by_id=request.user.id
                )
                messages.success(request, f"{member.full_name} added to household!")
                return redirect('households:detail', household_id=household_id)
        else:
            form = HouseMemberForm()
        
        context = {
            'form': form,
            'household': household
        }
        return render(request, 'households/member_form.html', context)
    
    except ObjectDoesNotExist:
        messages.error(request, "Household not found")
        return redirect('households:list')
```

## 7. Example Form (apps/households/forms.py)

```python
from django import forms
from django.core.exceptions import ValidationError
from .models import Household, HouseMember
from apps.locations.models import Ward, Street


class HouseholdForm(forms.ModelForm):
    """
    Form for creating/updating households.
    """
    ward = forms.ModelChoiceField(
        queryset=Ward.objects.all(),
        empty_label="Select Ward",
        widget=forms.Select(attrs={'class': 'form-select'})
    )
    
    street = forms.ModelChoiceField(
        queryset=Street.objects.all(),
        required=False,
        empty_label="Select Street (Optional)",
        widget=forms.Select(attrs={'class': 'form-select'})
    )
    
    class Meta:
        model = Household
        fields = ['phone_number', 'house_number', 'ward', 'street']
        widgets = {
            'phone_number': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'e.g., +255712345678'
            }),
            'house_number': forms.NumberInput(attrs={
                'class': 'form-control',
                'placeholder': 'House Number'
            }),
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        # Filter streets based on selected ward (using JavaScript)
        if 'ward' in self.data:
            try:
                ward_id = int(self.data.get('ward'))
                self.fields['street'].queryset = Street.objects.filter(
                    ward_id=ward_id
                ).order_by('name')
            except (ValueError, TypeError):
                pass
        elif self.instance.pk:
            self.fields['street'].queryset = Street.objects.filter(
                ward=self.instance.ward
            ).order_by('name')
    
    def clean_phone_number(self):
        phone = self.cleaned_data.get('phone_number')
        # Add phone validation logic
        if not phone.startswith('+255') and not phone.startswith('0'):
            raise ValidationError("Phone number must start with +255 or 0")
        return phone


class HouseMemberForm(forms.ModelForm):
    """
    Form for adding household members.
    """
    
    class Meta:
        model = HouseMember
        fields = ['full_name', 'date_of_birth', 'gender', 'relationship']
        widgets = {
            'full_name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'Full Name'
            }),
            'date_of_birth': forms.DateInput(attrs={
                'class': 'form-control',
                'type': 'date'
            }),
            'gender': forms.Select(attrs={'class': 'form-select'}),
            'relationship': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'e.g., Spouse, Child, Parent'
            }),
        }
```

## 8. Example URLs (apps/households/urls.py)

```python
from django.urls import path
from . import views

app_name = 'households'

urlpatterns = [
    path('', views.household_list, name='list'),
    path('create/', views.household_create, name='create'),
    path('<int:household_id>/', views.household_detail, name='detail'),
    path('<int:household_id>/edit/', views.household_update, name='update'),
    path('<int:household_id>/add-member/', views.add_member, name='add_member'),
]
```

## 9. Middleware Example (apps/core/middleware.py)

```python
from django.utils import timezone
from apps.analytics.services import log_activity


class ActivityLogMiddleware:
    """
    Middleware to log user activities.
    """
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        response = self.get_response(request)
        
        # Log activity for authenticated users
        if request.user.is_authenticated and request.method in ['POST', 'PUT', 'PATCH', 'DELETE']:
            # Extract relevant info
            action = f"{request.method} {request.path}"
            
            # Log asynchronously (use Celery in production)
            try:
                log_activity(
                    user_id=request.user.id,
                    action=action,
                    ip_address=self.get_client_ip(request),
                    user_agent=request.META.get('HTTP_USER_AGENT', '')
                )
            except Exception:
                # Don't let logging errors break the request
                pass
        
        return response
    
    def get_client_ip(self, request):
        """Get the client's IP address."""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
```

These templates provide a solid foundation for building your clean architecture Django application!
