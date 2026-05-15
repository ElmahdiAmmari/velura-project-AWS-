# Build from frontend/: docker build -t velura-frontend .
# Or via compose from infra/docker with context ../../frontend

FROM nginx:alpine

ARG AUTH_URL=http://localhost:5001
ARG CATALOG_URL=http://localhost:5002
ARG RENTAL_URL=http://localhost:5003
ARG ADMIN_URL=http://localhost:5004

COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod 644 /usr/share/nginx/html/index.html

RUN sed -i \
    "s|http://localhost:5001|${AUTH_URL}|g; \
     s|http://localhost:5002|${CATALOG_URL}|g; \
     s|http://localhost:5003|${RENTAL_URL}|g; \
     s|http://localhost:5004|${ADMIN_URL}|g" \
    /usr/share/nginx/html/index.html

EXPOSE 80
