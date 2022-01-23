from django.contrib import admin

from send_and_expire.upload.models import Upload


class UploadAdmin(admin.ModelAdmin):
    __basic_fields = [
        'id',
        'file',
        'password',
        'max_downloads',
        'expire_date',
        'created_by',
        'created_at',
        'download_url',
        'delete_url',
    ]
    list_display = __basic_fields
    list_display_links = __basic_fields


admin.site.register(Upload, UploadAdmin)
