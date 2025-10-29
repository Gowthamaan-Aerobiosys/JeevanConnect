from rest_framework.decorators import api_view
from rest_framework import status
from django.http import FileResponse
import os
from django.conf import settings

from shared.response import *

@api_view(['GET'])
def view_file(request, file_name):
    try:
        file_path = os.path.join(os.path.join(settings.BASE_DIR, 'media'), file_name)
        return FileResponse(open(file_path, 'rb'), as_attachment=True, filename=os.path.basename(file_path))
    except Exception as exception:
        return Response(status.HTTP_500_INTERNAL_SERVER_ERROR, ERROR_CODES.INTERNAL_ERROR, 'Unexpected error', data={'exception': exception})