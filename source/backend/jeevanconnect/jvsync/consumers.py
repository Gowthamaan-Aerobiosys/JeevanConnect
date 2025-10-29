from channels.generic.websocket import AsyncWebsocketConsumer
from asyncio import CancelledError
from channels.db import database_sync_to_async
from asgiref.sync import sync_to_async

import logging
import json

from product.models import Ventilator
from authentication.models import User, LoginInfo
from .models import VentilationSession
from .message_handler import MessageTypes

logger = logging.getLogger(__name__)

class UserConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        try:
            logger.info("Connecting User")
            self.user_id = self.scope['url_route']['kwargs']['id']
            self.session_key = self.scope['url_route']['kwargs']['key']
            self.user = await self.get_user()
            user_session = await self.get_session()
            if user_session is None or not user_session.is_active:
                logger.info("Unauth user")
                await self.close()
                return
            self.group_name = f"jeevan_{self.user_id}"
            await self.channel_layer.group_add(self.group_name, self.channel_name)
            logger.info("User group add complete")
            await self.accept()
            await self.send(text_data=json.dumps({
                "type": MessageTypes.TYPE_CONNECTION_ACCEPT,
                "data": self.group_name
            }))
            logger.info("User Connect complete")
        except CancelledError as error:
            logger.error("User Connection cancelled")
            logger.exception(error)
        except Exception as error:
            logger.error(f"Error during connection: {type(error)}", exc_info=True)
            await self.close()

    async def receive(self, text_data):
        try:
            logger.info(f"Received from {self.user} for {self.group_name}")
            message_json = json.loads(text_data)
            logger.info(f"Message: {message_json}")
        except json.JSONDecodeError:
            logger.error("Received invalid JSON")
        except Exception as error:
            logger.error(f"Error processing message: {type(error)}", exc_info=True)

    async def disconnect(self, close_code):
        try:
            logger.info(f"Disconnecting user {self.user}")
            if hasattr(self, 'group_name'):
                await self.channel_layer.group_discard(self.group_name, self.channel_name)
        except Exception as exception:
            logger.error(f"Error during user disconnection: {type(exception)}", exc_info=True)
        finally:
            # Ensure the connection is closed even if an error occurs
            await self.close()

    async def group_send_user(self, event):
        try:
            message = event.get("text", {})
            if isinstance(message, dict):
                message = json.dumps(message)
            await self.send(text_data=message)
        except Exception as error:
            logger.error(f"Error sending group message: {type(error)}", exc_info=True)
    
    @database_sync_to_async
    def get_user(self):
        user = None
        try:
            user = User.objects.get(user_id=self.user_id)
        except:
            user = None
        return user
    
    @database_sync_to_async
    def get_session(self):
        user_session = None
        try:
            user_session = LoginInfo.objects.get(session_key=self.session_key)
        except:
            user_session = None
        return user_session
    
class VentilatorConsumer(AsyncWebsocketConsumer):
    connections = {}
    async def connect(self):
        try:
            logger.info("Connecting ventilator")
            self.user_id = self.scope['url_route']['kwargs']['id']
            self.user = await self.get_user()
            self.serial_number = self.scope['url_route']['kwargs']['serial_number']
            self.secret_key = self.scope['url_route']['kwargs']['key']
            self.ventilator = await self.get_ventilator()
            if self.secret_key!=self.ventilator.secret_key:
                logger.info("Unauth device")
                await self.close()
                return
            self.group_name = f"jeevanlite_{self.serial_number}"
            if self.user is None:
                VentilatorConsumer.connections[self.serial_number] = self
            else:
                await self.channel_layer.group_add(self.group_name, self.channel_name)
                logger.info("Ventilator group add complete")
            await self.accept()
            await self.send(text_data=json.dumps({
                "type": MessageTypes.TYPE_CONNECTION_ACCEPT,
                "data": self.group_name
            }))
            if self.user is None:
                await self.set_activity_state(True)
            logger.info("Ventilator Connect complete")
        except CancelledError as error:
            logger.error("Ventilator Connection cancelled")
            logger.exception(error)
        except Exception as error:
            logger.error(f"Error during ventilator connection: {type(error)}", exc_info=True)
            await self.close()

    async def receive(self, text_data):
        try:
            if self.user is None:
                await self.channel_layer.group_send(self.group_name,{
                    "type":"group_send_ventilator",
                    "text": text_data,
                })
        except json.JSONDecodeError:
            logger.error("Received invalid JSON")
        except Exception as error:
            logger.error(f"Error processing message: {type(error)}", exc_info=True)
    
    @classmethod
    async def send_message_to_device(cls, serial_number, message):
        try:
            if isinstance(message, dict):
                message = json.dumps(message)
            if serial_number in cls.connections:
                await cls.connections[serial_number].send(text_data=message)
        except Exception as error:
            logger.error(f"Error sending group message: {type(error)}", exc_info=True)

    async def disconnect(self, close_code):
        try:
            logger.info(f"Disconnecting ventilator {self.channel_name}")
            if hasattr(self, 'group_name'):
                await self.channel_layer.group_discard(self.group_name, self.channel_name)
                if self.user is None:
                    await self.set_activity_state(False)
        except Exception as exception:
            logger.error(f"Error during ventilator disconnection: {type(exception)}", exc_info=True)
        finally:
            # Ensure the connection is closed even if an error occurs
            await self.close()

    async def group_send_ventilator(self, event):
        try:
            message = event.get("text", {})
            if isinstance(message, dict):
                message = json.dumps(message)
            await self.send(text_data=message)
        except Exception as error:
            logger.error(f"Error sending group message: {type(error)}", exc_info=True)
    
    @database_sync_to_async
    def get_ventilator(self):
        ventilator = None
        try:
            serial_number = self.serial_number.replace("_", "/")
            ventilator = Ventilator.objects.get(serial_number=serial_number)
        except:
            ventilator = None
        return ventilator
    
    @sync_to_async
    def set_activity_state(self, state):
        try:
            logger.info(f"Setting Ventilator Status to {state}")
            self.ventilator.is_online = state
            VentilationSession.objects.filter(ventilator=self.ventilator).update(is_active=False)
            self.ventilator.save()
            logger.info(f"Ventilator Status set to {self.ventilator.is_online}")
        except Exception as e:
            logger.error(f"Error setting ventilator status: {str(e)}")
            
    @database_sync_to_async
    def get_user(self):
        user = None
        try:
            user = User.objects.get(user_id=self.user_id)
        except:
            user = None
        return user