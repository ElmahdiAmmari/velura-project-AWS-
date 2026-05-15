# Build from repository root: docker build -f services/catalog/Dockerfile .

FROM python:3.11-slim AS builder

WORKDIR /build
COPY services/catalog/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt
FROM python:3.11-slim

WORKDIR /app
ENV PYTHONPATH=/app

COPY --from=builder /install /usr/local
COPY shared/ /app/shared/
COPY services/catalog/ /app/

EXPOSE 5002
CMD ["python", "catalog_service.py"]
