# send_and_expire

https://www.updatafile.com/

# Architecture
1. Flutter
2. Django REST API

# Run local developement
1. Edit `enter_password_screen.html` and `constants.dart` URL from production to localhost
2. `docker-compose -f local.yml up`
3. Android studio browse `./frontend` directory and run

# Deploy production
1. Replace production url in `traefik.yml`
2. `cd frontend` and `flutter build web`
3. `docker-compose -f production build`
4. `docker-compose -f production up -d`

# Celerybeat
Set this schedule will appear in crontab at admin page.
```python
CELERY_BEAT_SCHEDULE = {
    # Execute every 60 seconds. Expire in 15 seconds if failed to start.
    'remove-instance': {
        'task': 'config.celery_app.delete_outdated_files',
        'schedule': 60.0,
        'options': {
            'expires': 15.0
        }
    }
}
```

# Comments
1. Delete URL need login since it must be able to identify the owner.
   Then designed use case is login first and then delete.
2. I decided to use `Traefik` to secure communication.
3. I use Django REST in order to scale from web, iOS, and Android.
4. In production it runs `gunicorn` to serve multiple request at a time.

