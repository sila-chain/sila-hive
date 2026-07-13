ARG baseimage=ghcr.io/silajs/silajs-monorepo
ARG tag=latest

FROM $baseimage:$tag as builder

RUN apk add --update --no-cache bash git jq curl python3 gcc make g++ \
    && rm -rf /var/cache/apk/*

# Create version.txt
RUN cd /silajs-monorepo/packages/client/ && npm silajs --version > /version.txt

# Add genesis mapper script, startup script, and enode URL retriever script
ADD genesis.json /genesis.json
ADD mapper.jq /mapper.jq
ADD silajs.sh /silajs.sh
ADD enode.sh /hive-bin/enode.sh
ADD jwtsecret /silajs-monorepo/jwtsecret

# Set execute permissions for scripts
RUN chmod +x /silajs.sh /hive-bin/enode.sh

# Expose networking ports
EXPOSE 8545 8546 8551 8547 30303 30303/udp

# NodeJS applications have a default memory limit of 2.5GB.
# This limit is bit tight, it is recommended to raise the limit
# since memory may spike during certain network conditions.
ENV NODE_OPTIONS=--max_old_space_size=6144

ENTRYPOINT ["/silajs.sh"]
