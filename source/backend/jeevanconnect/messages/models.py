from django.db import models
import os
from django.conf import settings

import uuid

from authentication.models import User    


class Conversation(models.Model):
    user1 = models.ForeignKey(User, on_delete=models.CASCADE, related_name="user1")
    user2 = models.ForeignKey(User, on_delete=models.CASCADE, related_name="user2")
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False, unique=True)
    last_modified = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ('last_modified',)
    
class Message(models.Model):
    content = models.TextField(max_length=4095)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages', null=True, blank=True, default=None)
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name="sender")
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name="receiver")
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False, unique=True)
    seen = models.BooleanField(default=False)
    timestamp = models.DateTimeField(auto_now_add=True)
    file_message = models.FileField(blank=True, null=True, default=None, upload_to= os.path.join(settings.BASE_DIR, 'media'))

    def __str__(self):
        return "Message from {} to {}: {}".format(self.sender.user_id, self.receiver.user_id, self.content)
    
    class Meta:
        ordering = ('timestamp',)