# Base image
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy requirements (if you have one)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy your app code (e.g. app.py and templates/static folders)
COPY . .

# Expose port for Flask
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]

