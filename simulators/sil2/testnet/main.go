package main

import (
	"fmt"

	"github.com/sila-chain/sila-hive/hivesim"
	"github.com/sila-chain/sila-hive/simulators/sil2/common/clients"
	cl "github.com/sila-chain/sila-hive/simulators/sil2/common/config/consensus"
	"github.com/sila-chain/sila-hive/simulators/sil2/common/testnet"
)

type testSpec struct {
	Name  string
	About string
	Run   func(*hivesim.T, *testnet.Environment, clients.NodeDefinition)
}

var tests = []testSpec{
	// {Name: "single-client-testnet", Run: Phase0Testnet},
	{Name: "transition-testnet", Run: TransitionTestnet},
}

func main() {
	var suite = hivesim.Suite{
		Name:        "sil2-testnet",
		Description: `Run different sil2 testnets.`,
	}
	suite.Add(hivesim.TestSpec{
		Name:        "sil2-testnets",
		Description: "Collection of different sil2 testnet compositions and assertions.",
		Run: func(t *hivesim.T) {
			clientTypes, err := t.Sim.ClientTypes()
			if err != nil {
				t.Fatal(err)
			}
			c := clients.ClientsByRole(clientTypes)
			if len(c.Sil1) != 1 {
				t.Fatalf("choose 1 sil1 client type")
			}
			if len(c.Beacon) != 1 {
				t.Fatalf("choose 1 beacon client type")
			}
			if len(c.Validator) != 1 {
				t.Fatalf("choose 1 validator client type")
			}
			runAllTests(t, c)
		},
	})
	hivesim.MustRunSuite(hivesim.New(), suite)
}

func runAllTests(t *hivesim.T, c *clients.ClientDefinitionsByRole) {
	mnemonic := "couple kiwi radio river setup fortune hunt grief buddy forward perfect empty slim wear bounce drift execute nation tobacco dutch chapter festival ice fog"

	// Generate validator keys to use for all tests.
	keySrc := &cl.MnemonicsKeySource{
		From:     0,
		To:       64,
		Mnemonic: mnemonic,
	}
	keys, err := keySrc.Keys()
	if err != nil {
		t.Fatal(err)
	}
	for _, node := range c.Combinations() {
		for _, test := range tests {
			test := test
			t.Run(hivesim.TestSpec{
				Name:        fmt.Sprintf("%s-%s", test.Name, node.String()),
				Description: test.About,
				Run: func(t *hivesim.T) {
					env := &testnet.Environment{
						Clients:    c,
						Validators: keys,
					}
					test.Run(t, env, node)
				},
			})
		}
	}
}

/*
	TODO More testnet ideas:

	Name:        "two-client-testnet",
	Description: "This runs quick sil2 testnets with combinations of 2 client types, beacon nodes matched with preferred validator type, and dummy sil1 endpoint.",
	Name:        "all-client-testnet",
	Description: "This runs a quick sil2 testnet with all client types, beacon nodes matched with preferred validator type, and dummy sil1 endpoint.",
	Name:        "cross-single-client-testnet",
	Description: "This runs a quick sil2 single-client testnet, but beacon nodes are matched with all validator types",
*/
