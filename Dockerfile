# syntax=docker/dockerfile:1

ARG NODE_VERSION=20.11.0

FROM node:${NODE_VERSION}-alpine

ENV NODE_ENV=production

WORKDIR /usr/src/app

# Спочатку копіюємо package.json і package-lock.json для інсталяції залежностей
COPY package.json package-lock.json ./

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into
# into this layer.
RUN npm ci --omit=dev

# Run the application as a non-root user.
USER node

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]


