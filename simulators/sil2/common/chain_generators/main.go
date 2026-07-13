package chaingenerators

import (
	"github.com/sila-chain/go-sila/core/types"
	el "github.com/sila-chain/sila-hive/simulators/sil2/common/config/execution"
)

type ChainGenerator interface {
	Generate(*el.ExecutionGenesis) ([]*types.Block, error)
}
