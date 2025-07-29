# Use the official Node.js runtime as the base image
FROM node:18-alpine

# Install necessary packages for Sharp and font rendering
RUN apk add --no-cache \
    fontconfig \
    font-noto \
    font-noto-cjk \
    font-noto-emoji \
    ttf-dejavu \
    ttf-liberation \
    ttf-opensans \
    cairo \
    pango \
    glib \
    && fc-cache -fv

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy the rest of the application code
COPY . .

# Create a non-root user to run the application
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Change ownership of the app directory to the nodejs user
RUN chown -R nextjs:nodejs /app
USER nextjs

# Expose the port the app runs on
EXPOSE 9000

# Define the command to run the application
CMD ["npm", "start"]
