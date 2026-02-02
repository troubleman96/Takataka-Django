from django.utils import timezone
# from apps.analytics.services import log_activity # Delayed until analytics app is ready


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
            
            # Log asynchronously (future implementation with Celery)
            # try:
            #     log_activity(
            #         user_id=request.user.id,
            #         action=action,
            #         ip_address=self.get_client_ip(request),
            #         user_agent=request.META.get('HTTP_USER_AGENT', '')
            #     )
            # except Exception:
            #     pass
        
        return response
    
    def get_client_ip(self, request):
        """Get the client's IP address."""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
