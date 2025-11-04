# DOCKERFILE FINAL (MENGATASI SUBFOLDER)

FROM python:3.10

# Hapus semua blok RUN apt-get, karena python:3.10 sudah OK
# HAPUS: RUN apt-get update...

ENV PYTHONUNBUFFERED 1
ENV APP_HOME /app
WORKDIR $APP_HOME

# 1. Copy requirements dari SUBFOLDER (KOREKSI PATH)
COPY f1-winner-api/requirements.txt ./ 
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# 2. Copy kode dan model dari SUBFOLDER (KOREKSI PATH)
# Ini penting agar main.py, model.pkl, dan scaler.pkl ada di WorkDir /app
COPY f1-winner-api/main.py ./
COPY f1-winner-api/model.pkl ./
COPY f1-winner-api/scaler.pkl ./

ENV PORT 8080
CMD exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --worker-class uvicorn.workers.UvicornWorker main:app
