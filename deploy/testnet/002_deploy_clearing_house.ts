import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
  ethers,
}: HardhatRuntimeEnvironment) {
  const { deploy, get } = deployments;
  const { utils } = ethers;
  const { deployer } = await getNamedAccounts();
  const fund = await get("InsuranceFund");
  await deploy("ClearingHouse", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: [fund.address, utils.parseUnits("0.02", "ether")],
        },
      },
    },
    skipIfAlreadyDeployed: true,
  });
};
export default func;
func.dependencies = ["InsuranceFund"];
func.tags = ["ClearingHouse"];
