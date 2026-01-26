from rest_framework import views, permissions, status
from rest_framework.response import Response
from livekit import api
import os

class LiveKitTokenView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        room_name = request.data.get('room_name')
        if not room_name:
             return Response({"error": "room_name is required"}, status=400)
             
        # Use user info for identity
        identity = request.user.username
        name = request.user.display_name or request.user.username
        
        # Get credentials from env
        api_key = os.environ.get('LIVEKIT_API_KEY', 'devkey')
        api_secret = os.environ.get('LIVEKIT_API_SECRET', 'secret')
        ws_url = os.environ.get('LIVEKIT_API_URL', 'wss://your-project.livekit.cloud')

        # Create access token
        token = api.AccessToken(api_key, api_secret) \
            .with_identity(identity) \
            .with_name(name) \
            .with_grants(api.VideoGrants(
                room_join=True,
                room=room_name,
            ))
            
        return Response({
            "token": token.to_jwt(),
            "url": ws_url,
            "room_name": room_name,
            "identity": identity
        })
