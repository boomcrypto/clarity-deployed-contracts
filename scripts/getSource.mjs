import {
  Configuration,
  GetTransactionListTypeEnum,
  InfoApi,
  SmartContractsApi,
  TransactionsApi,
} from "@stacks/blockchain-api-client";
import { txidFromData } from "@stacks/transactions";
import {
  existsSync,
  mkdir,
  mkdirSync,
  readFileSync,
  readdir,
  readdirSync,
  rmSync,
  writeFileSync,
} from "fs";
import fetch from "node-fetch";

async function downloadSource(contractAddress, contractName, path) {
  console.log(`downloading ${contractAddress}.${contractName}`);
  const result = await api.getContractSource({
    contractAddress,
    contractName,
  });
  mkdirSync(`${path}/contracts/${contractAddress}`, { recursive: true });
  writeFileSync(
    `${path}/contracts/${contractAddress}/${contractName}.clar`,
    result.source
  );
}

async function loadAll(config, path) {
  const api = new SmartContractsApi(config);
  const transactionsApi = new TransactionsApi(config);
  const infoApi = new InfoApi(config);

  mkdirSync(`${path}`, { recursive: true });
  const lastBlockString = readFileSync(`${path}/last-block.txt`);
  const lastBlock = parseInt(lastBlockString);

  const coreInfo = await infoApi.getCoreApiInfo();
  console.log(coreInfo.stacks_tip_height);
  writeFileSync(
    `${path}/last-block.txt`,
    coreInfo.stacks_tip_height.toString()
  );

  let contracts = [];
  mkdirSync(`${path}/contracts`, { recursive: true });
  readdirSync(`${path}/contracts`).forEach((d) => {
    contracts = contracts.concat(
      readdirSync(`${path}/contracts/${d}`).map((c) => `${d}/${c}`)
    );
  });
  console.log("cached already", contracts.length);

  let offset = 0;
  let total = 1;
  while (offset < total) {
    const paged = await transactionsApi.getTransactionList({
      offset,
      type: [GetTransactionListTypeEnum.smart_contract],
    });
    total = paged.total;
    console.log({
      offset,
      total,
      lastBlock,
      currentBlock: paged.results[0].block_height,
    });
    if (
      paged.results.length > 0 &&
      paged.results[0].block_height <= lastBlock
    ) {
      break;
    }
    for (let t of paged.results.filter((t) => t.tx_status === "success")) {
      const [address, name] = t.smart_contract.contract_id.split(".");
      if (contracts.indexOf(`${address}/${name}.clar`) < 0) {
        try {
          console.log(`handling ${address}.${name}`);
          mkdirSync(`${path}/contracts/${address}`, { recursive: true });
          writeFileSync(
            `${path}/contracts/${address}/${name}.clar`,
            t.smart_contract.source_code
          );
          contracts.push(`${address}/${name}.clar`);
          //await downloadSource(address, name);
        } catch (e) {
          console.log(e, t.tx_id);
          console.log(`failed to download ${address}.${name}`);
        }
      }
    }
    offset += paged.results.length;
  }
  console.log(contracts.length);
}

loadAll(
  new Configuration({
    basePath: "https://stacks-node-api.mainnet.stacks.co",
    fetchApi: fetch,
  }),
  "."
);


loadAll(
  new Configuration({
    basePath: "https://stacks-node-api.testnet.stacks.co",
    fetchApi: fetch,
  }),
  "testnet"
);
