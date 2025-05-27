FROM vllm/vllm-openai

# Install system dependencies, including curl for the uv installer
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN UV_VERSION=$(curl -fsSL https://astral.sh/uv/version.txt) && \
    echo "Attempting to install uv version: ${UV_VERSION}" && \
    UV_TARGET_ARCH="x86_64-unknown-linux-gnu" && \
    curl -LsSf "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${UV_TARGET_ARCH}.tar.gz" \
    -o /tmp/uv.tar.gz && \
    # Extract the uv binary. Tarballs from Astral typically contain a directory like 'uv-x86_64-unknown-linux-gnu/uv'
    # We extract directly to /usr/local/bin and use strip-components if needed, or extract then move.
    # This command extracts the 'uv' binary from its containing folder into /usr/local/bin directly
    tar -xzf /tmp/uv.tar.gz -C /usr/local/bin --strip-components=1 "uv-${UV_TARGET_ARCH}/uv" && \
    chmod +x /usr/local/bin/uv && \
    rm /tmp/uv.tar.gz && \
    # Verify installation
    echo "uv installation verification:" && \
    uv --version

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