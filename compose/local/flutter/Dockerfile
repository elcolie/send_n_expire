ARG PYTHON_VERSION=3.9-slim-bullseye

# define an alias for the specfic python version used in this file.
FROM python:${PYTHON_VERSION} as python
RUN mkdir -p /app
COPY ./frontend/build/web /web
CMD python -m http.server 8080 --directory /web
