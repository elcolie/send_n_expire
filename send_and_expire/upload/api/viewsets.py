import logging
from rest_framework import viewsets, status, mixins
from rest_framework.response import Response
from rest_framework.settings import api_settings
from rest_framework.viewsets import GenericViewSet

from send_and_expire.upload.api.serializers import UploadSerializer, DownloadSerializer
from send_and_expire.upload.models import Upload

logger = logging.getLogger(__name__)


class UploadViewSet(mixins.CreateModelMixin,
                    GenericViewSet):
    """Upload file to server only."""
    queryset = Upload.objects.all()
    serializer_class = UploadSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        logger.info(serializer.data)

        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        serializer.save()


class DownloadViewSet(mixins.RetrieveModelMixin,
                      GenericViewSet):
    """
    Download url.

    Example:
    http://localhost:8000/api/downloads/e0e99592-4ee2-4d63-bc1b-78c966d584d9/
    """
    queryset = Upload.objects.all()
    serializer_class = DownloadSerializer
    lookup_field = 'download_url'
    lookup_url_kwarg = 'download_url'

    def retrieve(self, request, *args, **kwargs):
        instance: Upload = self.get_object()
        instance.max_downloads -= 1
        if instance.max_downloads == -1:
            instance.delete()
            return Response(data={
                'message': "File exceeds max_download and has been deleted."
            }, status=status.HTTP_204_NO_CONTENT)
        else:
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)


class DeleteViewSet(mixins.DestroyModelMixin, GenericViewSet):
    """
    Delete the instance using delete_url.

    DELETE '/api/deletes/a11342e4-7a70-40fd-9197-d7b465cccce3/'
    """
    queryset = Upload.objects.all()
    lookup_field = 'delete_url'
    lookup_url_kwarg = 'delete_url'
