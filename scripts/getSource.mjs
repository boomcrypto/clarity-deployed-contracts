import {
  Configuration,
  GetTransactionListTypeEnum,
  InfoApi,
  SmartContractsApi,
  TransactionsApi,
} from "@stacks/blockchain-api-client";
import { txidFromData } from "@stacks/transactions";
import {
  mkdir,
  mkdirSync,
  readdir,
  readdirSync,
  rmSync,
  writeFileSync,
} from "fs";
import fetch from "node-fetch";

const STACKS_API_URL = "https://stacks-node-api.mainnet.stacks.co";

const config = new Configuration({
  basePath: STACKS_API_URL,
  fetchApi: fetch,
});

const api = new SmartContractsApi(config);
const transactionsApi = new TransactionsApi(config);
const infoApi = new InfoApi(config);

async function downloadSource(contractAddress, contractName) {
  console.log(`downloading ${contractAddress}.${contractName}`);
  const result = await api.getContractSource({
    contractAddress,
    contractName,
  });
  mkdirSync(`contracts/${contractAddress}`, { recursive: true });
  writeFileSync(
    `contracts/${contractAddress}/${contractName}.clar`,
    result.source
  );
}

async function loadAll() {
  const coreInfo = await infoApi.getCoreApiInfo();
  console.log(coreInfo.stacks_tip_height)
  writeFileSync(
    "last-block.txt",
    coreInfo.stacks_tip_height.toString()
  );
  let contracts = [];
  readdirSync("contracts").forEach((d) => {
    contracts = contracts.concat(
      readdirSync(`contracts/${d}`).map((c) => `${d}.${c}`)
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
    console.log({ offset, total });
    for (let t of paged.results.filter((t) => t.tx_status === "success")) {
      const [address, name] = t.smart_contract.contract_id.split(".");
      if (contracts.indexOf(`${address}.${name}.clar`) < 0) {
        try {
          console.log(`handling ${address}.${name}`);
          mkdirSync(`contracts/${address}`, { recursive: true });
          writeFileSync(
            `contracts/${address}/${name}.clar`,
            t.smart_contract.source_code
          );
          //await downloadSource(address, name);
        } catch (e) {
          console.log(e, t.tx_id);
          console.log(`failed to download ${address}.${name}`);
        }
      }
    }
    offset += paged.results.length;
  }
}

loadAll();
