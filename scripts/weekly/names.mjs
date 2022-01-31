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
import { Configuration, NamesApi } from "@stacks/blockchain-api-client";
import fetch from "node-fetch";

async function loadAllNames(config) {
  const namesApi = new NamesApi(config);
  const names = {};
  let creators = 0;
  let contracts = 0;
  mkdirSync(`contracts`, { recursive: true });
  mkdirSync(`docs/content/references`, { recursive: true });

  for (let d of readdirSync("contracts")) {
    const usernames = await namesApi.getNamesOwnedByAddress({
      blockchain: "stacks",
      address: d,
    });
    console.log(usernames.names, d);
    if (usernames?.names && usernames.names.length > 0) {
      names[d] = usernames.names[0];
    }
  }
  writeFileSync(
    "names.txt",
    [
      ...Object.keys(names).map((address) => `${address}, ${names[address]}`),
    ].join("\n")
  );
  writeFileSync(
    "docs/content/references/accounts.md",
    `
---
title: "Accounts"
---
List of accounts that deployed a contract AND own a name

| Address| Current Name|
| -------|-------------|
${[
      ...Object.keys(names).map((address) => `|[${address}]({{<githubref>}}/tree/main/contracts/${address}) | ${names[address]}|`),
    ].join("\n")}

Updated: ${new Date().toLocaleString("en-US", { timeZone: 'UTC' })}
    `
  );
}

loadAllNames(
  new Configuration({
    basePath: "https://stacks-node-api.mainnet.stacks.co",
    //basePath: "http://localhost:3999",
    fetchApi: fetch,
  })
);
