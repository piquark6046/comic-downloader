# Use the official Ubuntu latest LTS base image
FROM ubuntu:latest

ARG ADGUARD_VERSION=4.3.13

# Install Node.js and npm
RUN apt update
RUN apt install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt install -y nodejs

# Set the working directory
WORKDIR /app

# Copy files.
COPY package.json ./
COPY LICENSE ./
COPY tsconfig.json ./
COPY index.ts ./
COPY README.md ./
COPY sources ./sources

# Install dependencies
RUN npm i

# Install Firefox
RUN apt install -y wget
RUN install -d -m 0755 /etc/apt/keyrings
RUN wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
RUN echo '' >> /etc/apt/preferences.d/mozilla
RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla
RUN echo 'Pin: origin packages.mozilla.org' >> /etc/apt/preferences.d/mozilla
RUN echo 'Pin-Priority: 1000' >> /etc/apt/preferences.d/mozilla
RUN apt update
RUN apt install -y firefox
# Install npm packages
RUN npm i -g geckodriver

# Download AdGuard Browser Extension
RUN wget https://addons.mozilla.org/firefox/downloads/file/4231905/adguard_adblocker-$ADGUARD_VERSION.xpi -O adguard.xpi

# Clean up
RUN rm -rf /var/cache/apt/**
RUN rm package-lock.json

# Run the application
ENTRYPOINT ["npm", "run", "start"]
