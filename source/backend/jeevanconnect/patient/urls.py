from django.urls import path
from . import views


urlpatterns = [
    path('register/', views.register_patient, name="register-patient"),
    
    # Getters
    path('get/', views.get_patients, name="get-patient"),
    path('amr/create/', views.add_admission_record, name="add-admission-record"),
    path('amr/edit/', views.add_admission_record, name="edit-admission-record"),
    path('amr/get/', views.get_admission_record, name="get-admission-record"),
    path('amr/get/current/', views.get_current_admission_record, name="get-current-admission-record"),
    path('amr/remove/', views.remove_admission_record, name="remove-admission-record"),
    path('amr/logs/get/<slug:id>/', views.get_log, name="get-clinical-advice"),
    path('amr/logs/add/', views.add_log, name="add-log"),
    path('amr/logs/remove/', views.remove_log, name="remove-log"),
    path('amr/abg/get/graph/<slug:id>/', views.get_abg_graph, name="get-abg-graph"),
    path('amr/abg/get/<slug:id>/', views.get_abg_records, name="get-abg-record"),
    path('amr/abg/add/', views.add_abg_record, name="add-abg-record"),
    path('amr/abg/remove/', views.remove_abg_record, name="remove-abg-record"),
    path('<slug:workspace_id>/get/', views.get_workspace_patients, name="get-workspace-patient")
]