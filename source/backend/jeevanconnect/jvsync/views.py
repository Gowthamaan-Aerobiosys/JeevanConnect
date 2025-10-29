import os
from django.conf import settings
from django.http import FileResponse
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status
from datetime import datetime

import json
from asgiref.sync import async_to_sync

from .models import VentilationSession, SessionLog
from .serializers import VentilatorSessionSerializer
from .consumers import VentilatorConsumer
from shared.response import *
from product.models import Ventilator
from authentication.models import Workspace
from patient.models import Patient


@api_view(['POST'])
def create_session(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        pqs = Ventilator.objects.filter(serial_number=serial_number)
        if not pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that Email address is not found")
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        secret_key = data['key']
        if secret_key!=ventilator.secret_key:
            return Response(status.HTTP_403_FORBIDDEN, ERROR_CODES.INVALID_CREDENTIALS, "Invalid API key")
        session_id = data['session_id']
        workspace_id = data['workspace_id']
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        workspace = Workspace.objects.get(workspace_id = workspace_id)
        session = VentilationSession.objects.create(
            session_id = session_id,
            ventilator = ventilator,
            workspace = workspace
        )
        if session is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't create session. Try again later")
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Session created')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
def update_status(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        pqs = Ventilator.objects.filter(serial_number=serial_number)
        if not pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that Email address is not found")
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        secret_key = data['key']
        if secret_key!=ventilator.secret_key:
            return Response(status.HTTP_403_FORBIDDEN, ERROR_CODES.INVALID_CREDENTIALS, "Invalid API key")
        session_id = data['session_id']
        pqs = VentilationSession.objects.filter(session_id=session_id)
        if not pqs.exists():
            return Response(status.HTTP_403_FORBIDDEN, ERROR_CODES.ENTITY_NOT_FOUND, "Ventilation session doesnot exists")
        session = VentilationSession.objects.get(session_id=session_id)
        active = data['active']
        session.is_active = active
        session.save()
        if session.is_active:
            ventilator.status = "IU"
        else:
            ventilator.status = "ID"
        ventilator.save()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Session created')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})  
    
@api_view(['POST'])
def archive_session(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        pqs = Ventilator.objects.filter(serial_number=serial_number)
        if not pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that Email address is not found")
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        secret_key = data['key']
        if secret_key!=ventilator.secret_key:
            return Response(status.HTTP_403_FORBIDDEN, ERROR_CODES.INVALID_CREDENTIALS, "Invalid API key")
        session_ids = data['session_id'].split(',')
        for session_id in session_ids:
            session_id = session_id.strip()
            try:
                session = VentilationSession.objects.get(session_id=session_id)
                session.is_active = False
                session.is_archive = True
                session.save()
            except VentilationSession.DoesNotExist:
                pass
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Session archived')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_sessions(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        qs = Ventilator.objects.filter(serial_number=serial_number)
        if qs.exists():
            ventilator = Ventilator.objects.get(serial_number=serial_number)
            sessions = VentilationSession.objects.filter(ventilator=ventilator, is_archive=False)
            serializer = VentilatorSessionSerializer(sessions, many=True)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
        return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that serial number is not found")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_patient_sessions(request):
    try:
        data = request.data
        patient_id = data['patient_id']
        qs = Patient.objects.filter(patient_id=patient_id)
        if qs.exists():
            patient = Patient.objects.get(patient_id=patient_id)
            sessions = VentilationSession.objects.filter(patient=patient, is_archive=False)
            serializer = VentilatorSessionSerializer(sessions, many=True)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
        return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Patient with that ID is not found")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_workspace_active_sessions(request, workspace_id):
    try:
        qs = Workspace.objects.filter(workspace_id=workspace_id)
        if qs.exists():
            workspace = Workspace.objects.get(workspace_id=workspace_id)
            sessions = VentilationSession.objects.filter(workspace=workspace, is_active=True, is_archive=False)
            serializer = VentilatorSessionSerializer(sessions, many=True)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
        return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that ID is not found")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def start_monitoring_stream(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        qs = Ventilator.objects.filter(serial_number=serial_number)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that Serial number is not found")
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        result = {}
        if ventilator.status == "IU":
            typedMessage = {}
            typedMessage["type"] = "connect_request"
            typedMessage["data"] = "monitoring_data"
            message = json.dumps(typedMessage)
            serial_number = serial_number.replace("/", "_")
            async_to_sync(VentilatorConsumer.send_message_to_device)(str(serial_number), message)
            result = {
                "serial_number": serial_number,
                "key": ventilator.secret_key
            } 
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', result)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def stop_monitoring_stream(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        qs = Ventilator.objects.filter(serial_number=serial_number)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that Serial number is not found")
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        if ventilator.status == "IU":
            typedMessage = {}
            typedMessage["type"] = "disconnect_request"
            typedMessage["data"] = "monitoring_data"
            message = json.dumps(typedMessage)
            serial_number = serial_number.replace("/", "_")
            async_to_sync(VentilatorConsumer.send_message_to_device)(str(serial_number), message)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def request_monitoring_log(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        qs = Ventilator.objects.filter(serial_number=serial_number)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that Serial number is not found")
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        if ventilator.is_online:
            typedMessage = {}
            typedMessage["type"] = "log_request"
            typedMessage["data"] = data["session_id"]
            message = json.dumps(typedMessage)
            serial_number = serial_number.replace("/", "_")
            async_to_sync(VentilatorConsumer.send_message_to_device)(str(serial_number), message)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', "Request sent")
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', "Device offline")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
def map_session_patient(request):
    try:
        data = request.data
        serial_number = data["serial_number"]
        workspace_id = data["workspace_id"]
        patient_id = data["patient_id"]
        session_id = data["session_id"]
        vqs = Ventilator.objects.filter(serial_number=serial_number)
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        pqs = Patient.objects.filter(patient_id=patient_id)
        sqs = VentilationSession.objects.filter(session_id=session_id)
        if not vqs.exists() or not wqs.exists() or not pqs.exists() or not sqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Invalid Request")
        ventilator = Ventilator.objects.get(serial_number=serial_number)
        secret_key = data["key"]
        print(data)
        if secret_key!=ventilator.secret_key:
            return Response(status.HTTP_403_FORBIDDEN, ERROR_CODES.INVALID_CREDENTIALS, "Invalid API key")
        session = VentilationSession.objects.get(session_id=session_id)
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        if session.ventilator.serial_number==serial_number and workspace.workspace_id==session.workspace.workspace_id:
            patient = Patient.objects.get(patient_id=patient_id)
            if patient.workspace.workspace_id == workspace.workspace_id:
                session.patient = patient
                session.save()
                return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
        return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Unable to find the patient')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['POST'])
def save_monitoring_log(request):
    try:
        data = request.data
        session_id = data.get('session_id')
        STORAGE_DIR = os.path.join(settings.BASE_DIR, 'storage')
        print(STORAGE_DIR)
        try:
            session = VentilationSession.objects.get(session_id=session_id)
        except VentilationSession.DoesNotExist:
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Session not found")
        try:
            session_log = SessionLog.objects.get(sessions=session)
        except SessionLog.DoesNotExist:
            session_log = SessionLog.objects.create(sessions=session)
        for field in ['trend', 'alerts', 'events']:
            file_content = data.get(field)
            if file_content:
                filename = f"{session_id}_{field}.txt"
                file_path = os.path.join(STORAGE_DIR, filename)
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(file_content)
                setattr(session_log, field, file_path)
        session_log.save()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', data = "Success")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_monitoring_log(request, session_id, log_type):
    try:
        session = VentilationSession.objects.filter(session_id=session_id).first()
        if not session:
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Session not found")

        session_log = session.logs.first()
        if not session_log:
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Session log not found")

        file = getattr(session_log, log_type)
        if not file:
           return Response(status.HTTP_409_CONFLICT, ERROR_CODES.ENTITY_NOT_FOUND, "Session log not found")

        file_path = file.path
        if os.path.exists(file_path):
            return FileResponse(open(file_path, 'rb'), as_attachment=True, filename=os.path.basename(file_path))
        else:
            Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "File doesnot exists")

    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
def _check_elements(elements):
    return any(element == 'None' or element in ('NaN', 'Infinity', 'null') for element in elements)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_monitoring_log(request, session_id, log_type):
    try:
        session = VentilationSession.objects.filter(session_id=session_id).first()
        if not session:
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Session not found")

        session_log = session.logs.first()
        if not session_log:
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Session log not found")

        file = getattr(session_log, log_type)
        if not file or not os.path.isfile(file.path):
           return Response(status.HTTP_409_CONFLICT, ERROR_CODES.ENTITY_NOT_FOUND, "Session log not found")
        
        file_content = file.read().decode('utf-8')
        data_units = file_content.splitlines()
        if log_type in ["events", "alerts"]:
            data_units = [line for line in data_units if line]
            data_units = list(reversed(data_units))
        elif log_type == "trend":
            pip, peep, vti, compliance, minuteVolume, fio, pif, time = [], [], [], [], [], [], [], []
            for line in data_units:
                values = line.split('|')
                if not _check_elements(values):
                    pip.append(float(values[0]))
                    peep.append(float(values[1]))
                    vti.append(float(values[2]))
                    compliance.append(float(values[3]) if values[3] != 'null' else None)
                    minuteVolume.append(float(values[4]))
                    fio.append(float(values[5]))
                    pif.append(float(values[6]))
                    dt = datetime.strptime(values[7], "%Y-%m-%d %H:%M:%S.%f")
                    time.append(float(dt.timestamp() * 1000))
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "File content", {
                "pip":pip, 
                "peep":peep, 
                "vti":vti, 
                "compliance":compliance, 
                "minuteVolume":minuteVolume, 
                "fio":fio, 
                "pif":pif, 
                "time":time
            })    
        else:
            return Response(status.HTTP_409_CONFLICT, ERROR_CODES.ENTITY_NOT_FOUND, "Session log not found")
        
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "File content", data_units)

    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    