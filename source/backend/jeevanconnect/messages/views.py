from django.db.models import Q, Max
from django.http import FileResponse
from django.shortcuts import get_object_or_404

import json
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status

from shared.response import *
from .models import Conversation, Message
from .serializers import ConversationSerializer, MessageSerializer
from authentication.models import User

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_conversation(request, user_id):
    try:
        qs = User.objects.filter(user_id=user_id)
        if qs.exists():
            user = User.objects.get(user_id=user_id)
            conversations = Conversation.objects.filter(user1=user)|Conversation.objects.filter(user2=user)
            conversations = conversations.annotate(
                last_message_timestamp=Max('messages__timestamp')
            ).order_by('-last_message_timestamp')
            serializer = ConversationSerializer(conversations, many=True)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request successful", serializer.data)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "User with that User ID doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_file(request, pk):
    message = get_object_or_404(Message, pk=pk)
    if message.file_message:
        return FileResponse(message.file_message.open('rb'), as_attachment=True, filename=message.file_message.name)
    return Response(status=404)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_messages(request, conversation_id):
    try:
        qs = Conversation.objects.filter(id=conversation_id)
        if qs.exists():
            conversation = Conversation.objects.get(id=conversation_id)
            messages = conversation.messages
            serializer = MessageSerializer(messages, many=True, context={'request': request})
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request successful", serializer.data)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Conversation with that conversation ID doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_conversation(request):
    try:
        data = request.data
        sender = User.objects.get(user_id = data["sender"])
        receiver = User.objects.get(user_id = data["receiver"])
        qs = Conversation.objects.filter(Q(user1=sender) | Q(user1=receiver) | Q(user2=sender) | Q(user2=receiver))
        if qs.exists():
            qs = Conversation.objects.filter(Q(user1=sender) | Q(user2=sender))
            if qs.exists():
                conversation = Conversation.objects.get(user1 = sender, user2 = receiver)
            else:
                conversation = Conversation.objects.get(user2 = sender, user1 = receiver)
        else:
            conversation = Conversation.objects.create(user1 = sender,user2 = receiver)
        serializer = ConversationSerializer(conversation, many=False)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_message(request): 
    try:
        data = request.data
        conversation_id = data.get('conversation_id', None)
        if conversation_id is None:
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Conversation ID required")     
        else:
            qs = Conversation.objects.filter(id=conversation_id)
            if qs.exists():
                conversation = Conversation.objects.get(id=conversation_id)   
            else: 
                return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Conversation with that conversation ID doesn't exists")
        message_data = {
            'conversation': conversation,
            'content': data.get('content', ''),
            'sender': request.user,
            'receiver': User.objects.get(user_id=data["receiver"])
        }
        if 'file' in request.FILES:
            message_data['file_message'] = request.FILES['file']
            
        try:
            message = Message.objects.create(**message_data)
        except Exception as e:
            print(f"Error creating message: {str(e)}")
            
        try:
            layer = get_channel_layer()
            typedMessage = {}
            typedMessage["type"] = "reload_request"
            typedMessage["data"] = "new_message"
            message = json.dumps(typedMessage)
            async_to_sync(layer.group_send)('jeevan_'+str(data["receiver"]), {
                    'type': 'group_send_user',
                    'text': message
            })     
        except Exception as exception:
            print(f"Error creating message: {str(exception)}")
        
        if message is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't add message. Try again later")
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request successful")
    except Exception as exception:
        print(f"Error creating message: {str(exception)}")
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
