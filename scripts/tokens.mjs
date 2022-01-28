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
import {
  Configuration,
  SmartContractsApi,
} from "@stacks/blockchain-api-client";
import fetch from "node-fetch";

async function loadAll(config) {
  const smartContractsApi = new SmartContractsApi(config);
  const sip9TraitPath =
    "SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9/nft-trait/nft-trait";
  const sip10TraitPath =
    "SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE/sip-010-trait-ft-standard/sip-010-trait";
  const sip10 = {};
  const sip9 = {};
  let url, name, result;
  let creators = 0;
  let contracts = 0;
  mkdirSync(`contracts`, { recursive: true });

  for (let d of readdirSync("contracts")) {
    console.log(d)
    for (let c of readdirSync(`contracts/${d}`)) {
      name = c.substring(0, c.length - 5);
      url = `${config.basePath}/v2/traits/${d}/${name}/${sip9TraitPath}`;
      try {
        result = await (await fetch(url)).json();
        if (result && result.is_implemented) {
          sip9[d] = `${d}.${name}`;
        }
      } catch (e) {
        console.log(url, e);
      }
      try {
        url = `${config.basePath}/v2/traits/${d}/${name}/${sip10TraitPath}`;
        result = await (await fetch(url)).json();
        if (result && result.is_implemented) {
          sip10[d] = `${d}.${name}`;
        }
      } catch (e) {
        console.log(url, e);
      }
    }
  }
  writeFileSync(
    "sip9.txt",
    [
      ...Object.keys(sip9).map((address) => `${address}, ${sip9[address]}`),
    ].join("\n")
  );
  writeFileSync(
    "sip10.txt",
    [
      ...Object.keys(sip10).map((address) => `${address}, ${sip10[address]}`),
    ].join("\n")
  );
  console.log({sip9: Object.keys(sip9).length})
  console.log({sip10: Object.keys(sip10).length})
}

loadAll(
  new Configuration({
    basePath: "http://localhost:3999",
    fetchApi: fetch,
  })
);
