package suite_base

import (
	"github.com/sila-chain/sila-hive/hivesim"
	"github.com/sila-chain/sila-hive/simulators/sil2/common/clients"
	"github.com/sila-chain/sila-hive/simulators/sil2/dencun/suites"
)

var testSuite = hivesim.Suite{
	Name:        "sil2-deneb-testnet",
	DisplayName: "SilaDeneb Testnet",
	Description: `Collection of test vectors that use a ExecutionClient+BeaconNode+ValidatorClient testnet for SilaCancun+SilaDeneb.`,
	Location:    "suites/base",
}

var Tests = make([]suites.TestSpec, 0)

func init() {
	Tests = append(Tests,
		BaseTestSpec{
			Name:         "test-deneb-fork",
			DisplayName:  "SilaDeneb Fork",
			Description:  `Sanity test to check the fork transition to deneb.`,
			DenebGenesis: false,
			GenesisExecutionWithdrawalCredentialsShares: 1,
			EpochsAfterFork:     1,
			ExitValidatorsShare: 10,
		},
		BaseTestSpec{
			Name:        "test-deneb-genesis",
			DisplayName: "SilaDeneb Genesis",
			Description: `
			Sanity test to check the beacon clients can start with deneb genesis.
			`,
			DenebGenesis: true,
			GenesisExecutionWithdrawalCredentialsShares: 1,
			WaitForFinality:     true,
			ExitValidatorsShare: 10,
		},
	)
}

func Suite(c *clients.ClientDefinitionsByRole) hivesim.Suite {
	suites.SuiteHydrate(&testSuite, c, Tests)
	return testSuite
}
