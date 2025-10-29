from django.contrib.sessions.models import Session
from django.utils import timezone

def close_all_sessions(user):
    user_sessions = Session.objects.filter(expire_date__gte=timezone.now())
    for session in user_sessions:
        session_data = session.get_decoded()
        if session_data.get('_auth_user_id') == str(user.id):
            session.delete()