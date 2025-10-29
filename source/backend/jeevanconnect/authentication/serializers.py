from rest_framework.serializers import ModelSerializer
from .models import User, Workspace, LoginInfo, WorkspaceModeration, Announcement

class AnnouncementSerializer(ModelSerializer):
    class Meta:
        model = Announcement
        fields = ['id', 'content', 'created_at']

class UserSerializer(ModelSerializer):
    class Meta:
        model = User
        exclude = ('password', 'id',)
        read_only_fields = ('created_at', 'modified_at')

class WorkspaceSerializer(ModelSerializer):
    default_user = UserSerializer(many=False, read_only=True)
    users = UserSerializer(many=True, read_only=True)
    admins = UserSerializer(many=True, read_only=True)

    class Meta:
        model = Workspace
        fields = '__all__'
        read_only_fields = ('created_at', 'modified_at')

class LoginInfoSerializer(ModelSerializer):
    
    class Meta:
        model = LoginInfo
        exclude = ('user', 'ip_address', 'session_key', )
        read_only_fields = ('created_at', 'modified_at')

class WorkspaceModerationSerializer(ModelSerializer):
    
    class Meta:
        model = WorkspaceModeration
        exclude = ('workspace',)