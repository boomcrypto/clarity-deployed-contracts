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

String.prototype.hashCode = function () {
  var hash = 0;
  for (var i = 0; i < this.length; i++) {
    var character = this.charCodeAt(i);
    hash = (hash << 5) - hash + character;
    hash = hash & hash; // Convert to 32bit integer
  }
  return hash;
};

async function loadAll() {
  const hashes = {};
  let creators = 0;
  let contracts = 0;
  mkdirSync(`contracts`, { recursive: true });

  readdirSync("contracts").forEach((d) => {
    creators += 1;
    readdirSync(`contracts/${d}`).map((c) => {
      const content = readFileSync(`contracts/${d}/${c}`).toString();
      const hash = content.hashCode();
      if (hash in hashes) {
        hashes[hash].push(`${d}/${c}`);
      } else {
        contracts += 1;
        hashes[hash] = [`${d}/${c}`];
      }
    });
  });
  writeFileSync("count.txt", `creators=${creators}\ncontracts=${contracts}`);
  writeFileSync(
    "duplicates.txt",
    [
      ...Object.values(hashes)
        .filter((h) => h.length > 1)
        .map((h) => [...h].join("\n")),
    ].join("\n\n")
  );
}

loadAll();
