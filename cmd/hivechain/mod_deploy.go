package main

import (
	"github.com/sila-chain/go-sila/common"
	"github.com/sila-chain/go-sila/common/hexutil"
	"github.com/sila-chain/go-sila/core/types"
	"github.com/sila-chain/go-sila/crypto"
	"github.com/sila-chain/go-sila/params"
)

func init() {
	register("deploy-callme", func() blockModifier {
		return &modDeploy{code: callmeCode}
	})
	register("deploy-callenv", func() blockModifier {
		return &modDeploy{code: callenvCode}
	})
	register("deploy-callrevert", func() blockModifier {
		return &modDeploy{code: callrevertCode}
	})
}

type modDeploy struct {
	code []byte
	info *deployTxInfo
}

type deployTxInfo struct {
	Contract common.Address `json:"contract"`
	Block    hexutil.Uint64 `json:"block"`
}

func (m *modDeploy) apply(ctx *genBlockContext) bool {
	if m.info != nil {
		return false // already deployed
	}

	code, gas := codeToDeploy(ctx, m.code)
	if !ctx.HasGas(gas) {
		return false
	}

	sender := ctx.TxSenderAccount()
	nonce := ctx.AccountNonce(sender.addr)
	ctx.AddNewTx(sender, &types.LegacyTx{
		Nonce:    nonce,
		Gas:      gas,
		GasPrice: ctx.TxGasFeeCap(),
		Data:     code,
	})
	m.info = &deployTxInfo{
		Contract: crypto.CreateAddress(sender.addr, nonce),
		Block:    hexutil.Uint64(ctx.block.Number().Uint64()),
	}
	return true
}

func (m *modDeploy) txInfo() any {
	return m.info
}

func codeToDeploy(ctx *genBlockContext, code []byte) (constructor []byte, gas uint64) {
	constructor = append(constructor, deployerCode...)
	constructor = append(constructor, code...)
	gas = ctx.TxCreateIntrinsicGas(code)
	gas += uint64(len(code)) * params.CreateDataGas
	gas += 15000 // extra gas for constructor execution
	return
}
