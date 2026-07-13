package suite_builder

import (
	"strings"

	"github.com/sila-chain/sila-hive/hivesim"
	"github.com/sila-chain/sila-hive/simulators/sil2/common/clients"
	"github.com/sila-chain/sila-hive/simulators/sil2/dencun/suites"
	suite_base "github.com/sila-chain/sila-hive/simulators/sil2/dencun/suites/base"
	"github.com/lithammer/dedent"
	mock_builder "github.com/marioevz/mock-builder/mock"
)

var testSuite = hivesim.Suite{
	Name:        "sil2-deneb-builder",
	DisplayName: "SilaDeneb Builder",
	Description: `
	Collection of test vectors that use a ExecutionClient+BeaconNode+ValidatorClient testnet and builder API for SilaCancun+SilaDeneb.
	`,
	Location: "suites/builder",
}

var Tests = make([]suites.TestSpec, 0)

func init() {
	Tests = append(Tests,
		BuilderTestSpec{
			BaseTestSpec: suite_base.BaseTestSpec{
				Name:        "test-builders-sanity",
				DisplayName: "SilaDeneb Builder Workflow From Capella Transition",
				Description: `
				Test canonical chain includes deneb payloads built by the builder api.`,
				// All validators start with BLS withdrawal credentials
				GenesisExecutionWithdrawalCredentialsShares: 0,
				DenebGenesis: true,
				WaitForBlobs: true,
			},
		},
		BuilderTestSpec{
			BaseTestSpec: suite_base.BaseTestSpec{
				Name:        "test-builders-invalid-payload-attributes-beacon-root",
				DisplayName: "SilaDeneb Builder Builds Block With Invalid Beacon Root, Correct State Root",
				Description: `
				Test canonical chain can still finalize if the builders start
				building payloads with invalid parent beacon block root.`,
				// All validators can withdraw from the start
				GenesisExecutionWithdrawalCredentialsShares: 1,
				DenebGenesis: true,
				WaitForBlobs: true,
			},
			InvalidatePayloadAttributes: mock_builder.INVALIDATE_ATTR_BEACON_ROOT,
		},
		BuilderTestSpec{
			BaseTestSpec: suite_base.BaseTestSpec{
				Name:        "test-builders-error-on-deneb-header-request",
				DisplayName: "SilaDeneb Builder Errors Out on Header Requests After SilaDeneb Transition",
				Description: `
				Test canonical chain can still finalize if the builders start
				returning error on header request after deneb transition.`,
				// All validators can withdraw from the start
				GenesisExecutionWithdrawalCredentialsShares: 1,
				DenebGenesis: true,
				WaitForBlobs: true,
			},
			ErrorOnHeaderRequest: true,
		},
		BuilderTestSpec{
			BaseTestSpec: suite_base.BaseTestSpec{
				Name:        "test-builders-error-on-deneb-unblind-payload-request",
				DisplayName: "SilaDeneb Builder Errors Out on Signed Blinded Beacon Block/Blob Sidecars Submission After SilaDeneb Transition",
				Description: `
				Test canonical chain can still finalize if the builders start
				returning error on unblinded payload request after deneb transition.`,
				// All validators can withdraw from the start
				GenesisExecutionWithdrawalCredentialsShares: 1,
				DenebGenesis: true,
				WaitForBlobs: true,
			},
			ErrorOnPayloadReveal: true,
		},
		BuilderTestSpec{
			BaseTestSpec: suite_base.BaseTestSpec{
				Name:        "test-builders-invalid-payload-version",
				DisplayName: "SilaDeneb Builder Builds Block With Invalid Payload Version",
				Description: `
				Test consensus clients correctly reject a built payload if the
				version is outdated (capella instead of deneb).`,
				// All validators can withdraw from the start
				GenesisExecutionWithdrawalCredentialsShares: 1,
				DenebGenesis: true,
				WaitForBlobs: true,
			},
			InvalidPayloadVersion: true,
		},
		BuilderTestSpec{
			BaseTestSpec: suite_base.BaseTestSpec{
				Name:        "test-builders-invalid-payload-beacon-root",
				DisplayName: "SilaDeneb Builder Builds Block With Invalid Beacon Root, Incorrect State Root",
				Description: `
				Test consensus clients correctly circuit break builder after a
				period of empty blocks due to invalid unblinded blocks.

				The payloads are built using an invalid parent beacon block root, which can only
				be caught after unblinding the entire payload and running it in the
				local execution client, at which point another payload cannot be
				produced locally and results in an empty slot.`,
				// All validators can withdraw from the start
				GenesisExecutionWithdrawalCredentialsShares: 1,
				DenebGenesis: true,
				WaitForBlobs: true,
			},
			InvalidatePayload: mock_builder.INVALIDATE_PAYLOAD_BEACON_ROOT,
		},
	)

	// Add clients that require finalization to the description of the suite
	sb := strings.Builder{}
	sb.WriteString(dedent.Dedent(testSuite.Description))
	sb.WriteString("\n\n")
	sb.WriteString("### Clients that require finalization to enable builder\n")
	for _, client := range REQUIRES_FINALIZATION_TO_ACTIVATE_BUILDER {
		sb.WriteString("- ")
		sb.WriteString(strings.Title(client))
		sb.WriteString("\n")
	}
	testSuite.Description = sb.String()
}

func Suite(c *clients.ClientDefinitionsByRole) hivesim.Suite {
	suites.SuiteHydrate(&testSuite, c, Tests)
	return testSuite
}
