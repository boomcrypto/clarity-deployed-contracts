;; Title: pyth-governance
;; Version: v1
;; Check for latest version: https://github.com/hirosystems/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/hirosystems/stacks-pyth-bridge/issues

(use-trait pyth-proxy-trait .pyth-traits-v1.proxy-trait)
(use-trait pyth-decoder-trait .pyth-traits-v1.decoder-trait)
(use-trait pyth-storage-trait .pyth-traits-v1.storage-trait)
(use-trait wormhole-core-trait .wormhole-traits-v1.core-trait)

(define-constant PTGM_MAGIC 0x5054474d) ;; 'PTGM': Pyth Governance Message

;; VAA including some commands for administrating Pyth contract
;; The oracle contract address must be upgraded
(define-constant PTGM_UPDATE_PYTH_ORACLE_ADDRESS 0x00)
;; Authorize governance change
(define-constant PTGM_UPDATE_GOVERNANCE_DATA_SOURCE 0x01)
;; Which wormhole emitter is allowed to send price updates
(define-constant PTGM_UPDATE_PRICES_DATA_SOURCES 0x02)
;; Fee is charged when you submit a new price
(define-constant PTGM_UPDATE_FEE 0x03)
;; Stale price threshold 
(define-constant PTGM_STALE_PRICE_THRESHOLD 0x04)
;; Upgrade wormhole contract 
(define-constant PTGM_UPDATE_WORMHOLE_CORE_ADDRESS 0x06)
;; Special Stacks operation: update recipient address
(define-constant PTGM_UPDATE_RECIPIENT_ADDRESS 0xa0)
;; Special Stacks operation: update storage contract address
(define-constant PTGM_UPDATE_PYTH_STORE_ADDRESS 0xa1)
;; Special Stacks operation: update decoder contract address
(define-constant PTGM_UPDATE_PYTH_DECODER_ADDRESS 0xa2)
;; Stacks chain id attributed by Pyth
(define-constant EXPECTED_CHAIN_ID (if is-in-mainnet 0xea86 0xc377))
;; Stacks module id attributed by Pyth
(define-constant EXPECTED_MODULE 0x03)

;; Error unauthorized control flow
(define-constant ERR_UNAUTHORIZED_ACCESS (err u4004))
;; Error unexpected action
(define-constant ERR_UNEXPECTED_ACTION (err u4001))
;; Error unexpected action payload
(define-constant ERR_UNEXPECTED_ACTION_PAYLOAD (err u4002))
;; Error unexpected action
(define-constant ERR_INVALID_ACTION_PAYLOAD (err u4003))
;; Error outdated action
(define-constant ERR_OUTDATED (err u4005))
;; Error unauthorized update
(define-constant ERR_UNAUTHORIZED_UPDATE (err u4006))
;; Error parsing PGTM
(define-constant ERR_INVALID_PTGM (err u4007))

(define-data-var governance-data-source 
  { emitter-chain: uint, emitter-address: (buff 32) }
  { emitter-chain: u0, emitter-address: 0x5635979a221c34931e32620b9293a463065555ea71fe97cd6237ade875b12e9e })
(define-data-var prices-data-sources 
  (list 255 { emitter-chain: uint, emitter-address: (buff 32) })
  (list
    { emitter-chain: u1, emitter-address: 0x6bb14509a612f01fbbc4cffeebd4bbfb492a86df717ebe92eb6df432a3f00a25 }
    { emitter-chain: u26, emitter-address: 0xf8cd23c2ab91237730770bbea08d61005cdda0984348f3f6eecb559638c0bba0 }
    { emitter-chain: u26, emitter-address: 0xe101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa71 }))
(define-data-var fee-value 
  { mantissa: uint, exponent: uint } 
  { mantissa: u1, exponent: u1 })
(define-data-var stale-price-threshold uint (if is-in-mainnet (* u2 u60 u60) (* u5 u365 u24 u60 u60))) ;; defaults: 2 hours on Mainnet, 5 years on Testnet
(define-data-var fee-recipient-address principal (if is-in-mainnet 'SP3CRXBDXQ2N5P7E25Q39MEX1HSMRDSEAP3CFK2Z3 'ST3CRXBDXQ2N5P7E25Q39MEX1HSMRDSEAP1JST19D))
(define-data-var last-sequence-processed uint u0)

;; Execution plan management
(define-data-var current-execution-plan { 
  pyth-oracle-contract: principal,
  pyth-decoder-contract: principal, 
  pyth-storage-contract: principal,
  wormhole-core-contract: principal
} { 
    pyth-oracle-contract: .pyth-oracle-v1,
    pyth-decoder-contract: .pyth-pnau-decoder-v1, 
    pyth-storage-contract: .pyth-store-v1,
    wormhole-core-contract: .wormhole-core-v1
})

(define-read-only (check-execution-flow 
  (former-contract-caller principal)
  (execution-plan-opt (optional {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  })))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (success (if (is-eq contract-caller (get pyth-storage-contract expected-execution-plan))
          ;; The storage contract is checking its execution flow
          ;; Must always be invoked by the proxy
          (try! (expect-contract-call-performed-by-expected-oracle-contract former-contract-caller expected-execution-plan))
          ;; Other contract
          (if (is-eq contract-caller (get pyth-decoder-contract expected-execution-plan))
            ;; The decoding contract is checking its execution flow
            (try! (expect-contract-call-performed-by-expected-oracle-contract former-contract-caller expected-execution-plan))
            (if (is-eq contract-caller (get pyth-oracle-contract expected-execution-plan))
              ;; The proxy contract is checking its execution flow
              (let ((execution-plan (unwrap! execution-plan-opt ERR_UNAUTHORIZED_ACCESS)))
                ;; Ensure that storage contract is the one expected
                (try! (expect-active-storage-contract (get pyth-storage-contract execution-plan) expected-execution-plan))
                ;; Ensure that decoder contract is the one expected
                (try! (expect-active-decoder-contract (get pyth-decoder-contract execution-plan) expected-execution-plan))
                ;; Ensure that wormhole contract is the one expected
                (try! (expect-active-wormhole-contract (get wormhole-core-contract execution-plan) expected-execution-plan)))
              false)))))
      (if success (ok true) ERR_UNAUTHORIZED_ACCESS)))

(define-read-only (check-storage-contract 
  (storage-contract <pyth-storage-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan)))
      ;; Ensure that storage contract is the one expected
      (expect-active-storage-contract storage-contract expected-execution-plan)))

(define-read-only (get-current-execution-plan)
  (var-get current-execution-plan))

(define-read-only (get-fee-info)
  (merge (var-get fee-value) { address: (var-get fee-recipient-address) }))

(define-read-only (get-stale-price-threshold)
  (var-get stale-price-threshold))

(define-read-only (get-authorized-prices-data-sources)
  (var-get prices-data-sources))

(define-public (update-fee-value (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_UPDATE_FEE) ERR_UNEXPECTED_ACTION)
    ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update fee-value
    (let ((updated-data (try! (parse-and-verify-fee-value (get body ptgm)))))
      (var-set fee-value updated-data)
      (ok updated-data))))

(define-public (update-stale-price-threshold (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_STALE_PRICE_THRESHOLD) ERR_UNEXPECTED_ACTION)
    ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update fee-value
    (let ((updated-data (try! (parse-and-verify-stale-price-threshold (get body ptgm)))))
      (var-set stale-price-threshold updated-data)
      (ok updated-data))))

(define-public (update-fee-recipient-address (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_UPDATE_RECIPIENT_ADDRESS) ERR_UNEXPECTED_ACTION)
      ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update fee-recipient address
    (let ((updated-data (unwrap! (from-consensus-buff? principal (get body ptgm)) ERR_UNEXPECTED_ACTION_PAYLOAD)))
      (var-set fee-recipient-address updated-data)
      (ok updated-data))))

(define-public (update-wormhole-core-contract (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_UPDATE_WORMHOLE_CORE_ADDRESS) ERR_UNEXPECTED_ACTION)
    ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update execution plan
    (let ((updated-data (unwrap! (from-consensus-buff? principal (get body ptgm)) ERR_UNEXPECTED_ACTION_PAYLOAD)))
      (var-set current-execution-plan (merge expected-execution-plan { wormhole-core-contract: updated-data }))
      (ok (var-get current-execution-plan)))))

(define-public (update-pyth-oracle-contract (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_UPDATE_PYTH_ORACLE_ADDRESS) ERR_UNEXPECTED_ACTION)
    ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update execution plan
    (let ((updated-data (unwrap! (from-consensus-buff? principal (get body ptgm)) ERR_UNEXPECTED_ACTION_PAYLOAD)))
      (var-set current-execution-plan (merge expected-execution-plan { pyth-oracle-contract: updated-data }))
      (ok (var-get current-execution-plan)))))

(define-public (update-pyth-decoder-contract (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_UPDATE_PYTH_DECODER_ADDRESS) ERR_UNEXPECTED_ACTION)
    ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update execution plan
    (let ((updated-data (unwrap! (from-consensus-buff? principal (get body ptgm)) ERR_UNEXPECTED_ACTION_PAYLOAD)))
      (var-set current-execution-plan (merge expected-execution-plan { pyth-decoder-contract: updated-data }))
      (ok (var-get current-execution-plan)))))

(define-public (update-pyth-store-contract (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_UPDATE_PYTH_STORE_ADDRESS) ERR_UNEXPECTED_ACTION)
    ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update execution plan
    (let ((updated-data (unwrap! (from-consensus-buff? principal (get body ptgm)) ERR_UNEXPECTED_ACTION_PAYLOAD)))
      (var-set current-execution-plan (merge expected-execution-plan { pyth-storage-contract: updated-data }))
      (ok (var-get current-execution-plan)))))

(define-public (update-prices-data-sources (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_UPDATE_PRICES_DATA_SOURCES) ERR_UNEXPECTED_ACTION)
    ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update prices-data-sources
    (let ((updated-data (try! (parse-and-verify-prices-data-sources (get body ptgm)))))
      (var-set prices-data-sources updated-data)
      (ok updated-data))))

(define-public (update-governance-data-source (vaa-bytes (buff 8192)) (wormhole-core-contract <wormhole-core-trait>))
  (let ((expected-execution-plan (var-get current-execution-plan))
        (vaa (try! (contract-call? wormhole-core-contract parse-and-verify-vaa vaa-bytes)))
        (ptgm (try! (parse-and-verify-ptgm (get payload vaa) (get sequence vaa)))))
    ;; Ensure action's expectation
    (asserts! (is-eq (get action ptgm) PTGM_UPDATE_GOVERNANCE_DATA_SOURCE) ERR_UNEXPECTED_ACTION)
    ;; Ensure that the action is authorized
    (try! (check-update-source (get emitter-chain vaa) (get emitter-address vaa)))
    ;; Ensure that the lastest wormhole contract is used
    (try! (expect-active-wormhole-contract wormhole-core-contract expected-execution-plan))
    ;; Update prices-data-sources
    (let ((updated-data (try! (parse-and-verify-governance-data-source (get body ptgm)))))
      (var-set governance-data-source updated-data)
      (ok updated-data))))

(define-private (check-update-source (emitter-chain uint) (emitter-address (buff 32)))
  (let ((authorized-data-source (var-get governance-data-source)))
    ;; Check data-source
    (asserts! (is-eq 
        authorized-data-source 
        { emitter-chain: emitter-chain, emitter-address: emitter-address })
      ERR_UNAUTHORIZED_UPDATE)
    (ok true)))

(define-private (expect-contract-call-performed-by-expected-oracle-contract 
  (former-contract-caller principal) 
  (expected-plan { 
    pyth-oracle-contract: principal,
    pyth-decoder-contract: principal, 
    pyth-storage-contract: principal,
    wormhole-core-contract: principal
  }))
  (begin
    (asserts! 
      (is-eq former-contract-caller (get pyth-oracle-contract expected-plan))
      ERR_UNAUTHORIZED_ACCESS)
    (ok true)))

(define-private (expect-active-storage-contract 
  (storage-contract <pyth-storage-trait>)
  (expected-plan { 
    pyth-oracle-contract: principal,
    pyth-decoder-contract: principal, 
    pyth-storage-contract: principal,
    wormhole-core-contract: principal
  }))
  (begin
    (asserts! 
      (is-eq 
        (contract-of storage-contract) 
        (get pyth-storage-contract expected-plan)) 
      ERR_UNAUTHORIZED_ACCESS)
    (ok true)))

(define-private (expect-active-decoder-contract 
  (decoder-contract <pyth-decoder-trait>)
  (expected-plan { 
    pyth-oracle-contract: principal,
    pyth-decoder-contract: principal, 
    pyth-storage-contract: principal,
    wormhole-core-contract: principal
  }))
  (begin
    (asserts! 
      (is-eq 
        (contract-of decoder-contract) 
        (get pyth-decoder-contract expected-plan)) 
      ERR_UNAUTHORIZED_ACCESS)
    (ok true)))

(define-private (expect-active-wormhole-contract 
  (wormhole-contract <wormhole-core-trait>)
  (expected-plan { 
    pyth-oracle-contract: principal,
    pyth-decoder-contract: principal, 
    pyth-storage-contract: principal,
    wormhole-core-contract: principal
  }))
  (begin
    (asserts! 
      (is-eq 
        (contract-of wormhole-contract) 
        (get wormhole-core-contract expected-plan))
      ERR_UNAUTHORIZED_ACCESS)
    (ok true)))

(define-private (parse-and-verify-ptgm (ptgm-bytes (buff 8192)) (sequence uint))
  (let ((cursor-magic (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-4 { bytes: ptgm-bytes, pos: u0 }) 
          ERR_INVALID_PTGM))
        (cursor-module (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-1 (get next cursor-magic)) 
          ERR_INVALID_PTGM))
        (cursor-action (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-1 (get next cursor-module)) 
          ERR_INVALID_PTGM))
        (cursor-target-chain-id (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-2 (get next cursor-action)) 
          ERR_INVALID_PTGM))
        (cursor-body (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-8192-max (get next cursor-target-chain-id) none)
          ERR_INVALID_PTGM)))
    ;; Check magic bytes
    (asserts! (is-eq (get value cursor-magic) PTGM_MAGIC) ERR_INVALID_PTGM)
    ;; Check target-chain-id
    (asserts! (is-eq (get value cursor-target-chain-id) EXPECTED_CHAIN_ID) ERR_INVALID_PTGM)
    ;; Check module
    (asserts! (is-eq (get value cursor-module) EXPECTED_MODULE) ERR_INVALID_PTGM)
    ;; Check Sequence
    (asserts! (> sequence (var-get last-sequence-processed)) ERR_OUTDATED)
    ;; Update Sequence
    (var-set last-sequence-processed sequence)
    (ok { 
      action: (get value cursor-action), 
      target-chain-id: (get value cursor-target-chain-id), 
      module: (get value cursor-module),
      cursor: cursor-target-chain-id,
      body: (get value cursor-body)
    })))

(define-private (parse-and-verify-fee-value (ptgm-body (buff 8192)))
  (let ((cursor-ptgm-body (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 new ptgm-body none))
        (cursor-mantissa (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-64 (get next cursor-ptgm-body)) 
          ERR_INVALID_ACTION_PAYLOAD))
        (cursor-exponent (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-64 (get next cursor-mantissa)) 
          ERR_INVALID_ACTION_PAYLOAD)))
    (ok { 
      mantissa: (get value cursor-mantissa), 
      exponent: (get value cursor-exponent) 
    })))

(define-private (parse-and-verify-stale-price-threshold (ptgm-body (buff 8192)))
  (let ((cursor-ptgm-body (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 new ptgm-body none))
        (cursor-stale-price-threshold (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-64 (get next cursor-ptgm-body)) 
          ERR_INVALID_ACTION_PAYLOAD)))
    (ok (get value cursor-stale-price-threshold))))

(define-private (parse-and-verify-governance-data-source (ptgm-body (buff 8192)))
  (let ((cursor-ptgm-body (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 new ptgm-body none))
        (cursor-emitter-chain (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-16 (get next cursor-ptgm-body))
          ERR_INVALID_ACTION_PAYLOAD))
        (cursor-emitter-address (unwrap! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-32 (get next cursor-emitter-chain))
          ERR_INVALID_ACTION_PAYLOAD)))
    (ok { 
      emitter-chain: (get value cursor-emitter-chain), 
      emitter-address: (get value cursor-emitter-address) 
    })))


(define-private (parse-and-verify-prices-data-sources (pgtm-body (buff 8192)))
  (let ((cursor-pgtm-body (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 new pgtm-body none))
        (cursor-num-data-sources (try! (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-8 (get next cursor-pgtm-body))))
        (cursor-data-sources-bytes (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 slice (get next cursor-num-data-sources) none))
        (data-sources (get result (fold parse-data-source cursor-data-sources-bytes { 
          result: (list), 
          cursor: {
            index: u0,
            next-update-index: u0
          },
          bytes: cursor-data-sources-bytes,
          limit: (get value cursor-num-data-sources) 
        }))))
    (ok data-sources)))

(define-private (parse-data-source
      (entry (buff 1)) 
      (acc { 
        cursor: { 
          index: uint,
          next-update-index: uint
        },
        bytes: (buff 8192),
        result: (list 255 { emitter-chain: uint, emitter-address: (buff 32) }), 
        limit: uint
      }))
  (if (is-eq (len (get result acc)) (get limit acc))
    acc
    (if (is-eq (get index (get cursor acc)) (get next-update-index (get cursor acc)))
      ;; Parse update
      (let ((buffer (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 new (get bytes acc) (some (get index (get cursor acc)))))
            (cursor-emitter-chain (unwrap-panic (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-uint-16 (get next buffer))))
            (cursor-emitter-address (unwrap-panic (contract-call? 'SP2J933XB2CP2JQ1A4FGN8JA968BBG3NK3EKZ7Q9F.hk-cursor-v2 read-buff-32 (get next cursor-emitter-chain)))))
        ;; Perform assertions
        {
          cursor: { 
            index: (+ (get index (get cursor acc)) u1),
            next-update-index: (+ (get index (get cursor acc)) u34),
          },
          bytes: (get bytes acc),
          result: (unwrap-panic (as-max-len? (append (get result acc) { 
            emitter-chain: (get value cursor-emitter-chain), 
            emitter-address: (get value cursor-emitter-address) 
          }) u255)),
          limit: (get limit acc),
        })
      ;; Increment position
      {
          cursor: { 
            index: (+ (get index (get cursor acc)) u1),
            next-update-index: (get next-update-index (get cursor acc)),
          },
          bytes: (get bytes acc),
          result: (get result acc),
          limit: (get limit acc)
      })))
