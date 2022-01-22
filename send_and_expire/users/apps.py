from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class UsersConfig(AppConfig):
    name = "send_and_expire.users"
    verbose_name = _("Users")

    def ready(self):
        try:
            import send_and_expire.users.signals  # noqa F401
        except ImportError:
            pass
