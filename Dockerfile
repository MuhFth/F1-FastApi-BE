# Dockerfile

# [1] Gunakan base image Python resmi yang ringan (slim)
# Python 3.10-slim memastikan image relatif kecil
FROM python:3.10

#Instal dependensi build Linux
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
    
# [2] Set environment variable untuk menghindari buffering output Python
ENV PYTHONUNBUFFERED 1

# [3] Tentukan direktori kerja di dalam container
ENV APP_HOME /app
WORKDIR $APP_HOME

# [4] Copy requirements dan install dependencies
# Kami menginstall Gunicorn di sini, server yang mengelola Uvicorn untuk produksi
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# [5] Copy semua file aplikasi lainnya (main.py, model.pkl, scaler.pkl)
COPY . ./

# [6] Tentukan port yang akan digunakan oleh Cloud Run (port 8080 adalah default)
# Cloud Run akan otomatis mengatur traffic ke port ini.
ENV PORT 8080

# [7] Command untuk menjalankan aplikasi
# Jalankan Gunicorn, ikat (bind) ke semua interface (0.0.0.0) di port 8080.
# Kami menggunakan satu worker karena Cloud Run menangani skalabilitas secara eksternal.
CMD exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --worker-class uvicorn.workers.UvicornWorker main:app

#Instal dependensi build Linux
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
