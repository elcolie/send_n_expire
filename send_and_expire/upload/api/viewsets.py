import logging

from django.db.models import QuerySet
from django.http import FileResponse
from django.template.response import TemplateResponse
from rest_framework import status, mixins
from rest_framework.response import Response
from rest_framework.viewsets import GenericViewSet

from send_and_expire.upload.api.serializers import UploadSerializer, DownloadSerializer, ListSerializer
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
    authentication_classes = ()
    permission_classes = ()
    queryset = Upload.objects.all()
    serializer_class = DownloadSerializer
    lookup_field = 'download_url'
    lookup_url_kwarg = 'download_url'

    def retrieve(self, request, *args, **kwargs):
        instance: Upload = self.get_object()
        if instance.password is not None:
            # Password is required here
            password = request.query_params.get('password')
            if password != instance.password:
                return TemplateResponse(request, 'enter_password_screen.html', {'download_url': instance.download_url})
        instance.max_downloads -= 1
        if instance.max_downloads == -1:
            instance.delete()
            return Response(data={
                'message': "File exceeds max_download and has been deleted."
            }, status=status.HTTP_204_NO_CONTENT)
        else:
            instance.save()
            response = FileResponse(
                instance.file
            ,status=status.HTTP_200_OK)
            response['Content-Disposition'] = f'attachment; filename={instance.original_name}'
            return response


class ListUploadViewSet(mixins.ListModelMixin,
                        GenericViewSet):
    queryset = Upload.objects.all()
    serializer_class = ListSerializer

    def get_queryset(self) -> QuerySet:
        return self.queryset.filter(
            created_by=self.request.user
        )


class DeleteViewSet(mixins.DestroyModelMixin, GenericViewSet):
    """
    Delete the instance using delete_url.

    DELETE '/api/deletes/a11342e4-7a70-40fd-9197-d7b465cccce3/'
    """
    queryset = Upload.objects.all()
    lookup_field = 'delete_url'
    lookup_url_kwarg = 'delete_url'

    def get_queryset(self) -> QuerySet:
        return super().get_queryset().filter(created_by=self.request.user)

    def perform_destroy(self, instance):
        instance.file.delete()
        instance.delete()
