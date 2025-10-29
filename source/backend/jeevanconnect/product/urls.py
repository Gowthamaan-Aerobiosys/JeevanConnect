from django.urls import path
from . import views

urlpatterns = [
    path('ven/register/', views.register_ventilator, name="register-ventilator"),
    path('ven/workspace/add/', views.add_product_to_workspace, name="add-product-to-workspace"),
    path('ven/location/update/', views.update_device_location, name="update-device-location"),
    path('ven/workspace/remove/', views.remove_product_from_workspace, name="remove-product-from-workspace"),
    
    # Getters
    path('ven/get_all/', views.getVentilators, name="get-ventilator"),
    path('ven/<slug:workspace_id>/get/', views.getWorkspaceVentilators, name="get-workspace-ventilators"),
    path('ven/service/book_ticket/', views.book_service_ticket, name="book-service-ticket"),
    path('ven/service/get_ticket/', views.get_service_tickets, name="get-service-ticket"),
    path('ven/service/<slug:ticket_id>/logs/', views.get_service_logs, name="get-service-logs"),
    path('ven/get/', views.getVentilator, name="get-ventilator"),
    path('ven/department/edit/', views.edit_department, name="edit-ventilator-department"),
]