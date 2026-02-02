# Waste Management System - Django Project Plan

## 🎯 Project Overview
A comprehensive waste collection management system for Tanzania, handling household registrations, collection scheduling, payments, and complaints.

## 📁 Recommended Project Structure

```
waste_management/
├── config/                          # Project configuration
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py                 # Common settings
│   │   ├── development.py          # Dev settings
│   │   ├── production.py           # Production settings
│   │   └── testing.py              # Test settings
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
│
├── apps/                            # All Django apps (services)
│   ├── __init__.py
│   │
│   ├── core/                        # Core/shared functionality
│   │   ├── __init__.py
│   │   ├── models.py               # Abstract base models
│   │   ├── managers.py             # Custom model managers
│   │   ├── mixins.py               # Reusable mixins
│   │   ├── utils.py                # Utility functions
│   │   ├── validators.py           # Custom validators
│   │   └── templatetags/           # Custom template tags
│   │
│   ├── accounts/                    # User management
│   │   ├── __init__.py
│   │   ├── models.py               # User model
│   │   ├── forms.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── serializers.py          # If using DRF
│   │   ├── services.py             # Business logic layer
│   │   ├── selectors.py            # Database queries
│   │   ├── admin.py
│   │   ├── signals.py
│   │   ├── tests/
│   │   └── templates/accounts/
│   │
│   ├── locations/                   # Regions, Districts, Wards, Streets
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── forms.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── selectors.py
│   │   ├── admin.py
│   │   ├── tests/
│   │   └── templates/locations/
│   │
│   ├── households/                  # Household & Members management
│   │   ├── __init__.py
│   │   ├── models.py               # Household, HouseMember
│   │   ├── forms.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── selectors.py
│   │   ├── admin.py
│   │   ├── tests/
│   │   └── templates/households/
│   │
│   ├── collections/                 # Collection routes, schedules, sessions
│   │   ├── __init__.py
│   │   ├── models.py               # CollectionPoint, Route, Schedule, Session
│   │   ├── forms.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── selectors.py
│   │   ├── admin.py
│   │   ├── tests/
│   │   └── templates/collections/
│   │
│   ├── vehicles/                    # Vehicle management & tracking
│   │   ├── __init__.py
│   │   ├── models.py               # Vehicle, VehicleLocation
│   │   ├── forms.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── selectors.py
│   │   ├── admin.py
│   │   ├── tests/
│   │   └── templates/vehicles/
│   │
│   ├── payments/                    # Payment processing
│   │   ├── __init__.py
│   │   ├── models.py               # Payment, MoneyCollectorRecord
│   │   ├── forms.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── selectors.py
│   │   ├── admin.py
│   │   ├── tests/
│   │   └── templates/payments/
│   │
│   ├── complaints/                  # Complaint management
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── forms.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── selectors.py
│   │   ├── admin.py
│   │   ├── tests/
│   │   └── templates/complaints/
│   │
│   ├── notifications/               # Notification system
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── forms.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── selectors.py
│   │   ├── tasks.py                # Celery tasks
│   │   ├── admin.py
│   │   ├── tests/
│   │   └── templates/notifications/
│   │
│   └── analytics/                   # Activity logs & reporting
│       ├── __init__.py
│       ├── models.py               # ActivityLog
│       ├── views.py
│       ├── urls.py
│       ├── services.py
│       ├── selectors.py
│       ├── admin.py
│       ├── tests/
│       └── templates/analytics/
│
├── templates/                       # Global templates
│   ├── base.html
│   ├── home.html
│   ├── includes/
│   │   ├── navbar.html
│   │   ├── sidebar.html
│   │   ├── footer.html
│   │   └── messages.html
│   └── errors/
│       ├── 404.html
│       ├── 500.html
│       └── 403.html
│
├── static/                          # Static files
│   ├── css/
│   │   ├── main.css
│   │   └── admin.css
│   ├── js/
│   │   ├── main.js
│   │   └── utils.js
│   ├── images/
│   └── vendor/                     # Third-party assets
│
├── media/                           # User uploaded files
│   └── .gitkeep
│
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   ├── production.txt
│   └── testing.txt
│
├── scripts/                         # Management scripts
│   ├── seed_data.py
│   └── import_locations.py
│
├── docs/                            # Documentation
│   ├── api.md
│   ├── setup.md
│   └── deployment.md
│
├── .env.example
├── .gitignore
├── manage.py
├── README.md
└── requirements.txt
```

## 🏗️ Clean Architecture Layers

### 1. **Models Layer** (`models.py`)
- Define database schema
- Model methods for business rules
- Properties and validators

### 2. **Selectors Layer** (`selectors.py`)
- **READ operations only**
- Complex queries
- Data fetching logic
- Returns QuerySets or model instances

```python
# Example: apps/households/selectors.py
def get_household_by_id(*, household_id: int):
    return Household.objects.select_related('user', 'ward').get(id=household_id)

def get_households_for_ward(*, ward_id: int):
    return Household.objects.filter(ward_id=ward_id).select_related('user')
```

### 3. **Services Layer** (`services.py`)
- **WRITE operations** (Create, Update, Delete)
- Business logic
- Transaction handling
- Validation

```python
# Example: apps/households/services.py
from django.db import transaction

@transaction.atomic
def create_household(*, user_id: int, phone_number: str, house_number: int, 
                     ward_id: int, street_id: int = None):
    household = Household.objects.create(
        user_id=user_id,
        phone_number=phone_number,
        house_number=house_number,
        ward_id=ward_id,
        street_id=street_id
    )
    # Additional business logic here
    return household
```

### 4. **Views Layer** (`views.py`)
- Handle HTTP requests/responses
- Call selectors and services
- Render templates
- Form handling

### 5. **Forms Layer** (`forms.py`)
- User input validation
- Form rendering
- Clean methods

## 📋 Implementation Steps

### Phase 1: Project Setup (Week 1)
1. **Initialize Django project**
   ```bash
   django-admin startproject config .
   mkdir apps
   ```

2. **Configure settings structure**
   - Split settings into base, dev, production
   - Setup environment variables (.env)
   - Configure database (PostgreSQL)

3. **Setup version control**
   ```bash
   git init
   # Add .gitignore
   git add .
   git commit -m "Initial commit"
   ```

4. **Install dependencies**
   ```
   Django==4.2
   psycopg2-binary==2.9.9
   python-decouple==3.8
   django-crispy-forms==2.1
   crispy-bootstrap5==2.0.0
   Pillow==10.1.0
   celery==5.3.4
   redis==5.0.1
   ```

### Phase 2: Core Infrastructure (Week 1-2)
1. **Create core app**
   - Abstract base models (TimeStampedModel, SoftDeleteModel)
   - Custom user model
   - Utility functions
   - Template tags

2. **Setup authentication**
   - Custom user model with roles
   - Login/logout views
   - Registration flow
   - Password reset

3. **Create base templates**
   - base.html with Bootstrap 5
   - Navigation
   - Footer
   - Message display

### Phase 3: Location Management (Week 2)
1. **Create locations app**
   - Models: Region, District, Ward, Street
   - Admin interface
   - Import/seed scripts for Tanzania data
   - CRUD views (admin only)

### Phase 4: Household Management (Week 2-3)
1. **Create households app**
   - Household model
   - HouseMember model
   - Registration forms
   - Member management
   - Dashboard views

### Phase 5: Collection System (Week 3-4)
1. **Create collections app**
   - CollectionPoint model
   - CollectionRoute model
   - RouteStop model
   - CollectionSchedule model
   - CollectionSession model
   - Schedule management views
   - Route planning interface

2. **Create vehicles app**
   - Vehicle model
   - VehicleLocation model (for tracking)
   - Assignment system
   - Vehicle dashboard

### Phase 6: Payment System (Week 4)
1. **Create payments app**
   - Payment model
   - MoneyCollectorRecord model
   - Payment recording interface
   - Payment history
   - Receipt generation

### Phase 7: Complaints & Notifications (Week 5)
1. **Create complaints app**
   - Complaint model
   - Submission form
   - Resolution workflow
   - Status tracking

2. **Create notifications app**
   - Notification model
   - SMS/Email integration (later)
   - In-app notifications
   - Notification preferences

### Phase 8: Analytics & Reporting (Week 5-6)
1. **Create analytics app**
   - ActivityLog model
   - Dashboard with statistics
   - Reports (payments, collections, complaints)
   - Charts and visualizations

### Phase 9: Testing & Documentation (Week 6)
1. **Write tests**
   - Unit tests for services
   - Integration tests for views
   - Test coverage > 80%

2. **Documentation**
   - README.md
   - API documentation
   - Setup guide
   - User manual

### Phase 10: Deployment (Week 7)
1. **Production setup**
   - Configure production settings
   - Setup static files serving
   - Database migrations
   - Deploy to server (Heroku/DigitalOcean)

## 👥 User Roles & Permissions

```python
# apps/core/constants.py
class UserRole:
    ADMIN = 'admin'
    WARD_OFFICER = 'ward_officer'
    COLLECTOR = 'collector'
    DRIVER = 'driver'
    HOUSEHOLD = 'household'
    
    CHOICES = [
        (ADMIN, 'Administrator'),
        (WARD_OFFICER, 'Ward Officer'),
        (COLLECTOR, 'Money Collector'),
        (DRIVER, 'Driver'),
        (HOUSEHOLD, 'Household User'),
    ]
```

### Permission Matrix
| Feature | Admin | Ward Officer | Collector | Driver | Household |
|---------|-------|--------------|-----------|--------|-----------|
| Manage users | ✓ | ✓ (ward) | ✗ | ✗ | ✗ |
| Manage routes | ✓ | ✓ (ward) | ✗ | ✗ | ✗ |
| View schedules | ✓ | ✓ | ✓ | ✓ | ✓ (own) |
| Record payments | ✓ | ✓ | ✓ | ✗ | ✗ |
| Make payments | ✗ | ✗ | ✗ | ✗ | ✓ |
| File complaints | ✓ | ✓ | ✗ | ✗ | ✓ |
| Resolve complaints | ✓ | ✓ | ✗ | ✗ | ✗ |
| View analytics | ✓ | ✓ (ward) | ✗ | ✗ | ✗ |

## 🎨 Frontend Technology Stack

### Recommended:
- **Bootstrap 5** - Responsive design
- **HTMX** - Dynamic interactions without complex JS
- **Alpine.js** - Lightweight JS framework
- **Chart.js** - Data visualization
- **DataTables** - Interactive tables
- **Leaflet.js** - Maps for vehicle tracking (optional)

## 🔧 Key Django Packages

```txt
# Core
Django==4.2
psycopg2-binary==2.9.9

# Environment
python-decouple==3.8

# Forms & UI
django-crispy-forms==2.1
crispy-bootstrap5==2.0.0

# APIs (optional)
djangorestframework==3.14.0

# Background tasks
celery==5.3.4
redis==5.0.1

# File handling
Pillow==10.1.0

# Development
django-debug-toolbar==4.2.0
django-extensions==3.2.3

# Testing
pytest-django==4.7.0
coverage==7.3.3

# Production
gunicorn==21.2.0
whitenoise==6.6.0
```

## 📝 Best Practices

### 1. **Naming Conventions**
- Models: Singular, PascalCase (e.g., `Household`, `Payment`)
- Apps: Plural, lowercase (e.g., `households`, `payments`)
- URLs: Kebab-case (e.g., `/household-members/`)
- Variables: snake_case

### 2. **Service Pattern Example**
```python
# apps/payments/services.py
from django.db import transaction
from django.utils import timezone
from .models import Payment
from apps.notifications.services import send_payment_notification

@transaction.atomic
def record_payment(
    *,
    household_id: int,
    amount: int,
    payment_method: str,
    collected_by_id: int
) -> Payment:
    """
    Record a new payment for a household.
    
    Args:
        household_id: ID of the household making payment
        amount: Payment amount
        payment_method: Method of payment (cash, mobile, etc.)
        collected_by_id: User ID of collector
    
    Returns:
        Payment: Created payment instance
    """
    payment = Payment.objects.create(
        household_id=household_id,
        amount=amount,
        payment_date=timezone.now(),
        payment_method=payment_method,
        status='completed',
        collected_by_id=collected_by_id
    )
    
    # Send notification
    send_payment_notification(payment_id=payment.id)
    
    return payment
```

### 3. **Selector Pattern Example**
```python
# apps/payments/selectors.py
from django.db.models import Sum, Count, Q
from .models import Payment

def get_household_payment_history(*, household_id: int):
    """Get all payments for a household."""
    return Payment.objects.filter(
        household_id=household_id
    ).select_related('collected_by').order_by('-payment_date')

def get_payment_statistics(*, ward_id: int = None, year: int = None):
    """Get payment statistics for analytics."""
    queryset = Payment.objects.filter(status='completed')
    
    if ward_id:
        queryset = queryset.filter(household__ward_id=ward_id)
    if year:
        queryset = queryset.filter(payment_date__year=year)
    
    return queryset.aggregate(
        total_amount=Sum('amount'),
        total_payments=Count('id')
    )
```

## 🚀 Getting Started Commands

```bash
# Create project
django-admin startproject config .

# Create apps structure
mkdir apps
python manage.py startapp core apps/core
python manage.py startapp accounts apps/accounts
python manage.py startapp locations apps/locations
python manage.py startapp households apps/households
python manage.py startapp collections apps/collections
python manage.py startapp vehicles apps/vehicles
python manage.py startapp payments apps/payments
python manage.py startapp complaints apps/complaints
python manage.py startapp notifications apps/notifications
python manage.py startapp analytics apps/analytics

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

## 📊 Database Considerations

1. **Indexes**: Add indexes to frequently queried fields
   ```python
   class Household(models.Model):
       phone_number = models.CharField(max_length=20, db_index=True)
       ward = models.ForeignKey('locations.Ward', db_index=True)
   ```

2. **Soft Deletes**: Implement for important records
   ```python
   class SoftDeleteModel(models.Model):
       is_deleted = models.BooleanField(default=False)
       deleted_at = models.DateTimeField(null=True, blank=True)
       
       class Meta:
           abstract = True
   ```

3. **Timestamps**: Add to all models
   ```python
   class TimeStampedModel(models.Model):
       created_at = models.DateTimeField(auto_now_add=True)
       updated_at = models.DateTimeField(auto_now=True)
       
       class Meta:
           abstract = True
   ```

## 🎯 Success Metrics

- [ ] All 9 apps created with proper structure
- [ ] All models migrated successfully
- [ ] User authentication working
- [ ] CRUD operations for all entities
- [ ] Role-based access control implemented
- [ ] Responsive UI with Bootstrap
- [ ] Payment recording functional
- [ ] Collection scheduling working
- [ ] Complaint system operational
- [ ] Basic analytics dashboard
- [ ] Test coverage > 70%
- [ ] Documentation complete
- [ ] Deployed and accessible

## 🤝 Sharing with Classmates

### Repository Setup
1. Create GitHub repository
2. Add comprehensive README
3. Include setup instructions
4. Add sample data fixtures
5. Document API endpoints
6. Add screenshots

### Presentation Topics
1. Clean architecture benefits
2. Service/Selector pattern
3. Django best practices
4. Role-based permissions
5. Testing strategies
6. Deployment process

Good luck with your project! 🚀
