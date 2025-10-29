from datetime import datetime

from django.db.models import Count, Q, OuterRef, Subquery, Exists
from django.db.models.functions import TruncMonth

from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status

from shared.response import *
from authentication.models import Workspace, LoginInfo
from product.models import Ventilator
from patient.models import Patient
from jvsync.models import VentilationSession

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def workspace_session_analytics(request, workspace_id, year):
    try:
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        sessions = VentilationSession.objects.filter(created_at__year=year, workspace=workspace).annotate(month=TruncMonth('created_at')).values('month').annotate(count=Count('session_id')).order_by('month')
        result = {}
        for session in sessions:
            month_name = session["month"].strftime("%m")
            result[month_name] = session["count"]
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, '', result)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def device_session_analytics(request):
    try:
        data = request.data
        serial_number = data["serial_number"]
        wqs = Ventilator.objects.filter(serial_number=serial_number)
        if not wqs.exists():
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Ventilator with that Serial number is not found")
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        year = data["year"]
        sessions = VentilationSession.objects.filter(created_at__year=year, ventilator=ventilator).annotate(month=TruncMonth('created_at')).values('month').annotate(count=Count('session_id')).order_by('month')
        result = {}
        for session in sessions:
            month_name = session["month"].strftime("%m")
            result[month_name] = session["count"]
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, '', result)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def workspace_analytics(request, workspace_id):
    try:
        result = {}
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        
        result["active_devices"] = Ventilator.objects.filter(Q(workspace=workspace), Q(status="IU"), Q(is_online=True)).count()
        
        result["offline_devices"] = Ventilator.objects.filter(Q(workspace=workspace), Q(is_online=False)).count()
        
        result["repair_devices"] = Ventilator.objects.filter(Q(workspace=workspace), Q(status="RP")).count()
        
        result["idle_devices"] = Ventilator.objects.filter(Q(workspace=workspace), Q(status="ID"), Q(is_online=True)).count()
        
        result["patients_under_ventilation"] = VentilationSession.objects.filter(workspace=workspace, is_active=True).count()
        
        active_sessions = VentilationSession.objects.filter(patient=OuterRef('pk'), is_active=True, workspace=workspace)
        result["treated_patients"] = Patient.objects.annotate(
            has_active_sessions=Subquery(active_sessions.values('patient_id')[:1])
        ).filter(
            has_active_sessions__isnull=True,
            session_patient__isnull=False,
            workspace=workspace
        ).distinct().count()
        
        result["department_count"] = len(workspace.departments)
        
        active_login = LoginInfo.objects.filter(user=OuterRef('pk'),is_active=True)
        result["active_users"] = workspace.users.annotate(
            has_active_login=Exists(active_login)
        ).filter(has_active_login=True).count()
        
        result["total_users"] = workspace.users.filter(active=True).count()
        
        result["active_patients"] = Patient.objects.filter(workspace=workspace, active=True).count()
        
        grouped_data = Ventilator.objects.filter(workspace=workspace).values('department').annotate(count=Count('serial_number'))
        result["department_wise_devices"] = {
            item['department'] if item['department'] is not None else 'Unassigned': item['count']
            for item in grouped_data
        }
        
        departments = workspace.departments
        departments.append("Unassigned")
        result["departments"] = departments
        
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS,"", result)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def workspace_device_statistics(request, workspace_id):
    try:
        result = {}
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        workspace = Workspace.objects.get(workspace_id=workspace_id)
         
        result["Total devices"] = Ventilator.objects.filter(Q(workspace=workspace)).count()
        result["Active devices"] = Ventilator.objects.filter(Q(workspace=workspace), Q(status="IU")).count()
        result["Idle devices"] = Ventilator.objects.filter(Q(workspace=workspace), Q(status="ID")).count()
        result["Offline devices"] = Ventilator.objects.filter(Q(workspace=workspace), Q(is_online=False)).count()
        result["Repair/In service devices"] = Ventilator.objects.filter(Q(workspace=workspace), Q(status="RP")).count()
        
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', result)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def workspace_patient_statistics(request, workspace_id):
    try:
        result = {}
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        
        result['Total patients attended'] = Patient.objects.filter(workspace=workspace).count()    
        result['Active patients'] = Patient.objects.filter(workspace=workspace, active=True).count()
        active_sessions = VentilationSession.objects.filter(patient=OuterRef('pk'), is_active=True, workspace=workspace)
        result["Treated patients"] = Patient.objects.annotate(
            has_active_sessions=Subquery(active_sessions.values('patient_id')[:1])
        ).filter(
            has_active_sessions__isnull=True,
            session_patient__isnull=False
        ).distinct().count()    
        result["Patients under ventilation"] = VentilationSession.objects.filter(workspace=workspace, is_active=True).count()
        
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', result)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def workspace_user_statistics(request, workspace_id):
    try:
        result = {}
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        
        total_users = workspace.users.filter(active=True).count()
        active_login = LoginInfo.objects.filter(user=OuterRef('pk'),is_active=True)
        online_users = workspace.users.annotate(
            has_active_login=Exists(active_login)
        ).filter(has_active_login=True).count()
        
        result['Total members'] = total_users
        
        result['Online members'] = online_users
        
        result['Offline members'] = total_users - online_users
        
        result['Total Admins'] = workspace.admins.count()
        
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', result)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})