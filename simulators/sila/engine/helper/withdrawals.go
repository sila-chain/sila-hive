package helper

import (
	"github.com/sila-chain/go-sila/common"
	"github.com/sila-chain/go-sila/core/types"
	"github.com/sila-chain/go-sila/trie"
)

var (
	EmptyWithdrawalsRootHash = &types.EmptyRootHash
)

func ComputeWithdrawalsRoot(ws types.Withdrawals) common.Hash {
	// Using RLP root but might change to ssz
	return types.DeriveSha(
		ws,
		trie.NewStackTrie(nil),
	)
}
