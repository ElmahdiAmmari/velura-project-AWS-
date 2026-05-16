# Build from repository root: docker build -f services/rental/Dockerfile .

FROM python:3.11-slim AS builder

WORKDIR /build
COPY services/rental/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt
FROM python:3.11-slim

WORKDIR /app
ENV PYTHONPATH=/app

COPY --from=builder /install /usr/local

#  CORRECTION  : Met à jour les bibliothèques OS (libcap2, systemd, udev, etc.)
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*
    
# CORRECTION CRITIQUE : Éliminer les CVEs de l'image de base finale
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

COPY shared/ /app/shared/
COPY services/rental/ /app/

EXPOSE 5003
CMD ["python", "rental_service.py"]
