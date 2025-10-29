from django.contrib import admin

from .models import Ventilator, ServiceTicket

class VentilatorAdmin(admin.ModelAdmin):
    def has_change_permission(self, request, obj=None):
        return False    
    
    list_display = ('serial_number', 'product_name', 'model_name', 'product_id', 'status','active',)
    fieldsets = (
        ('Product', {'fields': ('serial_number', 'lot_number', 'product_name', 'model_name', 'manufactured_on', 'workspace', 'secret_key',)}),
        ('Status', {'fields': ('active', 'software_version', 'status', 'is_online', 'is_on_service', 'location', 'department',)}),
        ('Peripherals', {'fields': ('battery_serial_number', 'battery_manufacturing_date')}),
    )
    search_fields = ('serial_number',)
    ordering = ('serial_number',)
    filter_horizontal = ()
    
admin.site.register(Ventilator, VentilatorAdmin)
admin.site.register(ServiceTicket)