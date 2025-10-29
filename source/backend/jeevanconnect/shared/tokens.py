from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.utils.crypto import constant_time_compare
import six
import base64
import hashlib
import time


class GenericAuthTokenGenerator:
    def __init__(self, secret_key):
        self.secret_key = secret_key

    def make_token(self, obj):
        timestamp = int(time.time())
        value = f"{obj.pk}{timestamp}{self.secret_key}"
        token = hashlib.sha256(value.encode()).hexdigest()
        token = base64.urlsafe_b64encode(token.encode()).decode().strip('=')
        return f"{obj.pk}:{timestamp}:{token}"

    def check_token(self, obj, token, expiration_seconds=86400):
        try:
            pk, ts , token = token.split(':')
            if str(obj.pk) != pk:
                return False
            ts = int(ts)
            current_timestamp = int(time.time())
            if current_timestamp - ts > expiration_seconds:
                return False
            return True
        except ValueError:
            return False

class ResetPasswordTokenGenerator(PasswordResetTokenGenerator):
    def _make_hash_value(self, user, timestamp):
        login_timestamp = '' if user.last_login is None else user.last_login.replace(microsecond=0, tzinfo=None)
        return (
            six.text_type(user.pk) + user.password +
            six.text_type(login_timestamp) + six.text_type(timestamp)
        )

password_reset_token = ResetPasswordTokenGenerator()
generic_auth_token = GenericAuthTokenGenerator(secret_key="0f6522fa8e878861cc2ff6b75e6303daaf1345ce")