# Build from repository root: docker build -f services/auth/Dockerfile .

FROM python:3.11-slim AS builder

WORKDIR /build
COPY services/auth/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim

WORKDIR /app
ENV PYTHONPATH=/app

COPY --from=builder /install /usr/local
COPY shared/ /app/shared/
COPY services/auth/ /app/

EXPOSE 5001
CMD ["python", "auth_service.py"]
