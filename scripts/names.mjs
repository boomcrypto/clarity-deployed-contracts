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

async function loadAll(config) {
  const namesApi = new NamesApi(config);
  const names = {};
  let creators = 0;
  let contracts = 0;
  mkdirSync(`contracts`, { recursive: true });

  for (let d of readdirSync("contracts")) {
    const usernames = await namesApi.getNamesOwnedByAddress({
      blockchain: "stacks",
      address: d,
    });
    console.log(usernames.names, d)
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
}

loadAll(
  new Configuration({
    basePath: "http://localhost:3999",
    fetchApi: fetch,
  })
);
