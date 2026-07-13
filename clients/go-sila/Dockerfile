ARG baseimage=sila/client-go
ARG tag=latest

FROM $baseimage:$tag as builder

FROM alpine:latest
RUN apk add --update bash curl jq
COPY --from=builder /usr/local/bin/sila /usr/local/bin/sila

# Generate the version.txt file.
RUN /usr/local/bin/sila console --exec 'console.log(admin.nodeInfo.name)' --maxpeers=0 --nodiscover --dev 2>/dev/null | head -1 > /version.txt

# Inject the startup script.
ADD sila.sh /sila.sh
ADD mapper.jq /mapper.jq
RUN chmod +x /sila.sh

# Inject the enode id retriever script.
RUN mkdir /hive-bin
ADD enode.sh /hive-bin/enode.sh
RUN chmod +x /hive-bin/enode.sh

# Add a default genesis file.
ADD genesis.json /genesis.json

# Export the usual networking ports to allow outside access to the node
EXPOSE 8545 8546 8547 8551 30303 30303/udp

ENTRYPOINT ["/sila.sh"]
