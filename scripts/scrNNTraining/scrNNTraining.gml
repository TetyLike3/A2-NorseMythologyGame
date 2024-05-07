// Neural Network Training

/// @func	NN_GenerateDefaultNetwork(inputCount, outputCount);
/// @desc	Creates a general neural network
/// @param	{real} inputCount How many input nodes the network will have
/// @param	{real} outputCount How many output nodes the network will have
function NN_GenerateDefaultNetwork(_inputCount, _outputCount) {
	var newNetwork = new NeuralTapedNetwork();
	newNetwork.add.Input(_inputCount);
	newNetwork.add.Dense(_inputCount*2, NNActivationType.IDENTITY);
	newNetwork.add.Dense(_inputCount*3, NNActivationType.TANH);
	newNetwork.add.Dense((_inputCount*3)+2, NNActivationType.IDENTITY);
	newNetwork.add.Dense((_outputCount*5), NNActivationType.IDENTITY);
	newNetwork.add.Dense((_outputCount*4)+2, NNActivationType.TANH);
	newNetwork.add.Dense((_outputCount*3)+2, NNActivationType.IDENTITY);
	newNetwork.add.Dense((_outputCount*2)+3, NNActivationType.TANH);
	newNetwork.add.Dense((_outputCount*2)+1, NNActivationType.IDENTITY);
	newNetwork.add.Dense((_outputCount*2), NNActivationType.IDENTITY);
	newNetwork.add.Dense(_outputCount, NNActivationType.IDENTITY);
	
	return newNetwork;
}

/// @func	NN_GenerateDefaultNetworks(count, inputCount, outputCount);
/// @desc	Creates multiple neural networks
/// @param	{real} count How many neural networks to generate
/// @param	{real} inputCount How many input nodes each network will have
/// @param	{real} outputCount How many output nodes each network will have
function NN_GenerateDefaultNetworks(_count, _inputCount, _outputCount) {
	var networks = [];
	for (var i = 0; i < _count; i++) {
		networks[i] = NN_GenerateDefaultNetwork(_inputCount,_outputCount);
	}
	return networks;
}