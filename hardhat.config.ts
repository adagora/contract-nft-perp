import { HardhatUserConfig } from "hardhat/config";
import { config as dotEnvConfig } from "dotenv";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";

dotEnvConfig();

const privateKeys = JSON.parse(process.env.PRIVATE_KEYS || "[]");

const supportedCompilers = ["0.8.13", "0.6.6"];

const config: HardhatUserConfig = {
  defaultNetwork: "testnet",
  solidity: {
    compilers: supportedCompilers.map((version) => ({
      version,
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    })),
  },
  networks: {
    polygon: {
      url: "https://polygon-rpc.com",
      timeout: 99999,
      chainId: 137,
      gasMultiplier: 1.3,
      accounts: privateKeys,
      deploy: ["./deploy/polygon/"],
      linkAddress: "0xb0897686c545045aFc77CF20eC7A532E3120E0F1",
    },
    testnet: {
      url: "https://matic-testnet-archive-rpc.bwarelabs.com",
      timeout: 99999,
      chainId: 80001,
      gasMultiplier: 1.3,
      accounts: privateKeys,
      deploy: ["./deploy/testnet/"],
      linkAddress: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
      verify: {
        etherscan: {
          apiUrl: "https://api-testnet.polygonscan.com",
          apiKey: process.env.POLYGONSCAN_API_KEY,
        },
      },
    },
  },
  typechain: {
    outDir: "typechain",
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};

export default config;
