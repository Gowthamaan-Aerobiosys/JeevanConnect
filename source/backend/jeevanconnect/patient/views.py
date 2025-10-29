from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status

from shared.response import *
from .models import Patient, AdmissionRecord, ABGReport, ClinicalAdvice
from .serializers import PatientSerializer, AdmissionRecordSerializer, ABGReportSerializer, ClinicalAdviceSerializer
from authentication.models import Workspace, User

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def register_patient(request):
    try:
        data = request.data
        patient_id = data['patient_id']
        workspace_id = data['workspace_id']
        pqs = Patient.objects.filter(patient_id=patient_id)
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_ALREADY_EXISTS, "Patient with that ID already exists")
        if not wqs.exists():
            return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        patient = Patient.objects.create(
            patient_id = patient_id,
            name = data['name'],
            gender = data['gender'],
            age = data['age'],
            blood_group = data.get('blood_group', None),
            contact =  data.get('contact', None),
            aadhar = data.get('aadhar', None),
            abha = data.get('abha', None),
            workspace = workspace
        )
        if patient is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't create patient. Try again later")
        else:
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Patient created successfully')
    except Exception as exception:
        print(exception)
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def archive_patient(request):
    try:
        data = request.data
        patient_id = data['patient_id']
        workspace_name = data['workspace_name']
        pqs = Patient.objects.filter(patient_id=patient_id)
        if not pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Patient with that ID does not exists")
        uemail = data['user']
        user = User.objects.get(email=uemail)
        workspace = Workspace.objects.get(name=workspace_name)
        if workspace.admins.filter(email=uemail).exists() or user.is_staff:
            patient = Patient.objects.filter(patient_id=patient_id)
            patient.active = False
            patient.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Archived patient successfully')
        return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Administrative permissions required to archive patient')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

def update_patient(request):
    pass

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_admission_record(request):
    try:
        data = request.data
        patient_id = data['patient_id']
        pqs = Patient.objects.filter(patient_id=patient_id)
        if not pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Patient with that ID does not exists")
        records = Patient.objects.get(patient_id=patient_id).visits
        serializer = AdmissionRecordSerializer(records, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_admission_record(request):
    try:
        data = request.data
        patient_id = data['patient_id']
        pqs = Patient.objects.filter(patient_id=patient_id)
        if not pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Patient with that ID does not exists")
        patient = Patient.objects.get(patient_id=patient_id)
        lqs = AdmissionRecord.objects.filter(patient=patient, is_discharged=False)
        if lqs.exists():
            return Response(status.HTTP_403_FORBIDDEN, ERROR_CODES.ENTITY_ALREADY_EXISTS, "Patient has a open admission record")
        record = AdmissionRecord.objects.create(
                patient = patient,
                height = data['height'],
                weight = data['weight'],
                bmi = data['bmi'],
                ibw = data['ibw'],
                admission_date = data['admission_date'],
                reason_for_admission = data['reason_for_admission'],
                reason_for_ventilation = data['reason_for_ventilation'],
                history_of_diabetes = data['history_of_diabetes'],
                tags = data['tags'],
                history_of_bp = data['history_of_bp'],
                current_status = data['current_status'],
        )
        if record is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't create record. Try again later")
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def remove_admission_record( request):
    try:
        data = request.data
        patient_id = request.data.get('patient_id')
        qs = Patient.objects.filter(patient_id=patient_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Patient with that ID doesn't exists") 
        indices = set(data['indices'].split(","))
        indices = set(map(int, indices))
        AdmissionRecord.objects.filter(id__in=indices).delete()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
def get_log(request, id):
    try:
        qs = AdmissionRecord.objects.filter(pk=id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Admission record not found")
        logs = AdmissionRecord.objects.get(id=id).clinical_advices
        serializer = ClinicalAdviceSerializer(logs, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_log( request):
    try:
        amr_id = request.data.get('amr_id')
        content = request.data.get('content')
        qs = AdmissionRecord.objects.filter(id=amr_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "AMR with that ID doesn't exists") 
        if not content:      
            return Response(status.HTTP_204_NO_CONTENT, ERROR_CODES.ENTITY_NOT_FOUND, "Log should have content")
        amr = AdmissionRecord.objects.get(id=amr_id)
        added_by = request.data.get('added_by')
        clinical_log = ClinicalAdvice.objects.create(record=amr, content=content, added_by=added_by)
        if clinical_log is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't create clinical log. Try again later")
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def remove_log( request):
    try:
        data = request.data
        amr_id = request.data.get('amr_id')
        qs = AdmissionRecord.objects.filter(id=amr_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "AMR with that ID doesn't exists") 
        index = request.data.get('index')
        ClinicalAdvice.objects.filter(id=index).delete()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_patients(request):
    try:
        patients = Patient.objects.all()
        serializer = PatientSerializer(patients, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_workspace_patients(request, workspace_id):
    try:
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        patients = Workspace.objects.get(workspace_id=workspace_id).patients
        serializer = PatientSerializer(patients, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_abg_records(request, id):
    try:
        qs = AdmissionRecord.objects.filter(pk=id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Admission record not found")
        abg_reports = AdmissionRecord.objects.get(id=id).abg_reports
        serializer = ABGReportSerializer(abg_reports, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_abg_record(request):
    try:
        amr_id = request.data.get('amr_id')
        qs = AdmissionRecord.objects.filter(id=amr_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "AMR with that ID doesn't exists") 
        record = AdmissionRecord.objects.get(id=amr_id)
        abg_log = ABGReport.objects.create(
            record=record,
            pH= request.data.get('pH'),
            pCO2= request.data.get('pCO2'),
            pO2= request.data.get('pO2'),
            hCO3= request.data.get('hCO3'),
            base_excess= request.data.get('base_excess'),
            sO2= request.data.get('sO2'),
            lactate= request.data.get('lactate', 0.0),
            comments= request.data.get('comments')
        )
        if abg_log is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't create abg log. Try again later")
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def remove_abg_record(request):
    try:
        data = request.data
        amr_id = request.data.get('amr_id')
        qs = AdmissionRecord.objects.filter(id=amr_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "AMR with that ID doesn't exists") 
        indices = set(data['indices'].split(","))
        indices = set(map(int, indices))
        record = AdmissionRecord.objects.get(id=amr_id)
        ABGReport.objects.filter(id__in=indices, record=record).delete()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
def get_abg_graph(request, id):
    try:
        qs = AdmissionRecord.objects.filter(pk=id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Admission record not found")
        abg_reports = AdmissionRecord.objects.get(id=id).abg_reports.all().order_by('created_at')
        graph_data = {
            'timestamps': [],
            'pH': [],
            'pCO2': [],
            'pO2': [],
            'hCO3': [],
            'base_excess': [],
            'sO2': [],
            'lactate': []
        }
        for report in abg_reports:
            graph_data['timestamps'].append(report.created_at.isoformat())
            graph_data['pH'].append(report.pH)
            graph_data['pCO2'].append(report.pCO2)
            graph_data['pO2'].append(report.pO2)
            graph_data['hCO3'].append(report.hCO3)
            graph_data['base_excess'].append(report.base_excess)
            graph_data['sO2'].append(report.sO2)
            graph_data['lactate'].append(report.lactate)
        stats = {}
        for key in ['pH', 'pCO2', 'pO2', 'hCO3', 'base_excess', 'sO2', 'lactate']:
            values = graph_data[key]
            if values:
                stats[key] = {
                    'min': min(values),
                    'max': max(values),
                    'avg': sum(values) / len(values)
                }
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', {
                'graph_data': graph_data,
                'stats': stats,
                'total_reports': len(abg_reports)
            })
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['POST'])
def get_current_admission_record(request):
    try:
        data = request.data
        patient_id = data['patient_id']
        pqs = Patient.objects.filter(patient_id=patient_id)
        if not pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Patient with that ID does not exists")
        records = Patient.objects.get(patient_id=patient_id).visits.order_by('-admission_date').first()
        serializer = AdmissionRecordSerializer(records, many=False)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})