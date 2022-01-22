from django.conf import settings
from rest_framework.routers import DefaultRouter, SimpleRouter

from send_and_expire.upload.api.viewsets import UploadViewSet, DownloadViewSet
from send_and_expire.users.api.views import UserViewSet

if settings.DEBUG:
    router = DefaultRouter()
else:
    router = SimpleRouter()

router.register("user.ymls", UserViewSet)
router.register("uploads", UploadViewSet, basename="upload")
router.register("downloads", DownloadViewSet, basename="download")

app_name = "api"
urlpatterns = router.urls
