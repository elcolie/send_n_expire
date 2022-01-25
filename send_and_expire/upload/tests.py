import datetime as dt
from datetime import datetime, timezone
from django.contrib.auth import get_user_model
from django.test import TestCase
from freezegun import freeze_time
from model_bakery import baker
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

    def _upload(self, client, max_downloads=100) -> Response:
        """Upload file."""
        with open('CAM01242.jpg', 'rb') as picture_file:
            data = {
                'password': "ThisIsPassword",
                'max_downloads': max_downloads,
                'expire_date': "2013-01-29T12:34:56.000000Z",   # iso-8601
                'file': picture_file,
            }
            url = reverse('api:upload-list')
            return client.post(url, data=data, format='multipart')

    def test_upload_file_created_by(self) -> None:
        """Check that file is saved with correct ownership."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        filename = 'CAM01242.jpg'
        with open(filename, 'rb') as picture_file:
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
            self.assertEqual(filename, instance.original_name)
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

    def test_delete_file_given_delete_url(self) -> None:
        """Delete file using delete_url."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        res = self._upload(client)

        url = reverse('api:delete-detail', kwargs={'delete_url': res.data['delete_url']})
        res_delete: Response = client.delete(url)
        self.assertEqual(status.HTTP_204_NO_CONTENT, res_delete.status_code)
        self.assertEqual(0, Upload.objects.count())

    def test_1_max_download(self) -> None:
        """Delete instance when max_download is 0."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        res = self._upload(client, max_downloads=1)

        # Download 1 time
        url = reverse('api:download-detail', kwargs={'download_url': res.data['download_url']})
        res_get: Response = client.get(url)

        instance: Upload = Upload.objects.first()
        # Expect instance is present since it is last instance
        self.assertEqual(status.HTTP_200_OK, res_get.status_code)
        self.assertEqual(1, Upload.objects.count())
        # Expect it has 0 max_downloads
        self.assertEqual(0, instance.max_downloads)

    def test_zero_max_download(self) -> None:
        """Use will not be able to download it and instance will be deleted."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        res = self._upload(client, max_downloads=0)

        # Download 1 time
        url = reverse('api:download-detail', kwargs={'download_url': res.data['download_url']})
        res_get: Response = client.get(url)

        # Expect instance is present since it is last instance
        self.assertEqual(status.HTTP_204_NO_CONTENT, res_get.status_code)
        self.assertEqual(
            {'message': 'File exceeds max_download and has been deleted.'},
            res_get.data
        )
        self.assertEqual(0, Upload.objects.count())

    def test_model_mommy_make(self) -> None:
        """Test against this model because it has FileField. And I am new to this tool."""
        _ = baker.make(Upload, max_downloads=100)
        _ = baker.make(Upload, max_downloads=10)
        first_instance: Upload = Upload.objects.first()
        last_instance: Upload = Upload.objects.last()
        self.assertEqual(2, Upload.objects.count())
        self.assertEqual(100, first_instance.max_downloads)
        self.assertEqual(10, last_instance.max_downloads)

    def test_delete_lte_0_max_downloads(self) -> None:
        """Test query and delete."""
        _ = baker.make(Upload, max_downloads=3)
        _ = baker.make(Upload, max_downloads=2)
        _ = baker.make(Upload, max_downloads=1)
        _ = baker.make(Upload, max_downloads=0)
        _ = baker.make(Upload, max_downloads=-1)
        Upload.objects.filter(max_downloads__lte=0).delete()
        self.assertEqual(3, Upload.objects.count())

    def test_delete_expired_instances(self) -> None:
        """Test delete expired instances."""
        import time
        today = datetime.utcnow()
        delta_2_sec = dt.timedelta(seconds=2)
        delta_5_min = dt.timedelta(minutes=5)
        delta_1_hr = dt.timedelta(hours=1)
        delta_1_day = dt.timedelta(days=1)
        delta_7_days = dt.timedelta(days=7)

        _ = baker.make(Upload, max_downloads=5, expire_date=today + delta_2_sec)
        _ = baker.make(Upload, max_downloads=4, expire_date=today + delta_5_min)
        _ = baker.make(Upload, max_downloads=3, expire_date=today + delta_1_hr)
        _ = baker.make(Upload, max_downloads=2, expire_date=today + delta_1_day)
        _ = baker.make(Upload, max_downloads=1, expire_date=today + delta_7_days)
        print("sleep 3 sec")
        time.sleep(3)
        later_time = datetime.utcnow()
        queryset = Upload.objects.filter(expire_date__lte=later_time)

        # Expect 1 instance expire and will be deleted
        self.assertEqual(1, queryset.count())

    def test_list_upload_permission(self) -> None:
        """Authenticated user will be able to list upload."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        non_auth_client = APIClient()
        url = reverse('api:list-list')
        res: Response = client.get(url)
        non_auth_res: Response = non_auth_client.get(url)
        self.assertEqual(status.HTTP_200_OK, res.status_code)
        self.assertEqual(status.HTTP_403_FORBIDDEN, non_auth_res.status_code)

    def test_delete_file_by_owner(self) -> None:
        """Delete file by owner."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        self._upload(client)
        instance: Upload = Upload.objects.first()
        url = reverse('api:delete-detail', kwargs={'delete_url': instance.delete_url})
        res = client.delete(url)
        self.assertEqual(status.HTTP_204_NO_CONTENT, res.status_code)
        self.assertEqual(0, Upload.objects.count())

    def test_delete_file_by_other(self) -> None:
        """Delete file by others."""
        client = APIClient()
        client.force_authenticate(user=self.user_a)
        self._upload(client)
        instance: Upload = Upload.objects.first()
        url = reverse('api:delete-detail', kwargs={'delete_url': instance.delete_url})
        client_2 = APIClient()
        res = client_2.delete(url)
        self.assertEqual(status.HTTP_403_FORBIDDEN, res.status_code)
        self.assertEqual(1, Upload.objects.count())
