import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const COLLECTION_PRICE_IN_USDC = "1000";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
  ethers,
}: HardhatRuntimeEnvironment) {
  const { deploy, get } = deployments;
  const { utils } = ethers;
  const { deployer } = await getNamedAccounts();
  const usdc = await get("MockUSDC");
  const priceFeed = await get("ChainlinkPriceFeed");

  const usdcReserve = utils.parseEther("10000000");
  const collectionReserve = usdcReserve.mul(COLLECTION_PRICE_IN_USDC);

  await deploy("Amm", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          methodName: "initialize",
          args: [
            usdcReserve,
            collectionReserve,
            utils.parseEther("0.9"), //trade limit ratio
            28800, // funding period
            priceFeed.address,
            utils.formatBytes32String("TEST"), // price feed key
            usdc.address,
            utils.parseEther("0.025"), // fluctuationLimitRatio
            utils.parseEther("0.003"), // feeRatio],
          ],
        },
      },
    },
    skipIfAlreadyDeployed: true,
  });
};
export default func;
func.dependencies = ["PriceFeed", "MockUSDC"];
func.tags = ["TestAmm"];
