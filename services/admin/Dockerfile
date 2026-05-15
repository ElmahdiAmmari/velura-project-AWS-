# Build from repository root: docker build -f services/admin/Dockerfile .

FROM python:3.11-slim AS builder

WORKDIR /build
COPY services/admin/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim

WORKDIR /app
ENV PYTHONPATH=/app

COPY --from=builder /install /usr/local
COPY shared/ /app/shared/
COPY services/admin/ /app/

EXPOSE 5004
CMD ["python", "admin_service.py"]
