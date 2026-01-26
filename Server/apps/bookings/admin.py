from django.contrib import admin
from .models import AppointmentSlot, BookingTransaction

@admin.register(AppointmentSlot)
class AppointmentSlotAdmin(admin.ModelAdmin):
    list_display = ('id', 'doctor', 'start_time', 'status', 'patient', 'cost')
    list_filter = ('status', 'start_time')
    search_fields = ('doctor__username', 'patient__username')

@admin.register(BookingTransaction)
class BookingTransactionAdmin(admin.ModelAdmin):
    list_display = ('id', 'patient', 'amount', 'payment_status', 'created_at')
    list_filter = ('payment_status',)
