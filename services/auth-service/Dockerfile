FROM node:20-alpine
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY src ./src

# Start the service
CMD ["node", "src/app.js"]
