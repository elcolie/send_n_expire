from datetime import datetime, timezone
from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework import status
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.test import APIClient

from send_and_expire.upload.models import Upload

User = get_user_model()


class TestUpload(TestCase):
    """Test upload endpoint. Otherwise, I have to manually clicking them."""

    def setUp(self) -> None:
        self.user_a = User.objects.create(username="sarit")

    def _upload(self, client) -> Response:
        """Upload file."""
        with open('CAM01242.jpg', 'rb') as picture_file:
            data = {
                'password': "ThisIsPassword",
                'max_downloads': 100,
                'expire_date': "2013-01-29T12:34:56.000000Z",   # iso-8601
                'file': picture_file,
            }
            url = reverse('api:upload-list')
            return client.post(url, data=data, format='multipart')

    def test_upload_file_created_by(self) -> None:
        """Check that file is save with correct ownership."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        with open('CAM01242.jpg', 'rb') as picture_file:
            data = {
                'password': "ThisIsPassword",
                'max_downloads': 100,
                'expire_date': "2013-01-29T12:34:56.000000Z",   # iso-8601
                'file': picture_file,
            }
            url = reverse('api:upload-list')
            res = client.post(url, data=data, format='multipart')
            picture_file.seek(0)    # Because pointer is moved to end of file

            # Call the saved instance
            instance: Upload = Upload.objects.first()
            self.assertEqual(status.HTTP_201_CREATED, res.status_code)
            self.assertEqual(picture_file.read(), instance.file.read())
            self.assertEqual(self.user_a, instance.created_by)
            self.assertEqual(datetime(2013, 1, 29, 12, 34, 56, tzinfo=timezone.utc), instance.expire_date)
            self.assertIsNotNone(instance.download_url)
            self.assertIsNotNone(instance.delete_url)

    def test_download_file_given_url(self) -> None:
        """Download file with given download_url. Expect be able to download and max_downloads decreased."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        res = self._upload(client)

        url = reverse('api:download-detail', kwargs={'download_url': res.data['download_url']})
        res_get: Response = client.get(url)

        instance: Upload = Upload.objects.first()
        self.assertEqual(status.HTTP_200_OK, res_get.status_code)
        self.assertEqual(99, instance.max_downloads)


