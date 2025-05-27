FROM vllm/vllm-openai

RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

# Install dependencies from requirements.txt and other specified packages
RUN pip install -r requirements.txt && \
    pip install pytest pytest-cov && \
    pip install jupyterlab notebook

# Copy application files
COPY app/ ./app/
COPY scripts/ ./scripts/
COPY tests/ ./tests/

# Make start script executable if you intend to use it later
# RUN chmod +x /app/scripts/start.sh

EXPOSE 8888

# Clear any entrypoint from the base image
ENTRYPOINT []

# Run JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
