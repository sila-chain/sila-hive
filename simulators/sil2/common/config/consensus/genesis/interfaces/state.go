package interfaces

import (
	"github.com/sila-chain/go-sila/core/types"
	"github.com/protolambda/zrnt/sil2/beacon/common"
)

type StateViewGenesis interface {
	common.BeaconState
	ForkVersion() common.Version
	PreviousForkVersion() common.Version
	EmptyBodyRoot() common.Root
	SetGenesisExecutionHeader(genesisBlock *types.Block) error
	ToJson() ([]byte, error)
}
