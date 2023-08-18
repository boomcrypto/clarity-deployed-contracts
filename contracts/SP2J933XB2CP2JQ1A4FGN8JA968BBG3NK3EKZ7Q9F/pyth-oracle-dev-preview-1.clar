;; Title: pyth-oracle
;; Version: Developer Preview 1
;; Check for latest version: https://github.com/hirosystems/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/hirosystems/stacks-pyth-bridge/issues

;;;; Traits

;;;; Constants

;; Price Feeds Ids (https://pyth.network/developers/price-feed-ids#pyth-evm-mainnet)
(define-constant STX_USD 0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17)
(define-constant BTC_USD 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43)
(define-constant ETH_USD 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace)

;; Generic error
(define-constant ERR_PANIC (err u0))
;; Unable to price feed magic bytes
(define-constant ERR_PF_PARSING_MAGIC_BYTES (err u2001))
;; Unable to parse major version
(define-constant ERR_PF_PARSING_VERSION_MAJ (err u2002))
;; Unable to parse minor version
(define-constant ERR_PF_PARSING_VERSION_MIN (err u2003))
;; Unable to parse trailing header size
(define-constant ERR_PF_PARSING_TRAILING_HEADER_SIZE (err u2004))
;; Unable to parse update type
(define-constant ERR_PF_PARSING_UPDATE_TYPE (err u2005))
;; Unable to parse payload ID (P2WH, PNAU, ...)
(define-constant ERR_PF_PARSING_PAYLOAD_ID (err u2006))
;; Unable to parse price attestation count
(define-constant ERR_P2WH_PARSING_ATTESTATION_COUNT (err u2007))
;; Unable to parse price attestation size
(define-constant ERR_P2WH_PARSING_ATTESTATION_SIZE (err u2008))
;; Unable to slice price attestation blobs
(define-constant ERR_P2WH_SLICING_ATTESTATION_BYTES (err u2009))
;; Unable to retrieve price feed
(define-constant ERR_PF_NOT_FOUND (err u2010))

;;;; Data vars
;;

;;;; Data maps
;;
(define-map prices
  { price-feed-id: (buff 32) } 
  {
    price: int,
    conf: uint,
    expo: int,
    attestation-time: uint,
    ema-price: int,
    ema-conf: uint,
    status: uint,
    publish-time: uint,
    prev-publish-time: uint,
    prev-price: int,
    prev-conf: uint,
  })

(define-data-var watched-price-feeds 
  (list 1024 (buff 32)) 
  (list STX_USD BTC_USD ETH_USD))

;;;; Public functions
;;
(define-public (update-prices-feeds (vaas (list 4 (buff 2048))))
  (let ((decoded-vaas (map parse-and-verify-vaa vaas))
        (decoded-prices-attestations-batches (map parse-and-verify-price-attestations decoded-vaas))
        (watched-prices-feeds (var-get watched-price-feeds))
        (updated-prices-feeds (get updated-prices-feeds (fold process-prices-attestations-batch decoded-prices-attestations-batches { input: watched-prices-feeds, updated-prices-feeds: (list) }))))
    (ok updated-prices-feeds)))

;;;; Read only functions
;;

(define-read-only (read-price-feed (price-feed-id (buff 32)))
  (let ((price-feed-entry (unwrap! (map-get? prices { price-feed-id: price-feed-id }) ERR_PF_NOT_FOUND)))
    (ok price-feed-entry)))
    
(define-read-only (parse-and-verify-price-attestations (pf-bytes (buff 2048)))
  (let ((cursor-price-attestations-header (try! (parse-price-attestations-header pf-bytes)))
        (cursor-attestations-count (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-price-attestations-header)) 
            ERR_P2WH_PARSING_ATTESTATION_COUNT))
        (cursor-attestation-size (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-attestations-count)) 
            ERR_P2WH_PARSING_ATTESTATION_SIZE))
        (attestations-bytes (unwrap! (slice? pf-bytes (get pos (get next cursor-attestation-size)) (+ (get pos (get next cursor-attestation-size)) (* (get value cursor-attestations-count) (get value cursor-attestation-size))))
            ERR_P2WH_SLICING_ATTESTATION_BYTES))
        (attestations-cues (get result (fold is-price-attestation-cue attestations-bytes { size: (get value cursor-attestation-size), cursor: u0, result: (unwrap-panic (as-max-len? (list u0) u64)) })))
        (encoded-price-attestations (get result (fold parse-price-attestation attestations-cues { attestations-bytes: attestations-bytes, result: (unwrap-panic (as-max-len? (list {
          price-feed-id: (unwrap-panic (as-max-len? 0x u32)),
          price: (unwrap-panic (as-max-len? 0x u8)),
          conf: (unwrap-panic (as-max-len? 0x u8)),
          expo: (unwrap-panic (as-max-len? 0x u4)),
          ema-price: (unwrap-panic (as-max-len? 0x u8)),
          ema-conf: (unwrap-panic (as-max-len? 0x u8)),
          status: (unwrap-panic (as-max-len? 0x u1)),
          attestation-time: (unwrap-panic (as-max-len? 0x u8)),
          publish-time: (unwrap-panic (as-max-len? 0x u8)),
          prev-publish-time: (unwrap-panic (as-max-len? 0x u8)),
          prev-price: (unwrap-panic (as-max-len? 0x u8)),
          prev-conf: (unwrap-panic (as-max-len? 0x u8)),
        }) u64)) })))
        (price-attestations (map decode-price-attestation (unwrap-panic (slice? encoded-price-attestations u1 (+ u1 (get value cursor-attestations-count)))))))
    (ok {
      attestations-count: (get value cursor-attestations-count),
      attestation-size: (get value cursor-attestation-size),
      price-attestations: price-attestations
    })))

(define-read-only (parse-price-attestations-header (pf-bytes (buff 2048)))
  (let ((cursor-magic (unwrap! (contract-call? .hk-cursor-v1 read-buff-4 { bytes: pf-bytes, pos: u0 }) 
          ERR_PF_PARSING_MAGIC_BYTES))
        ;; Todo: check magic bytes
        (cursor-version-maj (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-magic)) 
          ERR_PF_PARSING_VERSION_MAJ))
        ;; Todo: check major version
        (cursor-version-min (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-version-maj)) 
          ERR_PF_PARSING_VERSION_MIN))
        ;; Todo: check minor version
        (cursor-header-size (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-version-min)) 
          ERR_PF_PARSING_TRAILING_HEADER_SIZE))
        ;; Todo: check minor version
        (cursor-payload-id (unwrap! (contract-call? .hk-cursor-v1 read-u8 (get next cursor-header-size)) 
          ERR_PF_PARSING_PAYLOAD_ID)))
    (ok {
      value: {
        magic: (get value cursor-magic),
        version-maj: (get value cursor-version-maj),
        version-min: (get value cursor-version-min),
        header-size: (get value cursor-header-size),
        payload-id: (get value cursor-payload-id)
      },
      next: { 
        bytes: pf-bytes, 
        pos: (+ (get pos (get next cursor-payload-id)) 
                (- (get value cursor-header-size) u1)) 
      }
    })))

;;;; Private functions
;;
(define-private (parse-and-verify-vaa (vaa-bytes (buff 2048)))
  (let ((vaa (unwrap-panic (contract-call? .wormhole-core-dev-preview-1 parse-and-verify-vaa vaa-bytes)))) ;; try!
    (get payload vaa)))

(define-private (parse-price-feed-header (pf-bytes (buff 2048)))
  (let ((cursor-magic (unwrap! (contract-call? .hk-cursor-v1 read-buff-4 { bytes: pf-bytes, pos: u0 }) 
          ERR_PF_PARSING_MAGIC_BYTES))
        ;; Todo: check magic bytes
        (cursor-version-maj (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-magic)) 
          ERR_PF_PARSING_VERSION_MAJ))
        ;; Todo: check major version
        (cursor-version-min (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-version-maj)) 
          ERR_PF_PARSING_VERSION_MIN))
        ;; Todo: check minor version
        (cursor-trailing-header-size (unwrap! (contract-call? .hk-cursor-v1 read-u16 (get next cursor-version-min)) 
          ERR_PF_PARSING_TRAILING_HEADER_SIZE))
        ;; We use another offset for the trailing header and in the end add the
        ;; offset by trailingHeaderSize to skip the future headers.
        (cursor-udpate-type (unwrap! (contract-call? .hk-cursor-v1 read-u16 { bytes: pf-bytes, pos: (+ (get pos (get next cursor-trailing-header-size)) 
                                                                                                      (get value cursor-trailing-header-size)) })
          ERR_PF_PARSING_UPDATE_TYPE)))
    (ok {
      value: {
        magic: (get value cursor-magic),
        version-maj: (get value cursor-version-maj),
        version-min: (get value cursor-version-min),
        trailing-header-size: (get value cursor-trailing-header-size),
      },
      next: (get next cursor-udpate-type)
    })))

(define-private (is-price-attestation-cue 
      (entry (buff 1)) 
      (acc { cursor: uint, result: (list 64 uint), size: uint }))
  (if (and 
      (is-eq u0 (mod (get cursor acc) (get size acc))) 
      (> (get cursor acc) u0) )
    { 
      cursor: (+ u1 (get cursor acc)), 
      result: (unwrap-panic (as-max-len? (append (get result acc) (get cursor acc)) u64)),
      size: (get size acc) 
    }
    {
      cursor: (+ u1 (get cursor acc)), 
      result: (get result acc),
      size: (get size acc) 
    }))

(define-private (parse-price-attestation 
      (entry uint) 
      (acc { 
        attestations-bytes: (buff 2048), 
        result: (list 64 {
          price-feed-id: (buff 32),
          price: (buff 8),
          conf: (buff 8),
          expo: (buff 4),
          ema-price: (buff 8),
          ema-conf: (buff 8),
          status: (buff 1),
          attestation-time: (buff 8),
          publish-time: (buff 8),
          prev-publish-time: (buff 8),
          prev-price: (buff 8),
          prev-conf: (buff 8),
      })}))
  (let ((cursor-obsolete-1 (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-32 { bytes: (get attestations-bytes acc), pos: entry })))
        (cursor-price-feed-id (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-32 (get next cursor-obsolete-1))))
        (cursor-price (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-price-feed-id))))
        (cursor-conf (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-price))))
        (cursor-expo (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-4 (get next cursor-conf))))
        (cursor-ema-price (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-expo))))
        (cursor-ema-conf (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-ema-price))))
        (cursor-status (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-1 (get next cursor-ema-conf))))
        (cursor-obsolete-2 (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-4 (get next cursor-status))))
        (cursor-obsolete-3 (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-4 (get next cursor-obsolete-2))))
        (cursor-attestation-time (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-obsolete-3))))
        (cursor-publish-time (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-attestation-time))))
        (cursor-prev-publish-time (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-publish-time))))
        (cursor-prev-price (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-prev-publish-time))))
        (cursor-prev-conf (unwrap-panic (contract-call? .hk-cursor-v1 read-buff-8 (get next cursor-prev-price))))
  )
    {
      attestations-bytes: (get attestations-bytes acc),
      result: (unwrap-panic (as-max-len? (append (get result acc) {
        price-feed-id: (get value cursor-price-feed-id),
        price: (get value cursor-price),
        conf: (get value cursor-conf),
        expo: (get value cursor-expo),
        ema-price: (get value cursor-ema-price),
        ema-conf: (get value cursor-ema-conf),
        status: (get value cursor-status),
        attestation-time: (get value cursor-attestation-time),
        publish-time: (get value cursor-publish-time),
        prev-publish-time: (get value cursor-prev-publish-time),
        prev-price: (get value cursor-prev-price),
        prev-conf: (get value cursor-prev-conf),
      }) u64))
    }))

(define-private (decode-price-attestation 
      (entry {
        price-feed-id: (buff 32),
        price: (buff 8),
        conf: (buff 8),
        expo: (buff 4),
        ema-price: (buff 8),
        ema-conf: (buff 8),
        status: (buff 1),
        attestation-time: (buff 8),
        publish-time: (buff 8),
        prev-publish-time: (buff 8),
        prev-price: (buff 8),
        prev-conf: (buff 8)
      }))
  {
    price-feed-id: (get price-feed-id entry),
    price: (buff-to-int-be (get price entry)),
    conf: (buff-to-uint-be (get conf entry)),
    expo: (buff-to-int-be (get expo entry)),
    ema-price: (buff-to-int-be (get ema-price entry)),
    ema-conf: (buff-to-uint-be (get ema-conf entry)),
    status: (buff-to-uint-be (get status entry)),
    attestation-time: (buff-to-uint-be (get attestation-time entry)),
    publish-time: (buff-to-uint-be (get publish-time entry)),
    prev-publish-time: (buff-to-uint-be (get prev-publish-time entry)),
    prev-price: (buff-to-int-be (get prev-price entry)),
    prev-conf: (buff-to-uint-be (get prev-conf entry)),
  })

(define-private (process-prices-attestations-batch 
      (entry (response 
        { 
          attestation-size: uint, 
          attestations-count: uint, 
          price-attestations: (list 254 {
            price-feed-id: (buff 32),
            price: int,
            conf: uint,
            expo: int,
            ema-price: int,
            ema-conf: uint,
            status: uint,
            attestation-time: uint,
            publish-time: uint,
            prev-publish-time: uint,
            prev-price: int,
            prev-conf: uint,
          })
        } 
        uint)) 
      (acc { 
        input: (list 2048 (buff 32)), 
        updated-prices-feeds: (list 2048 (buff 32)) 
      }))
  (let ((batch (unwrap-panic entry))
        (updated-prices-feeds (get updated-prices-feeds (fold process-price-attestation (get price-attestations batch) acc))))
    {
      input: (get input acc),
      updated-prices-feeds: updated-prices-feeds
    }))

(define-private (process-price-attestation 
      (entry {
        price-feed-id: (buff 32),
        price: int,
        conf: uint,
        expo: int,
        ema-price: int,
        ema-conf: uint,
        status: uint,
        attestation-time: uint,
        publish-time: uint,
        prev-publish-time: uint,
        prev-price: int,
        prev-conf: uint,
        }) 
      (acc { input: (list 2048 (buff 32)), updated-prices-feeds: (list 2048 (buff 32)) }))
  (match (index-of? (get input acc) (get price-feed-id entry)) 
    index (begin 
      ;; Update Price Feed
      (map-set prices 
        { 
          price-feed-id: (get price-feed-id entry), 
        }
        {
          price: (get price entry), 
          conf: (get conf entry), 
          expo: (get expo entry), 
          ema-price: (get ema-price entry), 
          ema-conf: (get ema-conf entry), 
          status: (get status entry), 
          attestation-time: (get attestation-time entry), 
          publish-time: (get publish-time entry), 
          prev-publish-time: (get prev-publish-time entry), 
          prev-price: (get prev-price entry), 
          prev-conf: (get prev-conf entry), 
        })
      ;; TODO: check timestamps
      ;; Emit event
      (print { type: "price-feed", action: "updated", data: entry })
      {
        input: (get input acc),
        updated-prices-feeds: (unwrap-panic (as-max-len? (append (get updated-prices-feeds acc) (get price-feed-id entry)) u2048))
      })
    acc))

(define-private (parse-and-verify-price-feed (pf-bytes (buff 2048)))
  (let ((cursor-price-feed-header (try! (parse-price-feed-header pf-bytes)))
  ;; Todo: check minor version
        (cursor-trailing-header-size (unwrap! (contract-call? .hk-cursor-v1 read-u8 (get next cursor-price-feed-header)) 
          ERR_PF_PARSING_TRAILING_HEADER_SIZE))
        (cursor-udpate-type (unwrap! (contract-call? .hk-cursor-v1 read-u8 (get next cursor-trailing-header-size)) 
          ERR_PF_PARSING_VERSION_MIN)))
  ;;   (cursor-guardian-set (unwrap! (contract-call? .hk-cursor-v1 read-u32 (get next cursor-version)) 
  ;;     ERR_PARSING_VAA_GUARDIAN_SET))
  ;;   (cursor-signatures (fold 
  ;;     batch-read-signatures
  ;;     (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0)
  ;;     { 
  ;;         next: (get next cursor-signatures-len), 
  ;;         value: (list),
  ;;         iter: (get value cursor-signatures-len)
  ;;     }))
    (ok {
      price-feed-header: (get value cursor-price-feed-header),
      udpate-type: (get value cursor-udpate-type),
    })))
