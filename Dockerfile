FROM python:3.11-slim

ARG TARGETARCH
WORKDIR /app

# Playwright/Chrome runtime deps.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl fonts-liberation gnupg wget \
       libasound2 libatk-bridge2.0-0 libatk1.0-0 libcups2 libdbus-1-3 \
       libdrm2 libgbm1 libgtk-3-0 libnspr4 libnss3 libx11-xcb1 \
       libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 \
    && rm -rf /var/lib/apt/lists/*

# Install browser: Google Chrome on amd64, Chromium on arm64/others.
RUN set -eux; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
      wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux.gpg; \
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list; \
      apt-get update; \
      apt-get install -y --no-install-recommends google-chrome-stable; \
      rm -rf /var/lib/apt/lists/*; \
      ln -sf /usr/bin/google-chrome /usr/bin/container-browser; \
    else \
      apt-get update; \
      apt-get install -y --no-install-recommends chromium || apt-get install -y --no-install-recommends chromium-browser; \
      rm -rf /var/lib/apt/lists/*; \
      if command -v chromium >/dev/null 2>&1; then ln -sf "$(command -v chromium)" /usr/bin/container-browser; else ln -sf "$(command -v chromium-browser)" /usr/bin/container-browser; fi; \
    fi

COPY requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && python -m playwright install-deps chromium

COPY . .

ENV CI=true \
    HEADLESS=true \
    CHROME_BINARY_PATH=/usr/bin/container-browser

CMD ["python", "main.py"]
