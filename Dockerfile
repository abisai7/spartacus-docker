# Dockerfile for Self-Publishing Spartacus Libraries with Verdaccio
# This image builds Spartacus libraries from source and serves them via Verdaccio

# Use Node.js LTS version (adjust based on Spartacus version requirements)
FROM node:18-alpine

# Set working directory
WORKDIR /spartacus-build

# Install git and other necessary tools
RUN apk add --no-cache git bash curl expect

# Install global dependencies
RUN npm install -g ts-node verdaccio@4

# Clone Spartacus repository
ARG SPARTACUS_VERSION=release/2211.40.x
RUN git clone https://github.com/SAP/spartacus.git . && \
    git checkout ${SPARTACUS_VERSION}

# Install dependencies and build libraries
RUN npm install && npm run build:libs

# Run schematics testing script to prepare libraries
# Uncomment the following line if schematics testing is required, 
# but it may take additional time
# RUN ts-node ./tools/schematics/testing.ts

# Create Verdaccio config directory
RUN mkdir -p /verdaccio/storage /verdaccio/conf

# Copy Verdaccio configuration
COPY verdaccio-config.yaml /verdaccio/conf/config.yaml

# Copy and setup startup script
COPY start-verdaccio.sh /usr/local/bin/start-verdaccio.sh
RUN chmod +x /usr/local/bin/start-verdaccio.sh

# Expose Verdaccio port
EXPOSE 4873

# Set the startup command
CMD ["/usr/local/bin/start-verdaccio.sh"]
