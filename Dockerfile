FROM node:19-alpine

WORKDIR /reddit-clone

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies with security fixes
RUN npm install --legacy-peer-deps --no-audit --progress=false \
    && npm cache clean --force

# Copy application code
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nextjs -u 1001 -G nodejs

# Change ownership of workdir to non-root user
RUN chown -R nextjs:nodejs /reddit-clone

# Remove unnecessary packages and clean up
RUN apk --no-cache del curl wget \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Switch to non-root user
USER nextjs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node --version || exit 1

EXPOSE 3000
CMD ["npm","run","dev"]
