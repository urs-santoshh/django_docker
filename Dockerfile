# Use Alpine Linux as the base image
FROM python:3.12.0b4-alpine3.18
LABEL maintainer="santoshtimalsina123.com.np"

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy the project files to the container
COPY ./requirements.txt ./requirements.txt
COPY ./app ./app

# Set the working directory inside the container
WORKDIR /app

# Expose the port on which the Django application will run
EXPOSE 8000

# Install system dependencies
# No system dependencies installation is required as Alpine Python image already includes necessary system packages.

# Create a virtual environment and install Python dependencies
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    # Install PostgreSQL client
    apk add --update --no-cache postgresql-client && \
    # Install additional system dependencies for PostgreSQL and other packages
    apk add --update --no-cache --virtual .tmp-deps \
        build-base postgresql-dev musl-dev linux-headers && \
    /py/bin/pip install -r /requirements.txt && \
    # Remove temporary build dependencies
    apk del .tmp-deps && \
    # Create a non-root user for running the application
    adduser --disabled-password --no-create-home app && \
    # Set the ownership of the application files to the non-root user
    chown -R app /app && \
    mkdir -p /vol/web/static && \
    mkdir -p /vol/web/media && \
    chown -R app:app /vol && \
    chmod -R 755 /vol

# Add the virtual environment to the PATH
ENV PATH="/py/bin:$PATH"

# Switch to the non-root user
USER app