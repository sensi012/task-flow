FROM python:3.11-slim
WORKDIR /app
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt
COPY . .
ENV PATH="/home/appuser/.local/bin:$PATH"
CMD ["python", "main.py"]