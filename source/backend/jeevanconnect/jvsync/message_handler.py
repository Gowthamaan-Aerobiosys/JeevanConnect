import logging, json
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

logger = logging.getLogger(__name__)

class MessageTypes():
    TYPE_VENTILATOR_MESSAGE = "ventilator_message"
    TYPE_CONNECTION_ACCEPT = "connection_accept"
    TYPE_NEW_CHAT = "new_chat"

class MessageHandler():
    @staticmethod 
    def pushMessage(messageType,messageJson,userIDS):
        try:
            layer = get_channel_layer()
            typedMessage = {}
            typedMessage["type"] = messageType
            typedMessage["data"] = messageJson
            message = json.dumps(typedMessage)
            for userID in userIDS:
                async_to_sync(layer.group_send)('jeevan_'+str(userID), {
                    'type': 'group_send_user',
                    'text': message
                })
                
        except Exception as e:
            logger.error(e)