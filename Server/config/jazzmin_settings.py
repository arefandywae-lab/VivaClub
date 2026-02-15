# Django Jazzmin Configuration
# Add to Server/config/settings.py

# Install: pip install django-jazzmin

INSTALLED_APPS = [
    'jazzmin',  # Must be before django.contrib.admin
    'django.contrib.admin',
    'django.contrib.auth',
    # ... rest of your apps
]

JAZZMIN_SETTINGS = {
    # Title
    "site_title": "VivaClub Admin",
    "site_header": "VivaClub",
    "site_brand": "VivaClub Administration",
    "site_logo": None,  # Add logo path if you have one
    "login_logo": None,
    "site_icon": None,
    
    # Welcome text
    "welcome_sign": "Welcome to VivaClub Admin Panel",
    
    # Copyright
    "copyright": "VivaClub",
    
    # Search model
    "search_model": "auth.User",
    
    # Top Menu
    "topmenu_links": [
        {"name": "Home", "url": "admin:index", "permissions": ["auth.view_user"]},
        {"name": "Support", "url": "https://github.com/yourusername/vivaclub/issues", "new_window": True},
        {"model": "auth.User"},
        {"app": "community"},
    ],
    
    # User menu
    "usermenu_links": [
        {"model": "auth.user"}
    ],
    
    # Side Menu
    "show_sidebar": True,
    "navigation_expanded": True,
    "hide_apps": [],
    "hide_models": [],
    
    # Custom icons for apps/models
    "icons": {
        "auth": "fas fa-users-cog",
        "auth.user": "fas fa-user",
        "auth.Group": "fas fa-users",
        "community.ghostprofile": "fas fa-user-secret",
        "community.room": "fas fa-door-open",
        "community.ghostsubscription": "fas fa-user-plus",
    },
    
    # Default icon for models
    "default_icon_parents": "fas fa-chevron-circle-right",
    "default_icon_children": "fas fa-circle",
    
    # Related modal
    "related_modal_active": False,
    
    # Custom CSS/JS
    "custom_css": None,
    "custom_js": None,
    
    # Show language chooser
    "show_ui_builder": False,
    
    # Change view
    "changeform_format": "horizontal_tabs",
    "changeform_format_overrides": {
        "auth.user": "collapsible",
        "auth.group": "vertical_tabs"
    },
    
    # Theme
    "theme": "flatly",  # Options: default, darkly, flatly, journal, litera, lux, materia, minty, pulse, sandstone, simplex, slate, solar, spacelab, superhero, united, yeti
}

JAZZMIN_UI_TWEAKS = {
    "navbar_small_text": False,
    "footer_small_text": False,
    "body_small_text": False,
    "brand_small_text": False,
    "brand_colour": "navbar-primary",
    "accent": "accent-primary",
    "navbar": "navbar-dark",
    "no_navbar_border": False,
    "navbar_fixed": False,
    "layout_boxed": False,
    "footer_fixed": False,
    "sidebar_fixed": False,
    "sidebar": "sidebar-dark-primary",
    "sidebar_nav_small_text": False,
    "sidebar_disable_expand": False,
    "sidebar_nav_child_indent": False,
    "sidebar_nav_compact_style": False,
    "sidebar_nav_legacy_style": False,
    "sidebar_nav_flat_style": False,
    "theme": "flatly",
    "dark_mode_theme": None,
    "button_classes": {
        "primary": "btn-primary",
        "secondary": "btn-secondary",
        "info": "btn-info",
        "warning": "btn-warning",
        "danger": "btn-danger",
        "success": "btn-success"
    }
}
