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

