import os
import logging
from celery import Celery, shared_task

# set the default Django settings module for the 'celery' program.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.local")

app = Celery("send_and_expire")

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object("django.conf:settings", namespace="CELERY")

# Load task modules from all registered Django app configs.
app.autodiscover_tasks()

logger = logging.getLogger(__name__)


@shared_task
def debug_test(a: int, b: int) -> int:
    """Test connection between containers. debug.delay(1, 3)"""
    return a + b


@shared_task
def delete_outdated_files() -> None:
    """Delete outdated files or max_downloads is <= 0."""
    from datetime import datetime
    from django.db.models import Q
    from send_and_expire.upload.models import Upload
    qs = Upload.objects.filter(
        Q(max_downloads__lte=0) |
        Q(expire_date__lte=datetime.utcnow())
    )
    # Because Django does not delete file from filesystem automatically
    for instance in qs:
        instance.file.delete()
    logger.info(f"The server is going to delete {qs.count()} instances")
    qs.delete()
