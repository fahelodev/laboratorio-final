FROM node:19-alpine3.15

WORKDIR /reddit-clone

COPY . /reddit-clone
RUN npm install --legacy-peer-deps 

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Change ownership of workdir to non-root user
RUN chown -R nextjs:nodejs /reddit-clone

# Switch to non-root user
USER nextjs

EXPOSE 3000
CMD ["npm","run","dev"]
