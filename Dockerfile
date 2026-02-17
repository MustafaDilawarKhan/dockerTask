# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.13.12
FROM python:${PYTHON_VERSION}-slim as base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies (Node.js + npm for Pyright)
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# Install Pyright globally
RUN npm install -g pyright

# Create non-root user
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Install Python dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt

# Switch to non-root user
USER appuser

# Copy application source
COPY . .

# Expose port
EXPOSE 8010

# Start app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8010"]
