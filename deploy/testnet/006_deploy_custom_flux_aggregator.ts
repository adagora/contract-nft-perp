import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { BigNumber, utils, constants } from "ethers";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
  network,
}: HardhatRuntimeEnvironment) {
  const { deploy, execute, get, read } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainlinkPriceFeed = await get("ChainlinkPriceFeed");

  const validatorContract = await deploy("AcceptAllValidator", {
    from: deployer,
    skipIfAlreadyDeployed: true,
  });

  const linkTokenAddress = network.config.linkAddress;
  const paymentAmount = BigNumber.from("10000000000000000");
  const timeout = 100;
  const validator = validatorContract.address;
  const minSubmissionValue = 0;
  const maxSubmissionValue = BigNumber.from("100000000000000000000000");
  const decimals = 18;
  const description = "TEST Collection price";

  const aggregator = await deploy("CustomFluxAggregator", {
    from: deployer,
    skipIfAlreadyDeployed: true,
    args: [
      linkTokenAddress,
      paymentAmount,
      timeout,
      validator,
      minSubmissionValue,
      maxSubmissionValue,
      decimals,
      description
    ]
  });

  const readTx = await read(
    "ChainlinkPriceFeed",
    "getAggregator",
    utils.formatBytes32String("TEST"));


  if (readTx === constants.AddressZero) {
    await execute(
      "ChainlinkPriceFeed",
      { from: deployer, log: true },
      "addAggregator",
      utils.formatBytes32String("TEST"),
      aggregator.address
    );
  }
};
export default func;
func.dependencies = ["ChainlinkPriceFeed"];
func.tags = ["CustomFluxAggregator"];