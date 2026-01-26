from django.contrib.auth.models import AnonymousUser
from channels.db import database_sync_to_async
from channels.middleware import BaseMiddleware
from rest_framework_simplejwt.tokens import UntypedToken
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser
from django.conf import settings
import jwt
from urllib.parse import parse_qs

@database_sync_to_async
def get_user(validated_token):
    try:
        user = get_user_model().objects.get(id=validated_token["user_id"])
        return user
    except get_user_model().DoesNotExist:
        return AnonymousUser()

class JwtAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        # Get query string
        query_string = scope.get("query_string", b"").decode("utf-8")
        query_params = parse_qs(query_string)
        token = query_params.get("token", [None])[0]

        if token:
            try:
                # 1. Verify token structure with UntypedToken (validates against SIMPLE_JWT settings)
                UntypedToken(token)
                
                # 2. Decode manually to get user_id (since we verified persistence above)
                # Note: SimpleJWT uses a secret key configuration. 
                # Ideally use jwt.decode with settings.SECRET_KEY via SimpleJWT's backend, 
                # but UntypedToken already validates content.
                # Let's extract payload cleanly.
                decoded_data = jwt.decode(token, options={"verify_signature": False})
                
                scope["user"] = await get_user(decoded_data)
                
            except (InvalidToken, TokenError, jwt.DecodeError) as e:
                # Invalid token
                scope["user"] = AnonymousUser()
        else:
             scope["user"] = AnonymousUser()

        return await super().__call__(scope, receive, send)
