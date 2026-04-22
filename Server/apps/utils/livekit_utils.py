import os
from livekit import api
import datetime
from django.conf import settings

def generate_livekit_token(room_name, participant_identity, participant_name=None):
    """
    Generates an Access Token for a LiveKit room.
    """
    api_key = os.getenv('LIVEKIT_API_KEY')
    api_secret = os.getenv('LIVEKIT_API_SECRET')
    
    if not api_key or not api_secret:
        return None

    token = api.AccessToken(api_key, api_secret) \
        .with_identity(participant_identity) \
        .with_name(participant_name or participant_identity) \
        .with_grants(api.VideoGrants(
            room_join=True,
            room=room_name,
        ))
    
    # Token valid for 1 hour
    return token.to_jwt()

def get_appointment_room_name(appointment):
    """
    Generate a unique room name for an appointment.
    """
    return f"appointment_{appointment.id}"

def get_sos_room_name(sos_call):
    """
    Generate a unique room name for an SOS call.
    """
    return f"sos_{sos_call.id}"
