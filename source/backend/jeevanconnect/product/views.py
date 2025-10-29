from django.contrib.sites.shortcuts import get_current_site
from django.template.loader import get_template
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework import status

from shared.response import *
from .models import Ventilator, ServiceTicket, ServiceLog
from shared.mailer import jc_mailer
from .serializers import VentilatorSerializer, ServiceTicketSerializer, ServiceLogSerializer
from authentication.models import Workspace, User

@api_view(['POST'])
def register_ventilator(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        pqs = Ventilator.objects.filter(serial_number=serial_number)
        if pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_ALREADY_EXISTS, "Product with that Serial number already exists")
        product = Ventilator.objects.register(
            product_name=data['product_name'], 
            model_name=data['model_name'], 
            serial_number=data['serial_number'], 
            lot_number=data['lot_number'],   
            manufactured_on=data['manufactured_on'], 
            software_version=data['software_version'], 
            battery_serial_number=data['battery_serial_number'], 
            battery_manufacturing_date=data['battery_manufacturing_date'],
        )
        if product is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't register product. Try again later")
        else:
            serializer = VentilatorSerializer(product, many=False)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Product registered successfully', serializer.data)
    except Exception as exception:
        print(exception)
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def archive_product(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        qs = Ventilator.objects.filter(serial_number=serial_number)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that Serial number is not found")
        uemail = data['user']
        wemail = data['workspace']
        user = User.objects.get(email=uemail)
        workspace = Workspace.objects.get(email=wemail)
        if workspace.admins.filter(email=uemail).exists() or user.is_staff:
            product = qs.first
            product.active = False
            product.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Archived product successfully')
        return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Administrative permissions required to archive product')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
def add_product_to_workspace(request):
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
        workspace_id = data['workspace_id']
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        stage = data['stage']
        if stage=='1':
            pass_key = data['pass_key']
            return product_mailer(mail_type=1, request=request, kwargs={
                'pass_key': pass_key,
                'user': workspace.default_user.get_full_name(),
                'product': ventilator.serial_number,
                'workspace': workspace.name,
                'email': workspace.default_user.email
            })
        elif stage=='2':
            ventilator.workspace = workspace
            ventilator.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Product added to workspace successfully', {
                'workspace_name':workspace.name,
                'workspace_id':workspace.workspace_id
            })
        return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, "Invalid request")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
def remove_product_from_workspace(request):
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
        workspace_id = data['workspace_id']
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        workspace = Workspace.objects.get(workspace_id=workspace_id)
        stage = data['stage']
        if stage=='1':
            pass_key = data['pass_key']
            return product_mailer(mail_type=2, request=request, kwargs={
                'pass_key': pass_key,
                'user': workspace.default_user.get_full_name(),
                'product': ventilator.serial_number,
                'workspace': workspace.name,
                'email': workspace.default_user.email
            })
        elif stage=='2':
            ventilator.workspace = None
            ventilator.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Product removed from workspace successfully')
        return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, "Invalid request")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_product(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        wemail = data['workspace']
        pqs = Ventilator.objects.filter(serial_number=serial_number)
        wqs = Workspace.objects.filter(email=wemail)
        if not pqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that Email address is not found")
        if not wqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        uemail = data['user']
        user = User.objects.get(email=uemail)
        workspace = Workspace.objects.get(email=wemail)
        product = pqs.first
        if (workspace.admins.filter(email=uemail).exists() or user.is_staff) and workspace==product.workspace:
            product = VentilatorSerializer(data=data)
            if product.is_valid():
                product.save()
                return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Product updated successfully')
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't update product. Try again later")
        return Response(status.HTTP_409_CONFLICT, ERROR_CODES.CONFLICT, 'Administrative permissions required to remove product')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def getVentilators(request):
    try:
        products = Ventilator.objects.all()
        serializer = VentilatorSerializer(products, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def getVentilator(request):
    try:
        serial_number = request.data["serial_number"]
        products = Ventilator.objects.get(serial_number=serial_number)
        serializer = VentilatorSerializer(products, many=False)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})
    
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def getWorkspaceVentilators(request, workspace_id):
    try:
        wqs = Workspace.objects.filter(workspace_id=workspace_id)
        if not wqs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Workspace with that Email address is not found")
        products = Workspace.objects.get(workspace_id=workspace_id).ventilators
        serializer = VentilatorSerializer(products, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request Successful", serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
def book_service_ticket(request):
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
        if not ServiceTicket.can_create_new_ticket(ventilator):
            return Response(status.HTTP_409_CONFLICT, ERROR_CODES.ENTITY_ALREADY_EXISTS, "Service ticket booked already")
        length = ServiceTicket.objects.count()+1
        ticket_id = f"JL-ST-{length:06d}"
        ticket = ServiceTicket.objects.create(
            ventilator = ventilator,
            ticket_id = ticket_id
        )
        if ticket is None:
            return Response(status.HTTP_503_SERVICE_UNAVAILABLE, ERROR_CODES.SERVICE_UNAVAILABLE, "Couldn't book a ticket. Try again later")
        log = ServiceLog.objects.create(service_ticket=ticket, content = "Service ticket booked successfully")
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Service ticket created successfully')
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_service_logs(request, ticket_id):
    try:
        qs = ServiceTicket.objects.filter(ticket_id=ticket_id)
        if not qs.exists():
            return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Service ticket not found")
        logs = ServiceTicket.objects.get(ticket_id=ticket_id).logs
        serializer = ServiceLogSerializer(logs, many=True)
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def get_service_tickets(request):
    try:
        data = request.data
        serial_number = data['serial_number']
        qs = Ventilator.objects.filter(serial_number=serial_number)
        if qs.exists():
            ventilator = Ventilator.objects.get(serial_number=serial_number)
            tickets = ServiceTicket.objects.filter(ventilator=ventilator)
            serializer = ServiceTicketSerializer(tickets, many=True)
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Request successful', serializer.data)
        return Response(status.HTTP_404_NOT_FOUND, ERROR_CODES.ENTITY_NOT_FOUND, "Product with that serial number is not found")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def edit_department(request):
    try:
        data = request.data
        serial_number = data["serial_number"]
        qs = Ventilator.objects.filter(serial_number=serial_number)
        if qs.exists():
            ventilator = Ventilator.objects.get(serial_number=serial_number)
            department = data["department"]
            ventilator.department = department
            ventilator.save()
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request successful")
        return Response(status.HTTP_400_BAD_REQUEST, ERROR_CODES.ENTITY_NOT_FOUND, "Device with that serial number doesn't exists")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

@api_view(['POST'])
def update_device_location(request):
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
        
        location = data['location']
        ventilator.location = location
        ventilator.save()
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, "Request successful")
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})

def product_mailer(mail_type, request, **kwargs):
    current_site = get_current_site(request)
    try:
        if mail_type==1:
            subject = 'Add Product to Workspace - JeevanConnect'
            pass_key = kwargs['kwargs']['pass_key']
            email = kwargs['kwargs']['email']
            user = kwargs['kwargs']['user']
            product = kwargs['kwargs']['product']
            workspace = kwargs['kwargs']['workspace']
            context = {
                'pass_key': pass_key,
                'domain': current_site.domain,
                'user': user,
                'product': product,
                'workspace': workspace
            }
            message = get_template('mail/product/add_to_workspace.html').render(context)
            jc_mailer.send_email(to=[email], subject=subject, message=message, content_type='html')
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Add product to workspace mail sent')
        
        elif mail_type==2:
            subject = 'Remove Product from Workspace - JeevanConnect'
            pass_key = kwargs['kwargs']['pass_key']
            email = kwargs['kwargs']['email']
            user = kwargs['kwargs']['user']
            product = kwargs['kwargs']['product']
            workspace = kwargs['kwargs']['workspace']
            context = {
                'pass_key': pass_key,
                'domain': current_site.domain,
                'user': user,
                'product': product,
                'workspace': workspace
            }
            message = get_template('mail/product/remove_from_workspace.html').render(context)
            jc_mailer.send_email(to=[email], subject=subject, message=message, content_type='html')
            return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, 'Remove product from workspace mail sent')
        return Response(status.HTTP_200_OK, SUCCESS_CODES.SUCCESS, '')

    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})