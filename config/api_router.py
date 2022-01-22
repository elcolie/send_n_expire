from django.conf import settings
from rest_framework.routers import DefaultRouter, SimpleRouter

from send_and_expire.upload.api.viewsets import UploadViewSet, DownloadViewSet, DeleteViewSet
from send_and_expire.users.api.views import SignupViewSet

if settings.DEBUG:
    router = DefaultRouter()
else:
    router = SimpleRouter()

# router.register("user", UserViewSet)
router.register("signup", SignupViewSet, basename="signup")
router.register("uploads", UploadViewSet, basename="upload")
router.register("downloads", DownloadViewSet, basename="download")
router.register("deletes", DeleteViewSet, basename="delete")

app_name = "api"
urlpatterns = router.urls
