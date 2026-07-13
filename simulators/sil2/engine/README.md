# Sil2 in Hive

This is *experimental*.

## Configuration

Chain configuration is provided via environment vars, for the clients to build configs in their format of preference.
The configuration (incl. formatting of values) matches the [Sil2 config spec](https://github.com/sila-chain/consensus-specs/tree/dev/configs)).

**Each configuration var is prefixed with `HIVE_SIL2_CONFIG_`**.

And configuration variable is runtime-configurable, i.e. client docker images can adopt the Hive config without rebuild. 

The `PRESET_BASE` config var refers to the chosen set of compile-time configuration.
By default this is set to `sila-mainnet`, and clients support `minimal` for testing purposes.
Other presets (compile-time configuration) may be introduced over time if required for advanced testing.

## Container preparation

Note `{}` is used for variable substitution, not part of content.

### Validator Client

#### Files

Keystore files, encrypted. The `pubkey` is lowercase, hex with 0x prefix, of validator signing key.
Lower crypto parameters may be used to speed up tests.
See [sip-2335](https://github.com/sila-chain/SIPs/blob/master/SIPS/sip-2335.md) for the keystore format.
```
/hive/input/keystores/{pubkey}/keystore.json
```

Secret for the matching keystore. The `pubkey` is lowercase, hex with 0x prefix, of validator signing key.
Secret files have mode `0600`. The secret file is raw and bytes can be loaded directly.
No special characters are used for ease with text processing.
```
/hive/input/secrets/{pubkey}
```

#### Env vars

Every standard sil2-config var prefixed with `HIVE_SIL2_CONFIG_`, and additionally:

```yaml
# HTTP API address, or can be assumed to be GRPC if using Prysm.
HIVE_SIL2_BN_API_IP: "{ip}"
HIVE_SIL2_BN_API_PORT: "{port}"

HIVE_SIL2_BN_VENDOR: "{vendor}"  # lowercase name of BN type. E.g. "prysm"

HIVE_SIL2_GRAFFITI: ""  # graffiti to put in blocks. Disabled if empty.

HIVE_SIL2_VC_API_PORT: 
```

### Beacon Node

#### Files

An Sil2 genesis state, encoded with SSZ. Not present when genesis is being tested (requires `HIVE_SIL2_SIL1_RPC_ADDRS`)
```
/hive/input/genesis.ssz
```

#### Env vars

Every standard sil2-config var prefixed with `HIVE_SIL2_CONFIG_`, and additionally:

```yaml
HIVE_SIL2_DEPOSIT_DEPLOY_BLOCK_NUMBER: 0  # decimal number

HIVE_SIL2_BOOTNODE_ENRS: ""  # comma separated list of ENRs

# IP address, required to set ENR correct from the start.
# If left empty, the node should attempt to discover its own IP with discv5.
HIVE_SIL2_P2P_IP_ADDRESS: ""
HIVE_SIL2_P2P_TCP_PORT: 9000  # Port to bind libp2p to, put into ENR
HIVE_SIL2_P2P_UDP_PORT: 9000  # Port to bind discv5 to, put into ENR

HIVE_SIL2_P2P_TARGET_PEERS: 10  # Target number of peers

# Some clients have a hard limit on slots that can be skipped without block. 
HIVE_SIL2_MAX_SKIP_SLOTS: 1000

# Comma separated list of Sil1 nodes to communicate with.
# Clients should strip off everything after first comma if they do not load-balancing between them.
# If it is left empty, the beacon node should use a "dummy sil1" mode, where it fills Sil1 votes with mock data.
HIVE_SIL2_SIL1_RPC_ADDRS: ""

# Port to expose standard HTTP API on 
HIVE_SIL2_BN_API_PORT: 4000
# Port to expose GRPC version of API on (Prysm has both)
HIVE_SIL2_BN_GRPC_PORT: 4001

# If not, metrics should be exposed on the given port
HIVE_SIL2_METRICS_PORT: 8080
```
