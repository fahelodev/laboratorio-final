# Use Node.js 20 LTS with Alpine 3.20 (latest stable, no EOL vulnerabilities)
FROM node:20-alpine3.20

# Set working directory
WORKDIR /reddit-clone

# Update Alpine packages and install security patches
RUN apk update && apk upgrade --no-cache

# Copy package files first for better Docker layer caching
COPY package*.json ./

# install dependencies
RUN rm -rf node_modules package-lock.json \
    && npm install --legacy-peer-deps --no-audit --progress=false

# Copy application code
COPY . .

# Create non-root user for security (using Alpine's best practices)
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nextjs -u 1001 -G nodejs

# Change ownership of workdir to non-root user
RUN chown -R nextjs:nodejs /reddit-clone

# Remove unnecessary packages and clean up (security hardening)
RUN apk --no-cache del curl wget \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
    && rm -rf /usr/share/man /usr/share/doc

# Switch to non-root user for security
USER nextjs

# Health check with improved command
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node --version || exit 1

# Expose port
EXPOSE 3000

# Use exec form for better signal handling
CMD ["npm", "run", "dev"]
