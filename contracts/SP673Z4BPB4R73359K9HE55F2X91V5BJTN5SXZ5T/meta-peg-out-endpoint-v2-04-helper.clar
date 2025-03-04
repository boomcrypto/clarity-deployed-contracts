;; SPDX-License-Identifier: BUSL-1.1

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-public (claim-and-finalize-peg-out-on-index (request-id uint) (fulfilled-by (buff 128))
  (tx { bitcoin-tx: (buff 32768), output: uint, offset: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) }))
  (token-trait <ft-trait>))
  (begin 
    (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04 claim-peg-out request-id fulfilled-by))
    (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-04 finalize-peg-out-on-index request-id tx block proof signature-packs token-trait)))
