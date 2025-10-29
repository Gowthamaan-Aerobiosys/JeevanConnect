from rest_framework import serializers
from django.urls import reverse

from .models import Message, Conversation
from authentication.serializers import UserSerializer

class LastMessageSerializer(serializers.ModelSerializer):
    sender_user_id = serializers.CharField(source='sender.user_id')
    class Meta:
        model = Message
        fields = ['content', 'seen', 'id', 'timestamp', 'sender_user_id',]

class ConversationSerializer(serializers.ModelSerializer):
    user1 = UserSerializer(many=False, read_only=True)
    user2 = UserSerializer(many=False, read_only=True)
    last_message = serializers.SerializerMethodField()
    
    class Meta:
        model = Conversation
        fields = ['id', 'user1', 'user2', 'last_modified', 'last_message']

    def get_last_message(self, obj):
        last_message = obj.messages.order_by('-timestamp').first()
        if last_message:
            return LastMessageSerializer(last_message).data
        return None

class MessageSerializer(serializers.ModelSerializer):
    conversation = ConversationSerializer(many=False, read_only=True)
    sender = UserSerializer(many=False, read_only=True)
    receiver = UserSerializer(many=False, read_only=True)
    file_message_url = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'content', 'conversation', 'sender', 'receiver', 'seen', 'timestamp', 'file_message_url']

    def get_file_message_url(self, obj):
        if obj.file_message:
            return self.context['request'].build_absolute_uri(obj.file_message.url)
        return None
