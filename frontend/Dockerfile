FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .

# ← ADDED: receive the ALB URL at build time and bake it into the Next.js build
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

RUN npm run build

EXPOSE 3000

ENV NODE_ENV=production

CMD ["./node_modules/.bin/next", "start", "-p", "3000"]