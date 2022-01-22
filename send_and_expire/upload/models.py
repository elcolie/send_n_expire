from django.contrib.auth import get_user_model
from django.db import models
from django.urls import reverse

User = get_user_model()


class Upload(models.Model):
    file = models.FileField()
    password = models.CharField(max_length=255, blank=True, null=True)
    max_downloads = models.IntegerField(null=True)
    expire_date = models.DateTimeField(null=True)
    created_by = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    download_url = models.SlugField(max_length=255, unique=True)
    delete_url = models.SlugField(max_length=255, unique=True)

    def get_absolute_url(self):
        return reverse("download", args=(self.id,))
