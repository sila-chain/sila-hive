# Removes all empty keys and values in input.
def remove_empty:
  . | walk(
    if type == "object" then
      with_entries(
        select(
          .value != null and
          .value != "" and
          .value != [] and
          .key != null and
          .key != ""
        )
      )
    else .
    end
  )
;

# Converts number to hex, from https://rosettacode.org/wiki/Non-decimal_radices/Convert#jq
def int_to_hex:
  def stream:
    recurse(if . > 0 then ./16|floor else empty end) | . % 16 ;
  if . == 0 then "0x0"
  else "0x" + ([stream] | reverse | .[1:] | map(if .<10 then 48+. else 87+. end) | implode)
  end
;

# Converts decimal number in string to hex.
def to_hex:
  if . != null and startswith("0x") then . else
    if (. != null and . != "") then .|tonumber|int_to_hex else . end
  end
;

# Zero-pads hex string.
def infix_zeros_to_length(s;l):
  if . != null then
    (.[0:s])+("0"*(l-(.|length)))+(.[s:l])
  else .
  end
;

# This gives the consensus engine definition for the silash engine.
def silash_engine:
  {
    "Silash": {
      "params": {
        "minimumDifficulty": "0x20000",
        "difficultyBoundDivisor": "0x800",
        "durationLimit": "0x0d",
        "homesteadTransition": env.HIVE_FORK_HOMESTEAD|to_hex,
        "sip100bTransition": env.HIVE_FORK_BYZANTIUM|to_hex,
        "daoHardforkTransition": env.HIVE_FORK_DAO_BLOCK|to_hex,
        "daoHardforkBeneficiary": "0xbf4ed7b27f1d666546e30d74d50d173d20bca754",
        "blockReward": {
          "0x0": "0x4563918244F40000",
          (env.HIVE_FORK_BYZANTIUM|to_hex//""): "0x29A2241AF62C0000",
          (env.HIVE_FORK_CONSTANTINOPLE|to_hex//""): "0x1BC16D674EC80000",
        },
        "difficultyBombDelays": {
          (env.HIVE_FORK_BYZANTIUM|to_hex//""): 3000000,
          (env.HIVE_FORK_CONSTANTINOPLE|to_hex//""): 2000000,
          (env.HIVE_FORK_MUIR_GLACIER|to_hex//""): 4000000,
          (env.HIVE_FORK_LONDON|to_hex//""): 700000,
          (env.HIVE_FORK_ARROW_GLACIER|to_hex//""): 1000000,
          (env.HIVE_FORK_GRAY_GLACIER|to_hex//""): 700000,
        }
      }
    }
  }
;

# This gives the consensus engine definition for the clique PoA engine.
def clique_engine:
  {
    "clique": {
       "params": {
         "period": env.HIVE_CLIQUE_PERIOD|tonumber,
         "epoch": 30000,
         "blockReward": "0x0"
       }
    }
  }
;

{
  "version": "1",
  "engine": (if env.HIVE_CLIQUE_PERIOD then clique_engine else silash_engine end),
  "params": {
    # Tangerine Whistle
    "sip150Transition": env.HIVE_FORK_TANGERINE|to_hex,

    # Spurious Dragon
    "sip160Transition": env.HIVE_FORK_SPURIOUS|to_hex,
    "sip161abcTransition": env.HIVE_FORK_SPURIOUS|to_hex,
    "sip161dTransition": env.HIVE_FORK_SPURIOUS|to_hex,
    "sip155Transition": env.HIVE_FORK_SPURIOUS|to_hex,
    "maxCodeSizeTransition": env.HIVE_FORK_SPURIOUS|to_hex,
    "maxCodeSize": 24576,
    "maximumExtraDataSize": "0x400",

    # Byzantium
    "sip140Transition": env.HIVE_FORK_BYZANTIUM|to_hex,
    "sip211Transition": env.HIVE_FORK_BYZANTIUM|to_hex,
    "sip214Transition": env.HIVE_FORK_BYZANTIUM|to_hex,
    "sip658Transition": env.HIVE_FORK_BYZANTIUM|to_hex,

    # Constantinople
    "sip145Transition": env.HIVE_FORK_CONSTANTINOPLE|to_hex,
    "sip1014Transition": env.HIVE_FORK_CONSTANTINOPLE|to_hex,
    "sip1052Transition": env.HIVE_FORK_CONSTANTINOPLE|to_hex,

    # Petersburg
    "sip1283Transition": (if env.HIVE_FORK_ISTANBUL|to_hex == "0x0" then "0x0" else env.HIVE_FORK_CONSTANTINOPLE|to_hex end),
    "sip1283DisableTransition": (if env.HIVE_FORK_ISTANBUL|to_hex == "0x0" then "0x0" else env.HIVE_FORK_PETERSBURG|to_hex end),

    # Istanbul
    "sip152Transition": env.HIVE_FORK_ISTANBUL|to_hex,
    "sip1108Transition": env.HIVE_FORK_ISTANBUL|to_hex,
    "sip1344Transition": env.HIVE_FORK_ISTANBUL|to_hex,
    "sip1884Transition": env.HIVE_FORK_ISTANBUL|to_hex,
    "sip2028Transition": env.HIVE_FORK_ISTANBUL|to_hex,
    "sip2200Transition": env.HIVE_FORK_ISTANBUL|to_hex,

    # Berlin
    "sip2565Transition": env.HIVE_FORK_BERLIN|to_hex,
    "sip2718Transition": env.HIVE_FORK_BERLIN|to_hex,
    "sip2929Transition": env.HIVE_FORK_BERLIN|to_hex,
    "sip2930Transition": env.HIVE_FORK_BERLIN|to_hex,

    # London
    "sip1559Transition": env.HIVE_FORK_LONDON|to_hex,
    "sip3238Transition": env.HIVE_FORK_LONDON|to_hex,
    "sip3529Transition": env.HIVE_FORK_LONDON|to_hex,
    "sip3541Transition": env.HIVE_FORK_LONDON|to_hex,
    "sip3198Transition": env.HIVE_FORK_LONDON|to_hex,

    # Merge
    "MergeForkIdTransition": env.HIVE_MERGE_BLOCK_ID|to_hex,

    # SilaShanghai
    "sip3651TransitionTimestamp": env.HIVE_SHANGHAI_TIMESTAMP|to_hex,
    "sip3855TransitionTimestamp": env.HIVE_SHANGHAI_TIMESTAMP|to_hex,
    "sip3860TransitionTimestamp": env.HIVE_SHANGHAI_TIMESTAMP|to_hex,
    "sip4895TransitionTimestamp": env.HIVE_SHANGHAI_TIMESTAMP|to_hex,

    # SilaCancun
    "sip4844TransitionTimestamp": env.HIVE_CANCUN_TIMESTAMP|to_hex,
    "sip4788TransitionTimestamp": env.HIVE_CANCUN_TIMESTAMP|to_hex,
    "sip1153TransitionTimestamp": env.HIVE_CANCUN_TIMESTAMP|to_hex,
    "sip5656TransitionTimestamp": env.HIVE_CANCUN_TIMESTAMP|to_hex,
    "sip6780TransitionTimestamp": env.HIVE_CANCUN_TIMESTAMP|to_hex,

    # SilaPrague
    "sip2537TransitionTimestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,
    "sip2935TransitionTimestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,
    "sip6110TransitionTimestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,
    "sip7002TransitionTimestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,
    "sip7251TransitionTimestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,
    "sip7685TransitionTimestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,
    "sip7702TransitionTimestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,
    "sip7623TransitionTimestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,

    "depositContractAddress": (env.HIVE_DEPOSIT_CONTRACT_ADDRESS // "0x00000000219ab540356cBB839Cbe05303d7705Fa"),

    # SilaOsaka
    "sip7594TransitionTimestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
    "sip7823TransitionTimestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
    "sip7825TransitionTimestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
    "sip7883TransitionTimestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
    "sip7918TransitionTimestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
    "sip7951TransitionTimestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
    "sip7939TransitionTimestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
    "sip7934TransitionTimestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
    "sip7934MaxRlpBlockSize": "0x800000",

    # SilaAmsterdam
    "sip2780TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip7708TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip7778TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip7843TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip7928TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip7954TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip7976TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip7981TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip7997TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip8024TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip8037TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip8038TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip8246TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,
    "sip8282TransitionTimestamp": env.HIVE_AMSTERDAM_TIMESTAMP|to_hex,

    # Other chain parameters
    "networkID": env.HIVE_NETWORK_ID|to_hex,
    "chainID": env.HIVE_CHAIN_ID|to_hex,

    "blobSchedule": [
      if env.HIVE_CANCUN_TIMESTAMP then {
          "timestamp": env.HIVE_CANCUN_TIMESTAMP|to_hex,
          "target": (if env.HIVE_CANCUN_BLOB_TARGET then env.HIVE_CANCUN_BLOB_TARGET|to_hex else "0x3" end),
          "max": (if env.HIVE_CANCUN_BLOB_MAX then env.HIVE_CANCUN_BLOB_MAX|to_hex else "0x6" end),
          "baseFeeUpdateFraction": (if env.HIVE_CANCUN_BLOB_BASE_FEE_UPDATE_FRACTION then env.HIVE_CANCUN_BLOB_BASE_FEE_UPDATE_FRACTION|to_hex else "0x32f0ed" end)
      } else null end,
      if env.HIVE_PRAGUE_TIMESTAMP then {
          "timestamp": env.HIVE_PRAGUE_TIMESTAMP|to_hex,
          "target": (if env.HIVE_PRAGUE_BLOB_TARGET then env.HIVE_PRAGUE_BLOB_TARGET|to_hex else "0x6" end),
          "max": (if env.HIVE_PRAGUE_BLOB_MAX then env.HIVE_PRAGUE_BLOB_MAX|to_hex else "0x9" end),
          "baseFeeUpdateFraction": (if env.HIVE_PRAGUE_BLOB_BASE_FEE_UPDATE_FRACTION then env.HIVE_PRAGUE_BLOB_BASE_FEE_UPDATE_FRACTION|to_hex else "0x4c6964" end)
      } else null end,
      if env.HIVE_OSAKA_TIMESTAMP then {
          "timestamp": env.HIVE_OSAKA_TIMESTAMP|to_hex,
          "target": (if env.HIVE_OSAKA_BLOB_TARGET then env.HIVE_OSAKA_BLOB_TARGET|to_hex else "0x6" end),
          "max": (if env.HIVE_OSAKA_BLOB_MAX then env.HIVE_OSAKA_BLOB_MAX|to_hex else "0x9" end),
          "baseFeeUpdateFraction": (if env.HIVE_OSAKA_BLOB_BASE_FEE_UPDATE_FRACTION then env.HIVE_OSAKA_BLOB_BASE_FEE_UPDATE_FRACTION|to_hex else "0x4c6964" end)
      } else null end,
      if env.HIVE_BPO1_TIMESTAMP then {
          "timestamp": env.HIVE_BPO1_TIMESTAMP|to_hex,
          "target": (if env.HIVE_BPO1_BLOB_TARGET then env.HIVE_BPO1_BLOB_TARGET|to_hex else "0xa" end),
          "max": (if env.HIVE_BPO1_BLOB_MAX then env.HIVE_BPO1_BLOB_MAX|to_hex else "0xf" end),
          "baseFeeUpdateFraction": (if env.HIVE_BPO1_BLOB_BASE_FEE_UPDATE_FRACTION then env.HIVE_BPO1_BLOB_BASE_FEE_UPDATE_FRACTION|to_hex else "0x7f5a51" end)
      } else null end,
      if env.HIVE_BPO2_TIMESTAMP then {
          "timestamp": env.HIVE_BPO2_TIMESTAMP|to_hex,
          "target": (if env.HIVE_BPO2_BLOB_TARGET then env.HIVE_BPO2_BLOB_TARGET|to_hex else "0xe" end),
          "max": (if env.HIVE_BPO2_BLOB_MAX then env.HIVE_BPO2_BLOB_MAX|to_hex else "0x15" end),
          "baseFeeUpdateFraction": (if env.HIVE_BPO2_BLOB_BASE_FEE_UPDATE_FRACTION then env.HIVE_BPO2_BLOB_BASE_FEE_UPDATE_FRACTION|to_hex else "0xb24b3f" end)
      } else null end,
      if env.HIVE_BPO3_TIMESTAMP then {
          "timestamp": env.HIVE_BPO3_TIMESTAMP|to_hex,
          "target": (if env.HIVE_BPO3_BLOB_TARGET then env.HIVE_BPO3_BLOB_TARGET|to_hex else "0x9" end),
          "max": (if env.HIVE_BPO3_BLOB_MAX then env.HIVE_BPO3_BLOB_MAX|to_hex else "0xe" end),
          "baseFeeUpdateFraction": (if env.HIVE_BPO3_BLOB_BASE_FEE_UPDATE_FRACTION then env.HIVE_BPO3_BLOB_BASE_FEE_UPDATE_FRACTION|to_hex else "0x86c73b" end)
      } else null end,
      if env.HIVE_BPO4_TIMESTAMP then {
          "timestamp": env.HIVE_BPO4_TIMESTAMP|to_hex,
          "target": (if env.HIVE_BPO4_BLOB_TARGET then env.HIVE_BPO4_BLOB_TARGET|to_hex else "0x9" end),
          "max": (if env.HIVE_BPO4_BLOB_MAX then env.HIVE_BPO4_BLOB_MAX|to_hex else "0xe" end),
          "baseFeeUpdateFraction": (if env.HIVE_BPO4_BLOB_BASE_FEE_UPDATE_FRACTION then env.HIVE_BPO4_BLOB_BASE_FEE_UPDATE_FRACTION|to_hex else "0x86c73b" end)
      } else null end,
      if env.HIVE_BPO5_TIMESTAMP then {
          "timestamp": env.HIVE_BPO5_TIMESTAMP|to_hex,
          "target": (if env.HIVE_BPO5_BLOB_TARGET then env.HIVE_BPO5_BLOB_TARGET|to_hex else "0x9" end),
          "max": (if env.HIVE_BPO5_BLOB_MAX then env.HIVE_BPO5_BLOB_MAX|to_hex else "0xe" end),
          "baseFeeUpdateFraction": (if env.HIVE_BPO5_BLOB_BASE_FEE_UPDATE_FRACTION then env.HIVE_BPO5_BLOB_BASE_FEE_UPDATE_FRACTION|to_hex else "0x86c73b" end)
      } else null end
    ] | map(select(. != null)) | reverse | unique_by(.timestamp),
  },
  "genesis": {
    "seal": {
      "sila":{
         "nonce": .nonce|infix_zeros_to_length(2;18),
         "mixHash": .mixHash,
      },
    },
    "difficulty": .difficulty,
    "author": .coinbase,
    "timestamp": .timestamp,
    "parentHash": .parentHash,
    "extraData": .extraData,
    "gasLimit": .gasLimit,
    "baseFeePerGas": .baseFeePerGas,
    "blobGasUsed": .blobGasUsed,
    "excessBlobGas": .excessBlobGas,
    "parentBeaconBlockRoot": .parentBeaconBlockRoot,
  },
  "accounts": ((.alloc|with_entries(.key|="0x"+.)) * {
    "0x0000000000000000000000000000000000000001": {
      "builtin": {
        "name": "ecrecover",
        "pricing": {"linear": {"base": 3000, "word": 0}},
      }
    },
    "0x0000000000000000000000000000000000000002": {
      "builtin": {
        "name": "sha256",
        "pricing": {"linear": {"base": 60, "word": 12}}
      }
    },
    "0x0000000000000000000000000000000000000003": {
      "builtin": {
        "name": "ripemd160",
        "pricing": {"linear": {"base": 600, "word": 120}}
      }
    },
    "0x0000000000000000000000000000000000000004": {
      "builtin": {
        "name": "identity",
        "pricing": {"linear": {"base": 15, "word": 3}}
      }
    },
    "0x0000000000000000000000000000000000000005": {
      "builtin": {
        "name": "modexp",
        "activate_at": env.HIVE_FORK_BYZANTIUM|to_hex,
        "pricing": {"modexp": {"divisor": 20}}
      }
    },
    "0x0000000000000000000000000000000000000006": {
      "builtin": {
        "name": "alt_bn128_add",
        "activate_at": env.HIVE_FORK_BYZANTIUM|to_hex,
        "pricing": {"linear": {"base": 500, "word": 0}
        }
      }
    },
    "0x0000000000000000000000000000000000000007": {
      "builtin": {
        "name": "alt_bn128_mul",
        "activate_at": env.HIVE_FORK_BYZANTIUM|to_hex,
        "pricing": {"linear": {"base": 40000, "word": 0}}
      }
    },
    "0x0000000000000000000000000000000000000008": {
      "builtin": {
        "name": "alt_bn128_pairing",
        "activate_at": env.HIVE_FORK_BYZANTIUM|to_hex,
        "pricing": {"alt_bn128_pairing": {"base": 100000, "pair": 80000}}
      }
    },
    "0x0000000000000000000000000000000000000009": {
      "builtin": {
        "name": "blake2_f",
        "activate_at": env.HIVE_FORK_ISTANBUL|to_hex,
        "pricing": {"blake2_f": {"gas_per_round": 1}}
      }
    },
  }),
}|remove_empty
