from django.contrib import admin
from django.contrib.sessions.models import Session
from django.utils import timezone

from django.contrib.auth.models import Group
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from django.utils.translation import gettext_lazy

from .models import User, Workspace, LoginInfo, WorkspaceModeration, Announcement

admin.site.site_title = gettext_lazy('Jeevan Connect admin')
admin.site.site_header = gettext_lazy('Jeevan Connect administration')
admin.site.index_title = gettext_lazy('Jeevan Connect Admin')

class Workspaces(admin.TabularInline):
    model = User.users.through
    extra = 0
    verbose_name = "Workspaces"
    verbose_name_plural = "Workspaces"
    
    def has_add_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
    
    def has_change_permission(self, request, obj=None):
        return False

class Users(admin.TabularInline):
    model = Workspace.users.through
    extra = 0
    verbose_name = "Users"
    verbose_name_plural = "Users"
    
    def has_add_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
    
    def has_change_permission(self, request, obj=None):
        return False

class Admins(admin.TabularInline):
    model = Workspace.admins.through
    extra = 0
    verbose_name = "Admins"
    verbose_name_plural = "Admins"
    
    def has_add_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
    
    def has_change_permission(self, request, obj=None):
        return False

class UserAdmin(BaseUserAdmin):
    list_display = ('email','first_name','last_name', 'no_of_sessions', 'admin', )
    list_filter = ('admin',)
    fieldsets = (
        ('Account', {'fields': ('user_id', 'email', 'password',)}),
        ('About', {'fields': ('first_name','last_name', 'registered_id', 'designation', 'contact', 'emails', 'phone_numbers',)}),
        ('Access', {'fields': ('active', 'confirmed', 'no_of_sessions', 'password_changed_at', )}),
    )
    inlines = [Workspaces]
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2')}
        ),
    )
    readonly_fields = ('no_of_sessions', 'password_changed_at', 'emails', 'phone_numbers', 'email', 'user_id', )
    search_fields = ('email', 'user_id',)
    ordering = ('user_id',)
    filter_horizontal = ()
    

    def no_of_sessions(self, obj):
        sessions = Session.objects.filter(expire_date__gte=timezone.now())
        active_sessions = 0
        for session in sessions:
            session_data = session.get_decoded()
            if session_data.get('_auth_user_id') == str(obj.id):
                active_sessions += 1
        return active_sessions

class WorkspaceAdmin(admin.ModelAdmin):
    list_display = ('workspace_id','name', 'no_of_admin', 'no_of_users', 'archive', )
    fieldsets = (
        ('Account', {'fields': ('name', 'workspace_id', 'registered_id', 'default_user', )}),
        ('About', {'fields': ('street_address', 'city', 'state', 'country', 'postal_code', 'departments',)}),
        ('Contact', {'fields': ('email_id', 'website', 'contact',)}),
        ('Status', {'fields': ('active', 'confirmed', 'archive')}),
    )
    readonly_fields = ('default_user', 'workspace_id', 'registered_id', 'archive', )
    search_fields = ('workspace_id',)
    ordering = ('workspace_id',)
    filter_horizontal = ()
    inlines = (Admins, Users)
    
    def no_of_admin(self, obj):
        return obj.admins.count()
    
    def no_of_users(self, obj):
        return obj.users.count()

class LoginInfoAdmin(admin.ModelAdmin):
    def has_change_permission(self, request, obj=None):
        return False

    def has_add_permission(self, request):
        return False
    
    list_display = ('user', 'ip_address', 'device_type', 'is_active',)
    fieldsets = (
        ('Session', {'fields':('user', 'session_key', 'login_time', 'logout_time', )}),
        ('Address Parameters', {'fields':('ip_address', 'user_agent', 'city', 'country',)}),
        ('Device', {'fields':('device_type', 'os', 'browser', )}),
    )
    readonly_fields = ('user', 'session_key', 'login_time', 'logout_time', 'ip_address', 'user_agent', 'city', 'country', 'device_type', 'os', 'browser',)

admin.site.register(User, UserAdmin)
admin.site.register(Workspace, WorkspaceAdmin)
admin.site.register(LoginInfo, LoginInfoAdmin)
admin.site.register(WorkspaceModeration)
admin.site.register(Announcement)

admin.site.unregister(Group)