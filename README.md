# clarity-deployed-contracts

This repo contains all deployed contracts on [Stacks blockchain](https://stacks.org).

Branch `main` contains contracts of mainnet. Updated via Github Actions daily.

Branch `testnet` contains contracts of testnet. Not maintained currently.

## Blacklist

Contracts that are seen as bad actors in general are listed in the file `blacklist.txt`. This is an opinonated selection.

## Content Creations

### Update from Blockchain

Change the api node in `scripts/constants.mjs` if you don't want to use Hiro's api node.

0. In branch `docs`, pull from remote to be up-to-date.
1. In branch `main`,
   1. call `pnpm run start` to pull new contracts since the last call (stored in `last-block.txt`).
   2. call `pnpm run update:name` to check all contract deployers and add them to a list if they own a BNS name.
   3. call `pnpm run update:hash` to create a list of duplicate contracts by hash of source code.
2. In branch `docs` (used for github pages)

### Add New Post
