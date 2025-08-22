# Use the official Node.js runtime as the base image (Debian for full font support)
FROM node:18-bullseye

# Enable contrib repo for Microsoft fonts
RUN apt-get update && apt-get install -y --no-install-recommends wget gnupg && \
    echo "deb http://deb.debian.org/debian/ bullseye contrib" >> /etc/apt/sources.list

# Install necessary packages for Sharp and font rendering
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fontconfig \
    fonts-dejavu \
    fonts-liberation \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-crosextra-carlito \
    fonts-crosextra-caladea \
    ttf-mscorefonts-installer \
    libcairo2 \
    libpango-1.0-0 \
    libglib2.0-0 \
    && fc-cache -fv && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy the rest of the application code
COPY . .


# Create a non-root user and group to run the application (Debian/Ubuntu syntax)
RUN groupadd -g 1001 nodejs && \
    useradd -m -u 1001 -g nodejs nextjs

# Change ownership of the app directory to the nodejs user
RUN chown -R nextjs:nodejs /app
USER nextjs

# Expose the port the app runs on
EXPOSE 9000

# Define the command to run the application
CMD ["npm", "start"]
