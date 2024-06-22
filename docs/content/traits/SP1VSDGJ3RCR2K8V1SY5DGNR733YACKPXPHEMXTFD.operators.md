---
title: "Trait operators"
draft: true
---
```
(use-trait ft-trait 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.ft-trait.ft-trait) (define-public (set-owner (new-owner principal)) (contract-call? 'SPB75ZW15C90ZNDPQF4GSVNGBEJJA6WACZKNFVFK.vault-v1 set-owner new-owner)) (set-owner tx-sender) (define-public (set-enabled (enabled bool)) (contract-call? 'SPB75ZW15C90ZNDPQF4GSVNGBEJJA6WACZKNFVFK.vault-v1 set-enabled enabled)) (set-enabled false) (define-public (add-approved-contract (new-approved-contract principal)) (contract-call? 'SPB75ZW15C90ZNDPQF4GSVNGBEJJA6WACZKNFVFK.vault-v1 add-approved-contract new-approved-contract)) (define-public (remove-approved-contract (approved-contract principal)) (contract-call? 'SPB75ZW15C90ZNDPQF4GSVNGBEJJA6WACZKNFVFK.vault-v1 remove-approved-contract approved-contract)) (define-public (claim (token <ft-trait>) (amount uint) (recipient principal)) (contract-call? 'SPB75ZW15C90ZNDPQF4GSVNGBEJJA6WACZKNFVFK.vault-v1 transfer-ft token amount recipient))
```
