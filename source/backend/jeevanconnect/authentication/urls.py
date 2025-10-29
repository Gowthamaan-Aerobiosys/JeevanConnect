from django.urls import path
from . import views

urlpatterns = [
    # Users
    path('auth/signup/', views.signup, name="signup"),
    path('auth/signin/', views.signin, name="signin"),
    path('auth/signout/', views.signout, name="signout"),
    path('auth/validate/', views.validate_session, name="validate-session"),
    path('auth/confirmation/resend/', views.resend_confirmation, name="resend-confirmation"),
    path('auth/user/activate/<slug:uidb64>/<path:token>/', views.activate_user, name="activate-user"),
    path('auth/user/update/', views.update_user, name="update-user"),
    path('auth/user/get/', views.get_user_data, name="get-user-data"),
    path('auth/user/archive/', views.archive_user, name="archive-user"),
    path('auth/password/reset/', views.reset_password, name="reset-password"),
    path('auth/password/change/<slug:uidb64>/<slug:token>/', views.update_password, name="update-password"),
    path('auth/user/contact/add/', views.add_contact, name="add-contact"),
    path('auth/user/contact/activate/<slug:uidb64>/<path:token>/<path:contact>/<slug:ctype>/', views.activate_contact, name="activate-contact"),
    
    # Workspace
    path('workspace/create/', views.create_workspace, name="create-workspace"),
    path('workspace/update/', views.update_workspace, name="update-workspace"),
    path('workspace/activate/<slug:uidb64>/<path:token>/', views.activate_workspace, name="activate-workspace"),
    path('workspace/archive/', views.archive_workspace, name="archive-workspace"),
    path('workspace/get/', views.get_workspace_data, name="get-workspace-data"),
    path('workspace/user/invite/', views.invite_user, name="invite-user"),
    path('workspace/user/add/<slug:uuidb64>/<slug:wuidb64>/<path:token>/', views.add_user, name="add-user"),
    path('workspace/user/remove/', views.remove_user, name="remove-user"),
    path('workspace/user/exit/', views.exit_workspace, name="exit-user"),
    path('workspace/user/update-role/', views.update_role, name="update-role"),
    path('workspace/departments/add/', views.add_department, name="add-departments"),
    path('workspace/departments/remove/', views.remove_department, name="remove-departments"),
    path('workspace/departments/<slug:workspace_id>/', views.get_departments, name="get-departments"),
    path('workspace/permissions/edit/', views.edit_workspace_permissions, name="edit-workspace-permissions"),
    path('workspace/permissions/<slug:workspace_id>/', views.get_workspace_permissions, name="get-workspace-permissions"),
    path('workspace/announcement/create/', views.create_announcement, name="create-announcement"),
    path('workspace/announcement/remove/', views.remove_announcement, name="remove-announcement"),
    path('workspace/announcement/<slug:workspace_id>/', views.get_announcements, name="get-workspace-announcement"),
    
    # Getters
    path('<slug:registered_id>/workspaces/', views.get_workspaces, name="get-workspaces"),
    path('<slug:workspace_id>/users/', views.get_users, name="get-users"),
    path('<slug:user_id>/sessions/', views.get_sessions, name="get-sessions")
]