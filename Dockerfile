# Use a stable Node image (change if your app is Python/Java)
FROM node:18-alpine

WORKDIR /app

# Copy package files first (better caching)
COPY package*.json ./

RUN npm install --production

# Copy source code
COPY . .

# Expose port (app port)
EXPOSE 3000

# Start application
CMD ["npm", "start"]

