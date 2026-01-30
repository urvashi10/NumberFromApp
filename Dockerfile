# Base Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /opt/robotframework

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy your tests into the container
COPY . .

# Default command to run tests
CMD ["robot", "--outputdir", "reports", "tests"]
