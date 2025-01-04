FROM node:23.5-alpine3.21

# Set working directory
WORKDIR /home/app

# Add non-root user
RUN addgroup -S app && \
    adduser -S -G app app && \
    chown -R app:app /home/app && \
    # Ensure WORKDIR is owned by app user
    chown -R app:app .

# Copy package files first to leverage cache
COPY --chown=app:app package*.json ./

# Install dependencies including dev dependencies
# Keep as root user during npm install to avoid permission issues
RUN npm ci && \
    npm cache clean --force && \
    # Fix ownership of node_modules after install
    chown -R app:app /home/app/node_modules

# Switch to non-root user
USER app

# Copy application code
COPY --chown=app:app . .

# Document the port that will be exposed
EXPOSE 3000

# Use array syntax for CMD
CMD ["npm", "start"]
