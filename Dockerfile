FROM vllm/vllm-openai

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

COPY requirements.txt .

# Install ALL pip dependencies
RUN pip install -r requirements.txt && \
    pip install pytest pytest-cov

RUN pip3 install --no-cache-dir jupyterlab notebook

# Copy rest of application files
COPY app/ ./app/
COPY scripts/ ./scripts/
COPY tests/ ./tests/

# Make start script executable
# RUN chmod +x /app/scripts/start.sh

EXPOSE 8888

# Set the entrypoint to our start script
# ENTRYPOINT ["/app/scripts/start.sh"]
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
