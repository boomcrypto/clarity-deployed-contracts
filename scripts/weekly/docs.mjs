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

async function loadAll(config, path) {
  mkdirSync(`${path}`, { recursive: true });
  const lastBlockString = readFileSync(`${path}/last-block.txt`);
  const lastBlock = parseInt(lastBlockString);

  let name, sourceCode;
  mkdirSync(`${path}/contracts`, { recursive: true });

  readdirSync(`${path}/contracts`).forEach((d) => {
    mkdirSync(`${path}/docs/content/contracts/${d}`, { recursive: true });
    readdirSync(`${path}/contracts/${d}`).map((c) => {
      sourceCode = readFileSync(`${path}/contracts/${d}/${c}`);
      if (sourceCode.indexOf("(define-trait ") >= 0) {
        name = c.substring(0, c.length - 5);
        mkdirSync(`${path}/docs/content/traits/${d}`, { recursive: true });
        writeFileSync(
          `${path}/docs/content/traits/${d}/${name}.md`,
          `
---
title: ${name}
---
Deployer: ${d}
`
        );
      }
    });
  });
}

loadAll(
  new Configuration({
    basePath: "https://stacks-node-api.mainnet.stacks.co",
    fetchApi: fetch,
  }),
  "."
);
