from django.contrib.auth import get_user_model
from django.contrib.auth.backends import ModelBackend
from django.db.models import Q

class EmailOrUsernameModelBackend(ModelBackend):
    """
    Authentication backend that allows a user to login with either their
    username or email address.
    """
    def authenticate(self, request, username=None, password=None, **kwargs):
        User = get_user_model()
        
        if username is None:
            username = kwargs.get(User.USERNAME_FIELD)
            
        try:
            # Check if the username matches username or email
            user = User.objects.get(Q(username__iexact=username) | Q(email__iexact=username))
        except User.DoesNotExist:
            return None
        except User.MultipleObjectsReturned:
            # If multiple users have the same email (shouldn't happen with unique=True), 
            # pick the first one or fail. Safest is to fail or order by id.
            return User.objects.filter(Q(username__iexact=username) | Q(email__iexact=username)).order_by('id').first()

        if user.check_password(password) and self.user_can_authenticate(user):
            return user
        return None
