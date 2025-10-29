from django.core.mail import EmailMessage

class Mailer():
    
    def __init__(self):
        pass
    
    def send_email(self, to, subject, message, content_type):
        email = EmailMessage(subject, message, to=to)
        email.content_subtype = content_type
        email.send()

jc_mailer = Mailer()