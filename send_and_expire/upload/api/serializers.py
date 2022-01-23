import uuid
import typing as typ
from rest_framework import serializers
from rest_framework.exceptions import ValidationError

from send_and_expire.upload.models import Upload
from django.conf import settings


def file_size(value):
    if value.size > settings.UPLOAD_SIZE_LIMIT:
        raise ValidationError("File too large. Size should not exceed 100 MiB")


class UploadSerializer(serializers.ModelSerializer):
    created_by = serializers.HiddenField(
        default=serializers.CurrentUserDefault()
    )
    file = serializers.FileField(required=True, validators=[file_size])

    class Meta:
        model = Upload
        fields = [
            'file',
            'password',
            'max_downloads',
            'expire_date',
            'created_by',
            'download_url',
            'delete_url',
        ]
        extra_kwargs = {
            'password': {'write_only': True},
            'download_url': {'read_only': True},
            'delete_url': {'read_only': True},
        }

    def create(self, validated_data: typ.Dict) -> Upload:
        instance = super().create(validated_data)
        instance.download_url = str(uuid.uuid4())
        instance.delete_url = str(uuid.uuid4())
        instance.save()
        return instance


class DownloadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Upload
        fields = [
            'file',
        ]


class ListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Upload
        fields = [
            'file',
            'password',
            'max_downloads',
            'expire_date',
            'download_url',
            'delete_url',
        ]
