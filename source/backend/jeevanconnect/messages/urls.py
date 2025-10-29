from django.urls import path
from . import views

urlpatterns = [
    path('conversation/create/', views.create_conversation, name='create-user-conversations'),
    path('conversation/get/<slug:user_id>/', views.get_conversation, name='get-user-conversations'),
    path('<slug:conversation_id>/messages/', views.get_messages, name='get-messages'),
    path('send/message/', views.send_message, name="send-message")
]