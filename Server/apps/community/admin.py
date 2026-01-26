from django.contrib import admin
from .models import GhostProfile, GhostSubscription

@admin.register(GhostProfile)
class GhostProfileAdmin(admin.ModelAdmin):
    list_display = ('display_name', 'user', 'followers_count', 'is_active')
    search_fields = ('display_name', 'user__username')

@admin.register(GhostSubscription)
class GhostSubscriptionAdmin(admin.ModelAdmin):
    list_display = ('follower', 'target', 'created_at')
