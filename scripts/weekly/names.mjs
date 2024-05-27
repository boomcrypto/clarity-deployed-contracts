import { Configuration, NamesApi } from "@stacks/blockchain-api-client";
import { mkdirSync, readdirSync, writeFileSync } from "fs";
import fetch from "node-fetch";
import { basePath } from "../constants.mjs";

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
  ...Object.keys(names).map(
    (address) =>
      `|[${address}]({{<githubref>}}/tree/main/contracts/${address}) | ${names[address]}|`
  ),
].join("\n")}

Updated: ${new Date().toLocaleString("en-US", { timeZone: "UTC" })}
    `
  );
}

loadAllNames(
  new Configuration({
    basePath,
    fetchApi: fetch,
  })
);
