from django.urls import path
from . import views


urlpatterns = [
    path('workspace/<slug:workspace_id>/', views.workspace_analytics, name="workspace-analytics"),
    path('workspace/sessions/device/', views.device_session_analytics, name="device-sessions"),
    path('workspace/sessions/<slug:workspace_id>/<int:year>/', views.workspace_session_analytics, name="workspace-sessions"),
    path('workspace/device/<slug:workspace_id>/', views.workspace_device_statistics, name="workspace-device-statistics"),
    path('workspace/patient/<slug:workspace_id>/', views.workspace_patient_statistics, name="workspace-patient-statistics"),
    path('workspace/user/<slug:workspace_id>/', views.workspace_user_statistics, name="workspace-user-statistics"),
]