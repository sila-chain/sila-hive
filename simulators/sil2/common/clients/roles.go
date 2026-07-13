package clients

import "github.com/sila-chain/sila-hive/hivesim"

type ClientDefinitionsByRole struct {
	Beacon    []*hivesim.ClientDefinition `json:"beacon"`
	Validator []*hivesim.ClientDefinition `json:"validator"`
	Sil1      []*hivesim.ClientDefinition `json:"sil1"`
	Other     []*hivesim.ClientDefinition `json:"Other"`
}

func ClientsByRole(
	available []*hivesim.ClientDefinition,
) *ClientDefinitionsByRole {
	var out ClientDefinitionsByRole
	for _, client := range available {
		if client.HasRole("beacon") {
			out.Beacon = append(out.Beacon, client)
		}
		if client.HasRole("validator") {
			out.Validator = append(out.Validator, client)
		}
		if client.HasRole("sil1") {
			out.Sil1 = append(out.Sil1, client)
		}
	}
	return &out
}

func (c *ClientDefinitionsByRole) ClientByNameAndRole(
	name, role string,
) *hivesim.ClientDefinition {
	switch role {
	case "beacon":
		return byName(c.Beacon, name)
	case "validator":
		return byName(c.Validator, name)
	case "sil1":
		return byName(c.Sil1, name)
	}
	return nil
}

func byName(
	clients []*hivesim.ClientDefinition,
	name string,
) *hivesim.ClientDefinition {
	for _, client := range clients {
		if client.Name == name {
			return client
		}
	}
	return nil
}

func (c *ClientDefinitionsByRole) Combinations() NodeDefinitions {
	var nodes NodeDefinitions
	for _, validator := range c.Validator {
		for _, beacon := range c.Beacon {
			for _, sil1 := range c.Sil1 {
				nodes = append(
					nodes,
					NodeDefinition{
						ExecutionClient: sil1.Name,
						ConsensusClient: beacon.Name,
						ValidatorClient: validator.Name,
					},
				)
			}
		}
	}
	return nodes
}
