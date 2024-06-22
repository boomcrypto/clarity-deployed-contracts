import {
  Configuration,
  GetTransactionListTypeEnum,
  InfoApi,
  SmartContractsApi,
  TransactionsApi,
} from "@stacks/blockchain-api-client";
import { mkdirSync, readFileSync, readdirSync, writeFileSync } from "fs";
import fetch from "node-fetch";
import { basePath } from "./constants.mjs";

const sip9TraitPath =
  "SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9/nft-trait/nft-trait";
const sip10TraitPath =
  "SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE/sip-010-trait-ft-standard/sip-010-trait";
const commissionTraitPath =
  "SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9/commission-trait/commission-trait";
const operableTraitPath =
  "SPGAKH27HF1T170QET72C727873H911BKNMPF8YB/operable/operable";

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

function writeSourceCode(path, address, name, sourceCode) {
  mkdirSync(`${path}/contracts/${address}`, { recursive: true });
  writeFileSync(`${path}/contracts/${address}/${name}.clar`, sourceCode);
}

function writeSip9(path, address, name, contractInterface) {
  writeFileSync(
    `${path}/docs/content/assets/sip9/${address}.${name}.md`,
    `---
title: "Non-Fungible Token ${name}"
draft: true
---`
  );
}

function writeSip10(path, address, name, contractInterface) {
  writeFileSync(
    `${path}/docs/content/assets/sip10/${address}.${name}.md`,
    `---
title: "Non-Fungible Token ${name}"
draft: true
---`
  );
}

function writeTrait(path, address, name, sourceCode) {
  writeFileSync(
    `${path}/docs/content/traits/${address}.${name}.md`,
    `---
title: "Trait ${name}"
draft: true
---
` +
      "```\n" +
      sourceCode +
      "\n```\n"
  );
}

function writeContractDocDraft(
  path,
  address,
  name,
  block_height,
  burn_block_time_iso,
  contractInterface,
  sip9,
  sip10,
  commission,
  operable
) {
  writeFileSync(
    `${path}/docs/content/contracts/${address}.${name}.md`,
    `---
title: "Contract ${name}"
draft: true
---
Deployer: ${address}

${sip9 || sip10 || commission || operable ? "Traits:" : ""}
${sip9 ? "SIP-009" : ""} ${sip10 ? "SIP-0010" : ""}
${commission ? "Commission" : ""}
${operable ? "Operable" : ""}

Block height: ${block_height} (${burn_block_time_iso})

Source code: {{<contractref "${name}" ${address} ${name}>}}

Functions:

${contractInterface.functions
  .map((f) => `* ${f.name} _${f.access}_`)
  .join("\n")}
`
  );

  writeFileSync(
    `${path}/docs/data/contracts/${address}.${name}.json`,
    JSON.stringify({
      address,
      name,
      block_height,
      burn_block_time_iso,
      contractInterface,
      sip9,
      sip10,
      commission,
      operable,
    })
  );
}

function writeContractIndex(path, contracts) {
  writeFileSync(
    `${path}/docs/content/references/contracts/index.md`,
    `---
title: "Contracts"
---
${contracts
  .map(
    (c) =>
      `[${c.address}.${c.name}]({{<githubref>}}/blob/main/contracts/${c.address}/${c.name}.clar)`
  )
  .join("\n")}
`
  );
}

async function implementedSip9(config, address, name) {
  const url = `${config.basePath}/v2/traits/${address}/${name}/${sip9TraitPath}`;
  try {
    const result = await (await fetch(url)).json();
    return result && result.is_implemented;
  } catch (e) {
    console.log(url, e);
    return false;
  }
}

async function implementedSip10(config, address, name) {
  const url = `${config.basePath}/v2/traits/${address}/${name}/${sip10TraitPath}`;
  try {
    const result = await (await fetch(url)).json();
    return result && result.is_implemented;
  } catch (e) {
    console.log(url, e);
    return false;
  }
}

async function implementedCommission(config, address, name) {
  const url = `${config.basePath}/v2/traits/${address}/${name}/${commissionTraitPath}`;
  try {
    const result = await (await fetch(url)).json();
    return result && result.is_implemented;
  } catch (e) {
    console.log(url, e);
    return false;
  }
}

async function implementedOperable(config, address, name) {
  const url = `${config.basePath}/v2/traits/${address}/${name}/${operableTraitPath}`;
  try {
    const result = await (await fetch(url)).json();
    return result && result.is_implemented;
  } catch (e) {
    console.log(url, e);
    return false;
  }
}

function definesTrait(sourceCode) {
  return sourceCode.indexOf("(define-trait " >= 0);
}

async function handleNewContracts({ config, path, updateAll }) {
  const api = new SmartContractsApi(config);
  const transactionsApi = new TransactionsApi(config);
  const infoApi = new InfoApi(config);

  mkdirSync(`${path}`, { recursive: true });
  const lastBlockString = readFileSync(`${path}/last-block.txt`);
  const lastBlock = parseInt(lastBlockString);

  // update last block
  const coreInfo = await infoApi.getCoreApiInfo();
  console.log("current stacks height", coreInfo.stacks_tip_height);

  // setup contracts
  mkdirSync(`${path}/contracts`, { recursive: true });
  // setup docs
  mkdirSync(`${path}/docs/content/contracts`, { recursive: true });
  mkdirSync(`${path}/docs/content/assets/sip9`, { recursive: true });
  mkdirSync(`${path}/docs/content/assets/sip10`, { recursive: true });
  mkdirSync(`${path}/docs/content/traits`, { recursive: true });
  mkdirSync(`${path}/docs/content/references`, { recursive: true });
  mkdirSync(`${path}/docs/data/contracts`, { recursive: true });

  // read existing contracts
  let contracts = [];

  readdirSync(`${path}/contracts`).forEach((address) => {
    contracts = contracts.concat(
      readdirSync(`${path}/contracts/${address}`).map(
        (contractFilename) => `${address}/${contractFilename}`
      )
    );
  });
  console.log("in cache:", contracts.length);

  let offset = 0;
  let total = 1;
  while (offset < total) {
    const pageOfTxs = await transactionsApi.getTransactionList({
      offset,
      type: [GetTransactionListTypeEnum.smart_contract],
    });

    // update total
    total = pageOfTxs.total;
    console.log({
      offset,
      total,
      lastBlock,
      currentBlock: pageOfTxs.results[0].block_height,
    });

    // do not continue if already handled
    if (
      pageOfTxs.results.length > 0 &&
      pageOfTxs.results[0].block_height <= lastBlock
    ) {
      break;
    }

    const contractTxs = pageOfTxs.results.filter(
      (t) => t.tx_status === "success"
    );

    // handle transactions
    for (let t of contractTxs) {
      const [address, name] = t.smart_contract.contract_id.split(".");
      const contractFilename = `${name}.clar`;

      if (
        updateAll ||
        address === "SPC0KWNBJ61BDZRPF3W2GHGK3G3GKS8WZ7ND33PS" ||
        contracts.indexOf(`${address}/${contractFilename}`) < 0
      ) {
        try {
          if (address === "SPC0KWNBJ61BDZRPF3W2GHGK3G3GKS8WZ7ND33PS") {
            console.log(`handling ${address}.${name}`);
          }
          const sourceCode = t.smart_contract.source_code;
          const { block_height, burn_block_time_iso } = t;
          // the tx contains already the source code, no need to
          // make another api call.
          // do the api call if you want to verify the api
          //await downloadSource(address, name);

          writeSourceCode(path, address, name, sourceCode);
          contracts.push(`${address}/${name}.clar`);

          // will fail for contracts without any public functions
          const contractInterface = await api
            .getContractInterface({
              contractAddress: address,
              contractName: name,
            })
            .catch((_) => {
              return {
                noContract: true,
                functions: [],
                fungible_tokens: [],
                maps: [],
                non_fungible_tokens: [],
                variables: [],
              };
            });

          const sip9 = await implementedSip9(config, address, name);
          const sip10 = await implementedSip10(config, address, name);
          const commission = await implementedCommission(config, address, name);
          const operable = await implementedOperable(config, address, name);

          writeContractDocDraft(
            path,
            address,
            name,
            block_height,
            burn_block_time_iso,
            contractInterface,
            sip9,
            sip10,
            commission,
            operable
          );

          if (sip9) {
            writeSip9(path, address, name, contractInterface);
          }
          if (sip10) {
            writeSip10(path, address, name, contractInterface);
          }
          if (definesTrait(sourceCode)) {
            writeTrait(path, address, name, sourceCode);
          }
        } catch (e) {
          console.log(e, t.tx_id);
          console.log(`failed to download ${address}.${name}`);
        }
      }
    }
    offset += pageOfTxs.results.length;
  }
  writeFileSync(
    `${path}/last-block.txt`,
    coreInfo.stacks_tip_height.toString()
  );
  console.log(contracts.length);
}

handleNewContracts({
  config: new Configuration({
    basePath,
    fetchApi: fetch,
  }),
  path: ".",
  updateAll: true,
});
