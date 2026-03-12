FROM python:3.11-slim

ARG TARGETARCH
WORKDIR /app

# common deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl unzip wget gnupg ca-certificates fonts-liberation libnss3 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 libx11-xcb1 libxcomposite1 libasound2 libxdamage1 libxrandr2 \
    && rm -rf /var/lib/apt/lists/*

# Install browser: google-chrome on amd64, chromium on arm64/others
RUN set -eux; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
      wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux.gpg; \
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list; \
      apt-get update; \
      apt-get install -y --no-install-recommends google-chrome-stable; \
      rm -rf /var/lib/apt/lists/*; \
    else \
      apt-get update; \
      apt-get install -y --no-install-recommends chromium chromium-driver || apt-get install -y --no-install-recommends chromium-browser chromium-driver; \
      rm -rf /var/lib/apt/lists/*; \
    fi

COPY requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir webdriver-manager chromedriver-binary-auto

COPY . .

ENV CI=true \
    HEADLESS=true

CMD ["python", "main.py"]
