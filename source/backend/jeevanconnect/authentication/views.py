import django.contrib.auth as auth
from django.contrib.auth.hashers import check_password
from django.contrib.sites.shortcuts import get_current_site
from django.utils.http import urlsafe_base64_decode, urlsafe_base64_encode
from django.utils.encoding import force_str, force_bytes
from django.template.loader import get_template
from django.shortcuts import render
from django.contrib.auth.signals import user_logged_in, user_logged_out
from django.dispatch import receiver
from django.utils import timezone

from user_agents import parse

from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status

from .serializers import UserSerializer, WorkspaceSerializer, LoginInfoSerializer, WorkspaceModerationSerializer, AnnouncementSerializer
from .models import User, Workspace, LoginInfo, WorkspaceModeration, Announcement
from .forms import PasswordResetForm
from shared.response import *
from shared.tokens import password_reset_token, generic_auth_token
from shared.mailer import jc_mailer
from shared.location_info import get_location_info
from .session_helper import close_all_sessions

'''
TODO: Convert Invite token to single use only
TODO: Workspace attributes for Plan and Other feature management
TODO: User data management - HIPPA
TODO: Password reset UI Change
TODO: Verify all the exceptions
'''

# Users
@api_view(['POST'])
def signin(request):
    try:
        data = request.data
        email = data['email']
        qs = User.objects.filter(email=email, active=True)
        if not qs.exists():
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "No account exists with that Email address")
        user = User.objects.get(email=email, active=True)
        pwd_valid = check_password(data['password'], user.password)
        if pwd_valid:
            if user.is_confirmed:
                auth.login(request, user)
                userData = UserSerializer(user, many = False)
                return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Sign in Successful", userData.data)
            return Response(status.HTTP_401_UNAUTHORIZED, ERROR_CODES.CANNOT_PROCESS_REQUEST, "User not verified. Verify email to proceed further")
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.INVALID_CREDENTIALS, "Invalid credentials")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def signout(request):
    try:
        auth.logout(request)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Sign out Successful")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, "Unexpected error", data={'exception': exception})
       
@api_view(['POST'])
def signup(request):
    try:
        data = request.data
        email = data['email']
        qs = User.objects.filter(email=email, active=True)
        if qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_ALREADY_EXISTS, "User with that Email address already exists")
        password = data['password']
        first_name = data['first_name']
        last_name = data['last_name']
        designation = data['designation']
        registered_id = data['registered_id']
        contact = data['contact']
        user = User.objects.create_user(password= password, email=email, first_name=first_name, last_name=last_name, designation=designation, registered_id=registered_id, contact=contact)
        if user is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't create user. Try again later")
        else:
            return auth_mailer(mail_type=1, request=request, kwargs={"user":user})
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
def activate_user(request, uidb64, token):
    try:
        uid = force_str(urlsafe_base64_decode(uidb64))
        domain = get_current_site(request).domain
        try:
            user = User.objects.get(pk=uid)
        except User.DoesNotExist:
            user = None
        if user is not None and generic_auth_token.check_token(user, token):
            user.confirmed = True
            user.save()
            return render(request, 'authentication/account_activation.html', {'domain': domain})
        return render(request, 'authentication/invalid_request.html', {'domain': domain})
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
def reset_password(request):
    auth.logout(request)
    try:
        data = request.data
        email = data['email']
        qs = User.objects.filter(email=email)
        if qs.exists():
            user = User.objects.get(email=email)
            return auth_mailer(mail_type=2, request=request, kwargs={
                "user":user,
            }) 
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "User with that Email address doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET', 'POST'])
def update_password(request, uidb64, token):
    try:
        if request.method == 'POST':
            domain = get_current_site(request).domain
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)
            data = request.data
            new_password = data['password1']
            if user is not None and password_reset_token.check_token(user, token):
                user.set_password(new_password)
                user.password_changed_at = timezone.now()
                user.save()
                return render(request, 'authentication/password_reset.html', {'domain': domain})
            return render(request, 'authentication/invalid_request.html', {'domain': domain})
        else:
            form = PasswordResetForm()
            return render(request, 'authentication/password_reset_form.html', {'form': form, 'token':token, 'uidb64':uidb64})
            
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_user(request):
    try:
        data = request.data
        email = data['email']
        user = User.objects.get(email=email)
        user.first_name = data['first_name']
        user.last_name = data['last_name']
        user.designation = data['designation']
        user.registered_id = data['registered_id']
        user.save()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'User data updated')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_user_data(request):
    try:
        data = request.data
        user_id = data['email']
        user = User.objects.get(user_id=user_id)
        userData = UserSerializer(user, many = False)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'User data retrieved', userData.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_contact(request):
    try:
        data = request.data
        email = data['email']
        user = User.objects.get(email=email)
        return auth_mailer(mail_type=5, request=request, kwargs={"user":user, "data":data})
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
def activate_contact(request, uidb64, token, contact, ctype):
    try:
        uid = force_str(urlsafe_base64_decode(uidb64))
        domain = get_current_site(request).domain
        try:
            user = User.objects.get(pk=uid)
        except User.DoesNotExist:
            user = None
        if user is not None and generic_auth_token.check_token(user, token):
            if ctype=='email':
                if contact not in user.emails:
                    user.emails.append(contact)
            else:
                if contact not in user.phone_numbers:
                    user.phone_numbers.append(contact)
            user.save()
            return render(request, 'authentication/email_activation.html', {'domain': domain})
        return render(request, 'authentication/invalid_request.html', {'domain': domain})
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})    

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def archive_user(request):
    try:
        data = request.data
        email = data['email']
        user = User.objects.get(email=email, active=True)
        pwd_valid = check_password(data['password'], user.password)
        if pwd_valid:
            user.active = False
            close_all_sessions(user)
            user.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "User account archived successfully")
        else:
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.INVALID_CREDENTIALS, "Invalid credentials")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, "Unexpected error", data={'exception': exception})
    
@api_view(['POST'])
def resend_confirmation(request):
    try:
        data = request.data
        email = data['email']
        user = User.objects.get(email=email)
        if user.is_confirmed:
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "User is already verified")
        return auth_mailer(mail_type=1, request=request, kwargs={"user":user})
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_workspaces(request, registered_id):
    try:
        qs = User.objects.filter(registered_id=registered_id)
        if qs.exists():
            user = User.objects.get(registered_id=registered_id)
            if user.is_staff:
                serializer = WorkspaceSerializer(Workspace.objects.all(), many=True)
            else:
                serializer = WorkspaceSerializer(user.users.filter(archive=False), many=True)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request successful", serializer.data)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "User with that Email address doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
def validate_session(request):
    try:
        if request.user and request.user.is_authenticated:
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Valid Session")
        else:
            return Response(status.HTTP_403_FORBIDDEN, ERROR_CODES.INVALID_REQUEST, "Invalid Session")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_sessions(request, user_id):
    try:
        qs = User.objects.filter(user_id=user_id)
        if qs.exists():
            user = User.objects.get(user_id=user_id)
            sessions = LoginInfo.objects.filter(user=user, is_active=True)
            serializer = LoginInfoSerializer(sessions, many=True)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request successful", serializer.data)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "User with that Email address doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@receiver(user_logged_in)
def capture_login_info(sender, request, user, **kwargs):
    ip_address = request.META.get('REMOTE_ADDR')
    user_agent_string = request.META.get('HTTP_USER_AGENT', '')
    user_agent = parse(user_agent_string)
    location_info = get_location_info(ip_address)
    LoginInfo.objects.create(
        user=user,
        session_key=request.session.session_key,
        ip_address=ip_address,
        user_agent=user_agent_string,
        device_type=user_agent.device.family,
        browser=user_agent.browser.family,
        os=user_agent.os.family,
        country=location_info['country'],
        city=location_info['city']
    )

@receiver(user_logged_out)
def capture_logout_info(sender, request, user, **kwargs):
    if user:
        LoginInfo.objects.filter(
            user=user,
            session_key=request.session.session_key,
            is_active=True
        ).update(logout_time=timezone.now(), is_active=False)

# Workspace

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_workspace(request):
    try:
        data = request.data
        registered_id = data['registered_id']
        qs = Workspace.objects.filter(registered_id=registered_id)
        if qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_ALREADY_EXISTS, "Workspace with that ID already exists")
        name = data['name']
        email = data['email']
        street_address = data['street_address']
        city = data['city']
        state = data['state']
        postal_code = data['postal_code']
        website = data['website']
        contact = data['contact']
        user_id = data['user_id']
        country = data['country']
        user = User.objects.get(user_id=user_id)
        workspace = Workspace.objects.create_workspace(name=name, email=email,registered_id=registered_id,  user = user, street_address = street_address,
            city = city, state = state, postal_code = postal_code, website = website, contact = contact, country=country)
        moderations = WorkspaceModeration.objects.create(workspace = workspace)
        if workspace is None or moderations is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't create workspace. Try again later")
        else:
            return auth_mailer(mail_type=3, request=request, kwargs={"workspace":workspace})
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
def activate_workspace(request, uidb64, token):
    try:
        uid = force_str(urlsafe_base64_decode(uidb64))
        domain = get_current_site(request).domain
        try:
            workspace = Workspace.objects.get(pk=uid)
        except Workspace.DoesNotExist:
            workspace = None
        if workspace is not None and generic_auth_token.check_token(workspace, token):
            workspace.confirmed = True
            workspace.default_user.confirmed = True
            workspace.save()
            return render(request, 'authentication/workspace_activation.html', {'domain': domain})
        return render(request, 'authentication/invalid_request.html', {'domain': domain})
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def archive_workspace(request):
    try:
        data = request.data
        user_id = data['user']
        workspace_id = data['workspace']
        user = User.objects.get(user_id=user_id)
        pwd_valid = check_password(data['password'], user.password)
        if pwd_valid:
            workspace = Workspace.objects.get(workspace_id=workspace_id)
            if (user==workspace.default_user) or user.is_staff:
                workspace.active = False
                workspace.archive = True
                workspace.save()
                return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Archived workspace successfully')
            return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Administrative permissions required to archive workspace')
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.INVALID_CREDENTIALS, "Invalid credentials")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def invite_user(request):
    try:
        data = request.data
        user_id = data['admin']
        uemail = data['user']
        workspace_id = data['workspace']
        qs = User.objects.filter(email=uemail, active=True)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "User with that Email address doesn't exists")
        user = User.objects.get(email=uemail, active=True)
        admin = User.objects.get(user_id=user_id)
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        if admin.is_staff or workspace.admins.filter(user_id=user_id).exists():
            return auth_mailer(mail_type=4, request=request, kwargs={"user":user, "workspace":workspace, "admin":admin})
        else:
            return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Administrative permissions required to invite a user to workspace')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
def add_user(request, uuidb64, wuidb64, token):
    try:
        uuid = force_str(urlsafe_base64_decode(uuidb64))
        wuid = force_str(urlsafe_base64_decode(wuidb64))
        domain = get_current_site(request).domain
        try:
            user = User.objects.get(pk=uuid)
        except User.DoesNotExist:
            user = None
        try:
            workspace = Workspace.objects.get(pk=wuid)
        except Workspace.DoesNotExist:
            workspace = None
        if workspace is not None and user is not None and generic_auth_token.check_token(workspace, token, expiration_seconds=604800):
            if not workspace.users.filter(email=user.email).exists():
                workspace.users.add(user)
                workspace.save()
            return render(request, 'authentication/user_added.html', {'domain': domain, 'workspace':workspace})
        return render(request, 'authentication/invalid_request.html', {'domain': domain})
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def remove_user(request):
    try:
        data = request.data
        user_id = data['user']
        admin_id = data['admin']
        workspace_id = data['workspace']
        user = User.objects.get(user_id=user_id)
        admin = User.objects.get(user_id=admin_id)
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        
        if workspace.users.filter(user_id=user_id).exists():
            if user==workspace.default_user:
                return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Default user cannot be removed')
            if admin.is_staff or workspace.admins.filter(user_id=admin_id).exists():
                workspace.users.remove(user)
                workspace.admins.remove(user)
                workspace.save()
                return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'User removed from Workspace successfully')
            else:
                return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Administrative permissions required to remove a user from workspace')
        else:
            return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'User is not present in the workspace')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def exit_workspace(request):
    try:
        data = request.data
        user_id = data['user']
        workspace_id = data['workspace']
        default = data.get('default', None)
        
        user = User.objects.get(user_id=user_id)
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        
        if workspace.users.filter(user_id=user_id).exists():
            if user==workspace.default_user:
                if default:
                    default_user = User.objects.get(user_id=default)
                    workspace.default_user = default_user
                    if not workspace.admins.filter(user_id=default).exists():
                        workspace.admins.add(default_user)
                else:
                    return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Default user cannot be removed')
            workspace.users.remove(user)
            workspace.admins.remove(user)
            workspace.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'User removed from Workspace successfully')
        else:
            return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'User is not present in the workspace')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_workspace(request):
    try:
        data = request.data
        workspace_id = data['workspace_id']
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        workspace.name = data['name']
        workspace.website = data['website']
        workspace.street_address = data['street_address']
        workspace.city = data['city']
        workspace.country = data['country']
        workspace.postal_code = data['postal_code']
        workspace.state = data['state']
        workspace.save()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, '')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_role(request):
    try:
        data = request.data
        admin_id = data['admin']
        user_id = data['user']
        workspace_id = data['workspace']
        role = data['role']
        
        user = User.objects.get(user_id=user_id)
        admin = User.objects.get(user_id=admin_id)
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        
        if admin.is_staff or workspace.admins.filter(user_id=admin_id).exists():
            if workspace.users.filter(user_id=user_id).exists():
                if role == 'user':
                    workspace.admins.remove(user)
                    workspace.save()
                elif role == 'admin':
                    workspace.admins.add(user)
                    workspace.save()
                else:
                    return Response(status.HTTP_501_NOT_IMPLEMENTED, ERROR_CODES.NOT_IMPLEMENTED, 'Method not implemented')
                return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, 'User is not present in the workspace')
        return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Administrative permissions required to remove a user from workspace')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_users(request, workspace_id):
    try:
        data = request.data
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if qs.exists():
            workspace = Workspace.objects.get(workspace_id=workspace_id)
            userData = UserSerializer(workspace.users, many = True)
            adminData = UserSerializer(workspace.admins, many = True)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", {
                'users': userData.data,
                'admins': adminData.data
            })
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_workspace_data(request):
    try:
        data = request.data
        workspace_id = data['workspace_id']
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        workspaceData = WorkspaceSerializer(workspace, many = False)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Workspace data retrieved', workspaceData.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_departments(request, workspace_id):
    try:
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if qs.exists():
            workspace = Workspace.objects.get(workspace_id=workspace_id)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", workspace.departments)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_department(request):
    try:
        data = request.data
        workspace_id = data['workspace']
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if qs.exists():
            workspace = Workspace.objects.get(workspace_id=workspace_id)
            department = set(data['department'].split(","))
            existing = set(workspace.departments)
            workspace.departments = list(existing|department)
            workspace.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", workspace.departments)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def remove_department(request):
    try:
        data = request.data
        workspace_id = data['workspace']
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if qs.exists():
            workspace = Workspace.objects.get(workspace_id=workspace_id)
            department = set(data['department'].split(","))
            existing = set(workspace.departments)
            workspace.departments = list(existing.difference(department))
            workspace.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", workspace.departments)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
# Mailer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_workspace_permissions(request, workspace_id):
    try:
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if qs.exists():
            workspace = Workspace.objects.get(workspace_id=workspace_id)
            moderations = WorkspaceModeration.objects.get(workspace=workspace)
            serializer = WorkspaceModerationSerializer(moderations, many=False)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", serializer.data)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def edit_workspace_permissions(request):
    try:
        data = request.data
        workspace_id = data['workspace']
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if qs.exists():
            workspace = Workspace.objects.get(workspace_id=workspace_id)
            moderations = WorkspaceModeration.objects.get(workspace=workspace)
            moderations.invite_member = data['invite_member']
            moderations.edit_department = data['edit_department']
            moderations.add_patient = data['add_patient']
            moderations.edit_product = data['edit_product']
            moderations.download_information = data['download_information']
            moderations.workspace_details = data['workspace_details']
            moderations.share_device = data['share_device']
            moderations.save()
            moderations = WorkspaceModeration.objects.get(workspace=workspace)
            serializer = WorkspaceModerationSerializer(moderations, many=False)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", serializer.data)
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_announcements(request, workspace_id):
    try:
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID doesn't exists")
        announcements = Announcement.objects.filter(workspace_id=workspace_id, created_at__gte=timezone.now() - timezone.timedelta(days=1)) 
        serializer = AnnouncementSerializer(announcements, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request successful", serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception}) 

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_announcement( request):
    try:
        workspace_id = request.data.get('workspace_id')
        content = request.data.get('content')
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID doesn't exists") 
        if not content:      
            return Response(status.HTTP_204_NO_CONTENT, ERROR_CODES.ENTITY_NOT_FOUND, "Announcement should have content")
        announcement = Announcement.objects.create(workspace_id=workspace_id, content=content)
        if announcement is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't create announcment. Try again later")
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def remove_announcement( request):
    try:
        data = request.data
        workspace_id = request.data.get('workspace_id')
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID doesn't exists") 
        indices = set(data['indices'].split(","))
        indices = set(map(int, indices))
        Announcement.objects.filter(id__in=indices).delete()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

def auth_mailer(mail_type, request, **kwargs):
    current_site = get_current_site(request)
    try:
        if mail_type==1:
            subject = 'Account confirmation - JeevanConnect'
            user = kwargs['kwargs']['user']
            context = {
                'user': user,
                'domain': current_site.domain,
                'uid':urlsafe_base64_encode(force_bytes(user.pk)),
                'token':generic_auth_token.make_token(user),
            }
            message = get_template('mail/authentication/account_confirmation.html').render(context)
            jc_mailer.send_email(to=[user.email], subject=subject, message=message, content_type='html')
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'User created successfully')
        
        elif mail_type==2:
            subject = 'Password Reset - JeevanConnect'
            user = kwargs['kwargs']['user']
            context = {
                'user': user,
                'domain': current_site.domain,
                'uid':urlsafe_base64_encode(force_bytes(user.pk)),
                'token':password_reset_token.make_token(user),
            }
            message = get_template('mail/authentication/password_reset.html').render(context)
            jc_mailer.send_email(to=[user.email], subject=subject, message=message, content_type='html')
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Password reset mail is sent to the registered email address')
        
        elif mail_type==3:
            subject = 'Workspace confirmation - JeevanConnect'
            workspace = kwargs['kwargs']['workspace']
            context = {
                'workspace': workspace,
                'domain': current_site.domain,
                'uid':urlsafe_base64_encode(force_bytes(workspace.pk)),
                'token':generic_auth_token.make_token(workspace),
            }
            message = get_template('mail/authentication/workspace_confirmation.html').render(context)
            jc_mailer.send_email(to=[workspace.email_id], subject=subject, message=message, content_type='html')
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Workspace created successfully')
        
        elif mail_type==4:
            user = kwargs['kwargs']['user']
            admin = kwargs['kwargs']['admin']
            workspace = kwargs['kwargs']['workspace']
            subject = 'Workspace Invite - JeevanConnect'
            context = {
                'user': user,
                'admin': admin,
                'workspace': workspace,
                'domain': current_site.domain,
                'uuid':urlsafe_base64_encode(force_bytes(user.pk)),
                'wuid':urlsafe_base64_encode(force_bytes(workspace.pk)),
                'token': generic_auth_token.make_token(workspace),
            }
            message = get_template('mail/authentication/workspace_invite.html').render(context)
            jc_mailer.send_email(to=[user.email], subject=subject, message=message, content_type='html')
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Invite mail is sent to the user')
        
        elif mail_type==5:
            subject = 'Email confirmation - JeevanConnect'
            user = kwargs['kwargs']['user']
            data = kwargs['kwargs']['data']
            email = data['contact']
            context = {
                'user': user,
                'domain': current_site.domain,
                'uid':urlsafe_base64_encode(force_bytes(user.pk)),
                'token':generic_auth_token.make_token(user),
                'contact':data['contact'],
                'ctype':data['type'],
            }
            message = get_template('mail/authentication/email_confirmation.html').render(context)
            jc_mailer.send_email(to=[email], subject=subject, message=message, content_type='html')
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Email confirmation sent successfully')
        
        else:
            return Response(status.HTTP_501_NOT_IMPLEMENTED, ERROR_CODES.NOT_IMPLEMENTED, 'Method not implemented')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})