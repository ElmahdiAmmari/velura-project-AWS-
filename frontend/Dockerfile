# Build from frontend/: docker build -t velura-frontend .
# Or via compose from infra/docker with context ../../frontend

FROM nginx:alpine

ARG AUTH_URL
ARG CATALOG_URL
ARG RENTAL_URL
ARG ADMIN_URL

COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod 644 /usr/share/nginx/html/index.html

RUN sed -i \
    "s|%FRONTEND_AUTH_URL%|${AUTH_URL}|g; \
     s|%FRONTEND_CATALOG_URL%|${CATALOG_URL}|g; \
     s|%FRONTEND_RENTAL_URL%|${RENTAL_URL}|g; \
     s|%FRONTEND_ADMIN_URL%|${ADMIN_URL}|g" \
    /usr/share/nginx/html/index.html

EXPOSE 80
