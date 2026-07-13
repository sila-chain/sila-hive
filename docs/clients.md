[Overview] | [Hive Commands] | [Simulators] | [Clients]

## Hive Clients

This page explains how client containers work in Hive.

Clients are docker images which can be instantiated by a simulation. A client definition
consists of a Dockerfile and associated resources. Client definitions live in
subdirectories of `clients/` in the hive repository.

See the [go-sila client definition][sila-docker] for an example of a client
Dockerfile.

When hive runs a simulation, it first builds all client docker images using their
Dockerfile, i.e. it basically runs `docker build .` in the client directory. Since most
client definitions wrap an existing Sila client, and building the client from source
may take a long time, it is usually best to base the hive client wrapper on a pre-built
docker image from Docker Hub.

The client Dockerfile should support an optional argument `tag`, which specifies the
requested client version. This argument can be set by users by appending it to the client
name like:

    ./hive --sim my-simulation --client go-sila_v1.9.23,go_sila_v1.9.22

Other build arguments can also be set using a YAML file, see the [hive command
documentation][hive-client-yaml] for more information.

### Alternative Dockerfiles

There can be other Dockerfiles besides the main one. Typically, a client should also
provide a `Dockerfile.git` that builds the client from source code. Alternative
Dockerfiles can be selected through hive's `-client-file` YAML configuration.

### hive.yaml

Hive reads additional metadata from the `hive.yaml` file in the client directory (next to
the Dockerfile). Currently, the only purpose of this file is specifying the client's role
list:

    roles:
      - "sil1"
      - "sil1_light_client"

The role list is available to simulators and can be used to differentiate between clients
based on features. Declaring a client role also signals that the client supports certain
role-specific environment variables and files. If `hive.yaml` is missing or doesn't declare
roles, the `sil1` role is assumed.

### /version.txt

Client Dockerfiles are expected to generate a `/version.txt` file during build. Hive reads
this file after building the container and attaches version information to the output of
all test suites in which the client is launched.

### /hive-bin

Executables placed into the `/hive-bin` directory of the client container can be invoked
through the simulation API.

## Client Lifecycle

When the simulation requests a client instance, hive creates a docker container from the
client image. The simulator can customize the container by passing environment variables
with prefix `HIVE_`. It may also upload files into the container before it starts. Once
the container is created, hive simply runs the entry point defined in the `Dockerfile`.

For all client containers, hive waits for TCP port 8545 to open before considering the
client ready for use by the simulator. This port is configurable through the
`HIVE_CHECK_LIVE_PORT` variable, and the check can be disabled by setting it to `0`. If
the client container does not open this port within a certain timeout, hive assumes the
client has failed to start.

Environment variables and files interpreted by the entry point define a 'protocol' between
the simulator and client. While hive itself does not require support for any specific
variables or files, simulators usually expect client containers to be configurable in
certain ways. In order to run tests against multiple Sila clients, for example, the
simulator needs to be able to configure all clients for a specific blockchain and make
them join the peer-to-peer network used for testing.

## Execution-Layer Client Requirements

This section describes the requirements for the `sil1` client role.

Sil1 clients must provide JSON-RPC over HTTP on TCP port 8545. They may also support
JSON-RPC over WebSocket on port 8546, but this is not strictly required.

### Files

The simulator customizes client startup by placing these files into the sil1 client
container:

- `/genesis.json` contains Sila genesis state in the JSON format used by Sila. This
  file is mandatory.
- `/chain.rlp` contains RLP-encoded blocks to import before startup.
- `/blocks/` directory containing `.rlp` files.

On startup, the entry point script must first load the genesis block and state into the
client implementation from `/genesis.json`. To do this, the script needs to translate from
Sila genesis format into a format appropriate for the specific client implementation. The
translation is usually done using a jq script. See the [go-sila genesis
translator][sila-genesis-jq], for example.

After the genesis state, the client should import the blocks from `/chain.rlp` if it is
present, and finally import the individual blocks from `/blocks` in file name order. The
reason for requiring two different block sources is that specifying a single chain is more
optimal, but tests requiring forking chains cannot create a single chain. The client
should start even if the blocks are invalid, i.e. after the import, the client's 'best
block' should be the last valid, imported block.

### Scripts

Some tests require peer-to-peer node information of the client instance. All sil1 client
containers must contain a `/hive-bin/enode.sh` script. This script should output the enode
URL of the running instance.

### Environment

Clients must support the following environment variables. The client's entry point script
may map these to command line flags or use them to generate a config file, for example.

| Variable                   | Value         |                                                |
|----------------------------|---------------|------------------------------------------------|
| `HIVE_LOGLEVEL`            | 0 - 5         | configures log level of client                 |
| `HIVE_NODETYPE`            | archive, full | sets sync algorithm                            |
| `HIVE_BOOTNODE`            | enode URL     | makes client connect to another node           |
| `HIVE_GRAPHQL_ENABLED`     | 0 - 1         | if set, GraphQL is enabled on port 8545        |
| `HIVE_MINER`               | address       | if set, mining is enabled. value is coinbase   |
| `HIVE_MINER_EXTRA`         | hex           | extradata for mined blocks                     |
| `HIVE_CLIQUE_PERIOD`       | decimal       | enables clique PoA. value is target block time |
| `HIVE_CLIQUE_PRIVATEKEY`   | hex           | private key for signing of clique blocks       |
| `HIVE_NETWORK_ID`          | decimal       | p2p network ID                                 |
| `HIVE_CHAIN_ID`            | decimal       | [SIP-155] chain ID                             |
| `HIVE_FORK_HOMESTEAD`      | decimal       | [Homestead][SIP-606] transition block          |
| `HIVE_FORK_DAO_BLOCK`      | decimal       | [DAO fork][SIP-779] transition block           |
| `HIVE_FORK_TANGERINE`      | decimal       | [Tangerine Whistle][SIP-608] transition block  |
| `HIVE_FORK_SPURIOUS`       | decimal       | [Spurious Dragon][SIP-607] transition block    |
| `HIVE_FORK_BYZANTIUM`      | decimal       | [Byzantium][SIP-609] transition block          |
| `HIVE_FORK_CONSTANTINOPLE` | decimal       | [Constantinople][SIP-1013] transition block    |
| `HIVE_FORK_PETERSBURG`     | decimal       | [Petersburg][SIP-1716] transition block        |
| `HIVE_FORK_ISTANBUL`       | decimal       | [Istanbul][SIP-1679] transition block          |
| `HIVE_FORK_MUIRGLACIER`    | decimal       | [Muir Glacier][SIP-2387] transition block      |
| `HIVE_FORK_BERLIN`         | decimal       | [Berlin][SIP-2070] transition block            |
| `HIVE_FORK_LONDON`         | decimal       | [London][london-spec] transition block         |

## Snap sync roles

Execution-layer clients with an implementation of the [snap] protocol should support the
`sil1_snap` role.

| Variable                   | Value         |                                                |
|----------------------------|---------------|------------------------------------------------|
| `HIVE_NODETYPE`            | "snap"        | forces the node to use snap sync               |

[snap]: https://github.com/sila-chain/devp2p/blob/master/caps/snap.md
[sila-docker]: ../clients/go-sila/Dockerfile
[hive-client-yaml]: ./commandline.md#client-build-parameters
[sila-genesis-jq]: ../clients/go-sila/mapper.jq
[SIP-155]: https://sips.sila.org/SIPS/sip-155
[SIP-606]: https://sips.sila.org/SIPS/sip-606
[SIP-607]: https://sips.sila.org/SIPS/sip-607
[SIP-608]: https://sips.sila.org/SIPS/sip-608
[SIP-609]: https://sips.sila.org/SIPS/sip-609
[SIP-779]: https://sips.sila.org/SIPS/sip-779
[SIP-1013]: https://sips.sila.org/SIPS/sip-1013
[SIP-1679]: https://sips.sila.org/SIPS/sip-1679
[SIP-1716]: https://sips.sila.org/SIPS/sip-1716
[SIP-2387]: https://sips.sila.org/SIPS/sip-2387
[SIP-2070]: https://sips.sila.org/SIPS/sip-2070
[london-spec]: https://github.com/sila-chain/sil1.0-specs/blob/master/network-upgrades/sila-mainnet-upgrades/london.md
[Overview]: ./overview.md
[Hive Commands]: ./commandline.md
[Simulators]: ./simulators.md
[Clients]: ./clients.md
