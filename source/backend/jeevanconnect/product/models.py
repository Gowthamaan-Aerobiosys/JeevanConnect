from django.db import models
from django.utils import timezone
from datetime import timedelta
import random
import string

from authentication.models import Workspace

class VentilatorManager(models.Manager):
    def register(self, product_name=None, model_name=None, serial_number=None, lot_number=None, manufactured_on=None, workspace=None, 
                 software_version=None, battery_serial_number=None, battery_manufacturing_date=None, product_id='VEN'):
        if not product_name:
            raise ValueError('Product must have a Product name')
        if not model_name:
            raise ValueError('Product must have a Model name')
        if not serial_number:
            raise ValueError('Product must have a Serial number')
        if not lot_number:
            raise ValueError('Product must have a Lot number')
        if not manufactured_on:
            raise ValueError('Product must have a Manufacturing date')
        
        product = self.model(
            product_name=product_name,
            model_name=model_name,
            serial_number=serial_number,
            lot_number=lot_number,
            manufactured_on=manufactured_on,
            workspace=workspace,
            software_version=software_version,
            battery_serial_number=battery_serial_number,
            battery_manufacturing_date=battery_manufacturing_date,
            product_id=product_id
        )
        product.secret_key = self.get_secret_key()
        product.save(using=self._db)
        return product
    
    def get_secret_key(self):
        unique_id = ''.join(random.choices(string.ascii_uppercase + string.digits, k=10))
        return unique_id

class Ventilator(models.Model):
    class ActivityStatus(models.TextChoices):
        IDLE = 'ID', ('Idle')
        INUSE = 'IU', ('Active')
        REPAIR = 'RP', ('In Service')
    serial_number = models.CharField(verbose_name="Serial number", unique=True, primary_key=True, max_length=30)
    lot_number = models.CharField(max_length=100, null=False, blank=False)
    manufactured_on = models.DateTimeField(null=True)
    product_name = models.CharField(max_length=255, null=False, blank=False)
    model_name = models.CharField(max_length=255, null=False, blank=False)
    product_id = models.CharField(max_length=255, null=False, blank=False)
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name='ventilators', null=True, blank=True, default=None)
    secret_key = models.CharField(max_length=10, blank=False, null=False)

    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)
    
    active = models.BooleanField(default=True)    
    software_version = models.CharField(max_length=255, null=True, blank=True, default=None)
    battery_serial_number = models.CharField(max_length=255, null=True, blank=True, default=None)
    battery_manufacturing_date = models.DateTimeField(null=True, blank=True, default=None)

    status = models.CharField(max_length=2, choices=ActivityStatus.choices, default=ActivityStatus.IDLE)
    is_online = models.BooleanField(default=False)
    is_on_service = models.BooleanField(default=False)
    location = models.CharField(max_length=500, null=True, blank=False, default=None)
    department = models.CharField(null=True, blank=True, default=None)
    
    objects = VentilatorManager()
    
    class Meta:
        verbose_name_plural = "Ventilators"
        
    def __str__(self):              
        return self.serial_number
    
    @property
    def is_active(self):
        return self.active

class ServiceTicketManager(models.Manager):
    def create(self, ticket_id=None, ventilator=None):
        ticket = self.model(
            ticket_id = ticket_id,
            ventilator = ventilator
        )
        ticket.save(using=self._db)
        return ticket

class ServiceTicket(models.Model):
    class TicketStatus(models.TextChoices):
        BOOKED = 'BK', ('Booked')
        UNDERREVIEW = 'UR', ('Under review')
        INPROGRESS = 'IP', ('In progress')
        CLOSED = 'CL', ('Closed')
        DECLINED = 'DL', ('Declined')    
    
    ticket_id = models.CharField(max_length=100, unique=True, primary_key=True, null=False, blank=False)
    booked_on = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    status = models.CharField(max_length=2, choices=TicketStatus.choices, default=TicketStatus.BOOKED)
    ventilator = models.ForeignKey(Ventilator, on_delete=models.CASCADE, null=False,  related_name= "service_tickets")
 
    def __str__(self):
        return f"{self.ticket_id}-{self.status}"
    
    @classmethod
    def can_create_new_ticket(cls, ventilator):
        seven_days_ago = timezone.now() - timedelta(days=7)
        last_ticket = cls.objects.filter(ventilator=ventilator).order_by('-booked_on').first()
        if last_ticket is None:
            return True
        return last_ticket.booked_on <= seven_days_ago
    
class ServiceLog(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    content = models.CharField()
    service_ticket = models.ForeignKey(ServiceTicket, on_delete=models.CASCADE, related_name="logs")

    def __str__(self):
        return f"{self.service_ticket.ticket_id}-{self.content} at {self.created_at}"