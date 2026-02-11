from django.contrib import admin
from .models import GhostProfile, GhostSubscription, Room

@admin.register(GhostProfile)
class GhostProfileAdmin(admin.ModelAdmin):
    list_display = ('display_name', 'user', 'followers_count', 'is_active')
    search_fields = ('display_name', 'user__email')

@admin.register(GhostSubscription)
class GhostSubscriptionAdmin(admin.ModelAdmin):
    list_display = ('follower', 'target', 'created_at')

@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
    list_display = ('title', 'host', 'category', 'listeners_count', 'is_active', 'created_at')
    list_filter = ('category', 'is_active')
    search_fields = ('title', 'host__display_name')
