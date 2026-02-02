from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout, update_session_auth_hash
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .forms import UserLoginForm, UserRegisterForm, ProfileUpdateForm, PasswordChangeForm
from .services import user_create, user_update, user_change_password
from .selectors import user_get_login_data


def register_view(request):
    """
    Handle user registration.
    """
    if request.method == 'POST':
        form = UserRegisterForm(request.POST)
        if form.is_valid():
            user = user_create(
                email=form.cleaned_data['email'],
                phone_number=form.cleaned_data['phone_number'],
                first_name=form.cleaned_data['first_name'],
                last_name=form.cleaned_data['last_name'],
                password=form.cleaned_data['password']
            )
            messages.success(request, "Registration successful. Please login.")
            return redirect('accounts:login')
    else:
        form = UserRegisterForm()
    return render(request, 'accounts/register.html', {'form': form})


def login_view(request):
    """
    Handle user login via phone number.
    """
    if request.method == 'POST':
        form = UserLoginForm(request.POST)
        if form.is_valid():
            phone_number = form.cleaned_data['phone_number']
            password = form.cleaned_data['password']
            
            # Get user by phone number
            user = user_get_login_data(phone_number=phone_number)
            if user:
                # Authenticate using email and password (Django default)
                authenticated_user = authenticate(request, email=user.email, password=password)
                if authenticated_user:
                    login(request, authenticated_user)
                    messages.success(request, f"Welcome back, {user.first_name}!")
                    return redirect('home')
            
            messages.error(request, "Invalid phone number or password.")
    else:
        form = UserLoginForm()
    return render(request, 'accounts/login.html', {'form': form})


@login_required
def logout_view(request):
    """
    Handle user logout.
    """
    logout(request)
    messages.info(request, "You have been logged out.")
    return redirect('accounts:login')


@login_required
def profile_view(request):
    """
    Handle user profile viewing and update.
    """
    if request.method == 'POST':
        form = ProfileUpdateForm(request.POST, instance=request.user)
        if form.is_valid():
            user_update(user=request.user, **form.cleaned_data)
            messages.success(request, "Profile updated successfully.")
            return redirect('accounts:profile')
    else:
        form = ProfileUpdateForm(instance=request.user)
    return render(request, 'accounts/profile.html', {'form': form})


@login_required
def change_password_view(request):
    """
    Handle password change.
    """
    if request.method == 'POST':
        form = PasswordChangeForm(request.POST)
        if form.is_valid():
            if request.user.check_password(form.cleaned_data['old_password']):
                user_change_password(user=request.user, new_password=form.cleaned_data['new_password'])
                update_session_auth_hash(request, request.user)
                messages.success(request, "Password changed successfully.")
                return redirect('accounts:profile')
            else:
                messages.error(request, "Incorrect old password.")
    else:
        form = PasswordChangeForm()
    return render(request, 'accounts/change_password.html', {'form': form})
