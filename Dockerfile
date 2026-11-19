FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=UTC \
    HOST=0.0.0.0 \
    PORT=8788

WORKDIR /app

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY wb_*.py ./
COPY dashboard.html ./
COPY pricing/ ./pricing/

RUN mkdir -p /app/accounts /app/usage

VOLUME ["/app/accounts", "/app/usage"]
EXPOSE 8788

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:%s/health' % os.environ.get('PORT', '8788'), timeout=4)"

CMD ["python", "wb_proxy.py", "--lan"]
