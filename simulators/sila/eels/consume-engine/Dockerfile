# Builds and runs the EELS (execution-specs) consume engine simulator
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

## Default fixtures/git-ref
ARG fixtures=stable@latest
ENV FIXTURES=${fixtures}
ARG branch=""

## Clone and install EELS
RUN apt-get update && apt-get install -y git

# Clone repo and use the default branch if none specified
RUN git clone --depth 1 https://github.com/sila-chain/execution-specs.git && \
    cd execution-specs && \
    if [ -n "$branch" ]; then \
        git fetch --depth 1 origin "$branch" && \
        git checkout FETCH_HEAD; \
    fi

# Preserve any workflow-provided local fixture archive in the simulator image.
COPY . /hive-simulator-input

WORKDIR /execution-specs/packages/testing

# Cache the fixtures. This is done to avoid re-downloading the fixtures every time
# the container starts. A local archive copied into the simulator build context is
# preferred when present; otherwise the configured fixture reference is used.
RUN fixture_input="$FIXTURES"; \
    if [ -f "/hive-simulator-input/$FIXTURES" ]; then fixture_input="/hive-simulator-input/$FIXTURES"; fi; \
    uv sync && \
    uv run consume cache --input "$fixture_input"

## Define `consume engine` entry point using the local fixtures
# TODO: remove when fixed on nimbus-el side.
ARG disable_strict_exception_matching=nimbus-el
ENV DISABLE_STRICT_EXCEPTION_MATCHING=${disable_strict_exception_matching}
ENTRYPOINT ["/bin/sh", "-c", "fixture_input=\"$FIXTURES\"; if [ -f \"/hive-simulator-input/$FIXTURES\" ]; then fixture_input=\"/hive-simulator-input/$FIXTURES\"; fi; exec uv run consume engine -v --input \"$fixture_input\" --disable-strict-exception-matching \"$DISABLE_STRICT_EXCEPTION_MATCHING\""]
