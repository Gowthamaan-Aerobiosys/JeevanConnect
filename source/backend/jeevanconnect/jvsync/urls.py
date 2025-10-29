from django.urls import path
from . import views

urlpatterns = [
    path('monitoring/sessions/create/', views.create_session, name="create-monitoring-sessions"),
    path('monitoring/sessions/update/', views.update_status, name="update-monitoring-sessions"),
    path('monitoring/sessions/archive/', views.archive_session, name="archive-monitoring-sessions"),
    path('monitoring/sessions/get/', views.get_sessions, name="get-monitoring-sessions"),
    path('monitoring/sessions/patient/', views.get_patient_sessions, name="get-patient-sessions"),
    path('monitoring/sessions/stream/start/', views.start_monitoring_stream, name="start-monitoring-stream"),
    path('monitoring/sessions/stream/stop/', views.stop_monitoring_stream, name="stop-monitoring-stream"),
    path('monitoring/sessions/log/request/', views.request_monitoring_log, name="request-monitoring-log"),
    path('monitoring/sessions/log/save/', views.save_monitoring_log, name="save-monitoring-log"),
    path('monitoring/sessions/log/download/<slug:session_id>/<slug:log_type>/', views.download_monitoring_log, name="download-monitoring-log"),
    path('monitoring/sessions/log/get/<slug:session_id>/<slug:log_type>/', views.get_monitoring_log, name="get-monitoring-log"),
    path('monitoring/sessions/link/patient/', views.map_session_patient, name="map-session-patient"),
    path('monitoring/sessions/active/<slug:workspace_id>/', views.get_workspace_active_sessions, name="get-active-workspace-sessions"),
]