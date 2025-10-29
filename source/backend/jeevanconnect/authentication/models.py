from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.contrib.auth.models import (BaseUserManager, AbstractBaseUser)
import random
import string
    
class UserManager(BaseUserManager):
    def create_user(self, email, password=None, first_name=None, last_name=None, designation=None, registered_id=None, contact=None):
        if not email:
            raise ValueError('Users must have an email address')
        if not password:
            raise ValueError('Users must have an password')
        if not first_name:
            raise ValueError('Users must have an first name')
        if not last_name:
            raise ValueError('Users must have an last name')
        if not designation:
            raise ValueError('Users must have an designation')
        if not registered_id:
            raise ValueError('Users must have an registered id')
        user = self.model(
            email=self.normalize_email(email),
            first_name = first_name,
            last_name = last_name,
            designation = designation,
            registered_id = registered_id,
            contact = contact
        )
        user.set_password(password)   
        user.user_id = self.get_user_id()
        user.emails.append(email)
        user.phone_numbers.append(contact)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password, first_name, last_name, designation, registered_id, contact):
        user = self.create_user(email,password=password, first_name=first_name, last_name=last_name,
                                designation=designation, registered_id=registered_id)
        user.admin = True
        user.confirmed = True
        user.save(using=self._db)
        return user
    
    def get_user_id(self):
        while True:
            unique_number = str(random.randint(1000000000, 9999999999))
            if not self.filter(user_id=unique_number).exists():
                return unique_number
            
class User(AbstractBaseUser):
    
    email = models.EmailField(verbose_name='email address', max_length=255)
    user_id = models.CharField(max_length=10, unique=True)
    admin = models.BooleanField(default=False)
    confirmed = models.BooleanField(default=False)
    
    active = models.BooleanField(default=True)
    first_name = models.CharField(max_length=255, null=True)
    last_name = models.CharField(max_length=255, null=True)
    designation = models.CharField(max_length=255, null=True, blank=True)
    registered_id = models.CharField(max_length=15, null=True, blank=True, unique=True)
    contact = models.BigIntegerField(null=True, blank=True)
    
    emails = ArrayField(models.EmailField(), blank=True, default=list)
    phone_numbers = ArrayField(models.CharField(max_length=20), blank=True, default=list)
    
    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)
    password_changed_at = models.DateTimeField(null=True, blank=True)
    
    USERNAME_FIELD = 'user_id'
    REQUIRED_FIELDS = ['first_name','last_name', 'designation', 'registered_id']

    objects = UserManager()

    def get_full_name(self):
        return self.first_name+" "+self.last_name

    def get_short_name(self):
        return self.email

    def __str__(self):
        return self.get_short_name()
    
    def has_perm(self, perm, obj=None):
        return self.is_staff

    def has_module_perms(self, app_label):
        return self.is_staff

    @property
    def is_staff(self):
        return self.admin
    
    @property
    def is_confirmed(self):
        return self.confirmed
    
    @property
    def is_active(self):
        return self.active


class WorkspaceManager(models.Manager):
    def create_workspace(self, name=None, registered_id= None, email=None, user=None, street_address=None, city=None, 
                         state=None, postal_code=None, website=None, contact=None, country=None):
        if not name:
            raise ValueError('Workspace must have an name')
    
        workspace = self.model(
            name=name, 
            registered_id = registered_id,
            default_user = user,
            email_id = email,
            street_address = street_address,
            city = city,
            state = state,
            postal_code = postal_code,
            website = website,
            contact = contact,
            country = country
            )
        workspace.workspace_id = self.get_workspace_id()
        workspace.save(using=self._db)
        workspace.admins.add(user)
        workspace.users.add(user)
        workspace.save(using=self._db)
        return workspace

    def get_workspace_id(self):
        while True:
            unique_id = ''.join(random.choices(string.ascii_uppercase + string.digits, k=10))
            if not self.filter(workspace_id=unique_id).exists():
                return unique_id

class Workspace(models.Model):
    name = models.CharField(max_length=255, blank=False, null=False)
    workspace_id = models.CharField(max_length=10, blank=False, null=False, primary_key=True, unique=True)
    registered_id = models.CharField(blank=False, null=False, unique=True)
    email_id = models.EmailField(blank=True, null=True, default=None)
    street_address = models.CharField(max_length=255)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    country = models.CharField(max_length=100)
    postal_code = models.CharField(max_length=20)
    website = models.URLField(blank=True, null=True, default=None)
    contact = models.CharField(blank=True, null=True, default=None)
    
    confirmed = models.BooleanField(default=False)
    active = models.BooleanField(default=False)
    archive = models.BooleanField(default=False)
    
    departments = ArrayField(models.CharField(), blank=True, default=list)
    
    default_user = models.ForeignKey(User, on_delete=models.DO_NOTHING, null=False, blank=False)
    users = models.ManyToManyField(User, related_name='users', blank=True)
    admins = models.ManyToManyField(User, related_name='admins', blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)
    
    REQUIRED_FIELDS = ['name','default_user']
    
    objects = WorkspaceManager()

    def __str__(self):
        return self.name
    
    @property
    def is_confirmed(self):
        return self.confirmed
    
    @property
    def is_active(self):
        return self.active
    
    property
    def full_address(self):
        return f"{self.street_address}, {self.city}, {self.state} {self.postal_code}, {self.country}"


class LoginInfo(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="sessions")
    session_key = models.CharField(max_length=40, null=True, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.CharField(max_length=255, null=True, blank=True)
    device_type = models.CharField(max_length=50, null=True, blank=True)
    browser = models.CharField(max_length=50, null=True, blank=True)
    os = models.CharField(max_length=50, null=True, blank=True)
    country = models.CharField(max_length=50, null=True, blank=True)
    city = models.CharField(max_length=50, null=True, blank=True)
    login_time = models.DateTimeField(auto_now_add=True)
    logout_time = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    modified_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.get_full_name()} - {self.login_time}"


class WorkspaceModeration(models.Model):
    class Permission(models.TextChoices):
        ADMIN = 'AD', ('ADMIN')
        ANYONE = 'AN', ('ANYONE')     
        OWNER = 'OW', ('OWNER')     
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, null=False, blank=False)
    invite_member = models.CharField(max_length=2, choices=Permission.choices, default=Permission.OWNER)
    edit_department = models.CharField(max_length=2, choices=Permission.choices, default=Permission.OWNER)
    add_patient = models.CharField(max_length=2, choices=Permission.choices, default=Permission.ADMIN)
    edit_product = models.CharField(max_length=2, choices=Permission.choices, default=Permission.ADMIN)
    download_information = models.CharField(max_length=2, choices=Permission.choices, default=Permission.ANYONE)
    workspace_details = models.CharField(max_length=2, choices=Permission.choices, default=Permission.ANYONE)
    share_device = models.CharField(max_length=2, choices=Permission.choices, default=Permission.ADMIN)
    modified_at = models.DateTimeField(auto_now=True)


class Announcement(models.Model):
    workspace = models.ForeignKey(Workspace, on_delete=models.CASCADE, related_name="announcements")
    content = models.TextField(null=False, blank=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Announcement for {self.workspace.name} at {self.created_at}"