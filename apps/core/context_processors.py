def user_info(request):
    """
    Returns global context for the template engine.
    """
    return {
        'project_name': 'Takataka Waste Management',
    }




##A context processor is a function that automatically injects variables into every template context.