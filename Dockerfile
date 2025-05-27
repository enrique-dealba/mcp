FROM vllm/vllm-openai

# Install system dependencies, including curl for the uv installer
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --to /usr/local/bin

WORKDIR /app

COPY . .

RUN uv pip install --system -r requirements.txt \
    pytest \
    pytest-cov \
    jupyterlab \
    notebook \
    fastmcp

EXPOSE 8888
# For MCP server.py
EXPOSE 8000

# Clear any entrypoint inherited from the base image
ENTRYPOINT []


CMD ["sh", "-c", "uv run --with fastmcp server.py --server_type=sse & \
     jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''"]