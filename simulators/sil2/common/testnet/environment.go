package testnet

import (
	"github.com/sila-chain/sila-hive/simulators/sil2/common/clients"
	consensus_config "github.com/sila-chain/sila-hive/simulators/sil2/common/config/consensus"
)

type Environment struct {
	Clients        *clients.ClientDefinitionsByRole
	Validators     consensus_config.ValidatorsSetupDetails
	LogEngineCalls bool
}
