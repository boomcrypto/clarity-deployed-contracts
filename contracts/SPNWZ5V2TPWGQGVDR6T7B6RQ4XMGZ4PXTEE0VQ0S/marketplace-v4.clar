(use-trait tradables-trait .tradable-trait.tradables-trait)

(define-data-var minimum-commission uint u100) ;; minimum commission 1% by default
(define-data-var minimum-listing-price uint u1000000) ;; minimum listing price 1 STX

(define-data-var listings-frozen bool false) ;; turn off the ability to list additional NFTs
(define-data-var purchases-frozen bool false) ;; turn off the ability to purchase NFTs
(define-data-var unlistings-frozen bool false) ;; turn off the ability to unlist NFTs

(define-map on-sale
  {tradables: principal, tradable-id: uint}
  {price: uint, commission: uint, owner: principal, royalty-address: principal, royalty-percent: uint}
)

(define-map verified-contracts
  {tradables: principal}
  {royalty-address: principal, royalty-percent: uint}
)

(define-constant contract-owner tx-sender)
(define-constant err-payment-failed u1)
(define-constant err-transfer-failed u2)
(define-constant err-not-allowed u3)
(define-constant err-duplicate-entry u4)
(define-constant err-tradable-not-found u5)
(define-constant err-commission-or-price-too-low u6)
(define-constant err-listings-frozen u7)
(define-constant err-commission-payment-failed u8)
(define-constant err-royalty-payment-failed u9)
(define-constant err-contract-not-authorized u10)

(define-read-only (get-listing (tradables <tradables-trait>) (tradable-id uint))
  (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
    nft-data 
    (ok nft-data)
    (err err-tradable-not-found)
  )
)

(define-read-only (get-royalty-amount (contract principal))
  (match (map-get? verified-contracts {tradables: contract})
    royalty-data
    (get royalty-percent royalty-data)
    u0)
)

(define-private (get-royalty (contract principal))
  (match (map-get? verified-contracts {tradables: contract})
    royalty-data
    royalty-data
    {royalty-address: contract-owner, royalty-percent: u0})
)
 
(define-private (get-owner (tradables <tradables-trait>) (tradable-id uint))
  (contract-call? tradables get-owner tradable-id)
)

(define-private (transfer-tradable-to-escrow (tradables <tradables-trait>) (tradable-id uint))
  (begin
    (contract-call? tradables transfer tradable-id tx-sender (as-contract tx-sender))
  )
)

(define-private (transfer-tradable-from-escrow (tradables <tradables-trait>) (tradable-id uint))
  (let ((owner tx-sender))
    (begin
      (as-contract (contract-call? tradables transfer tradable-id (as-contract tx-sender) owner))
    )
  )
)

(define-private (return-tradable-from-escrow (tradables <tradables-trait>) (tradable-id uint))
  (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
    nft-data
    (let ((owner tx-sender))
      (begin
        (as-contract (contract-call? tradables transfer tradable-id (as-contract tx-sender) (get owner nft-data)))
      )
    )
    (err err-tradable-not-found)
  )
)

(define-public (list-asset (tradables <tradables-trait>) (tradable-id uint) (price uint) (commission uint))
  (begin
    (asserts! (is-eq false (var-get listings-frozen)) (err err-listings-frozen))
    (match (map-get? verified-contracts { tradables: (contract-of tradables) })
      contract-name
      (let ((tradable-owner (unwrap! (unwrap-panic (get-owner tradables tradable-id)) (err err-tradable-not-found)))
           (royalty (get-royalty (contract-of tradables))))
       (if (and (>= commission (var-get minimum-commission)) (>= price (var-get minimum-listing-price)))
        (if (is-eq tradable-owner tx-sender)
         (if (map-insert on-sale {tradables: (contract-of tradables), tradable-id: tradable-id}
              {price: price, commission: commission, owner: tradable-owner, royalty-address: (get royalty-address royalty), royalty-percent: (get royalty-percent royalty)})
          (begin
           (match (transfer-tradable-to-escrow tradables tradable-id)
            success (begin
                (ok true))
            error (begin (print error) (err err-transfer-failed))))
          (err err-duplicate-entry)
         )
         (err err-not-allowed)
        )
        (err err-commission-or-price-too-low)
       )
      )
      (err err-contract-not-authorized)
    )
  )
)

(define-public (unlist-asset (tradables <tradables-trait>) (tradable-id uint))
  (begin
    (asserts! (is-eq false (var-get unlistings-frozen)) (err err-listings-frozen))
    (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
      nft-data 
      (if (is-eq (get owner nft-data) tx-sender)
          (match (transfer-tradable-from-escrow tradables tradable-id)
             success (begin
                       (map-delete on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
                       (ok true))
             error (begin (print error) (err err-transfer-failed)))
          (err err-not-allowed)
      )
      (err err-tradable-not-found)
    )
  )
)

;; tx sender has to send the required amount
;; tx sender receives NFT
;; owner gets paid out the amount minus commission
;; stxnft address gets paid out commission
(define-public (purchase-asset (tradables <tradables-trait>) (tradable-id uint))
  (begin
    (asserts! (is-eq false (var-get purchases-frozen)) (err err-listings-frozen))
    (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
      nft-data 
      (let ((price (get price nft-data)) 
            (commission-amount (/ (* price (get commission nft-data)) u10000)) 
            (royalty-amount (/ (* price (get royalty-percent nft-data)) u10000)) 
            (to-owner-amount (- (- price commission-amount) royalty-amount))) 
        ;; first send the amount to the owner
        (match (stx-transfer? to-owner-amount tx-sender (get owner nft-data))
          owner-success ;; sending money to owner succeeded
          (match (stx-transfer? commission-amount tx-sender contract-owner)
            commission-success ;; sending commission to contract owner succeeded
              (if (> royalty-amount u0)
                (match (stx-transfer? royalty-amount tx-sender (get royalty-address nft-data))
                  royalty-success ;; sending royalty to artist succeeded
                  (match (transfer-tradable-from-escrow tradables tradable-id)
                    transfer-success (begin 
                      (map-delete on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
                      (ok true) ;; sending NFT to buyer succeeded
                    )
                    error (err err-transfer-failed)
                  )
                  error (err err-royalty-payment-failed)
                )
                (match (transfer-tradable-from-escrow tradables tradable-id)
                  transfer-success (begin 
                    (map-delete on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
                    (ok true) ;; sending NFT to buyer succeeded
                  )
                  error (err err-transfer-failed)
                )
             )
            error (err err-commission-payment-failed)
          )
          error (err err-payment-failed)
        )
      )
      (err err-tradable-not-found)
    )
  )
)

(define-public (admin-unlist-asset (tradables <tradables-trait>) (tradable-id uint))
  (match (map-get? on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
    nft-data 
    (if (is-eq contract-owner tx-sender)
        (match (return-tradable-from-escrow tradables tradable-id)
           success (begin
                     (map-delete on-sale {tradables: (contract-of tradables), tradable-id: tradable-id})
                     (ok true))
           error (begin (print error) (err err-transfer-failed)))
        (err err-not-allowed)
    )
    (err err-tradable-not-found)
  )
)

(define-public (set-minimum-commission (commission uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set minimum-commission commission))
  )
)

(define-public (add-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-set verified-contracts {tradables: contract} {royalty-address: contract-owner, royalty-percent: u0}))
  )
)

(define-public (remove-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-delete verified-contracts {tradables: contract}))
  )
)

(define-public (set-royalty (contract principal) (address principal) (percent uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (map-set verified-contracts {tradables: contract} {royalty-address: address, royalty-percent: percent}))
  )
)

(define-public (set-minimum-listing-price (price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set minimum-listing-price price))
  )
)

(define-public (set-listings-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set listings-frozen frozen))
  )
)

(define-public (set-unlistings-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set unlistings-frozen frozen))
  )
)

(define-public (set-purchases-frozen (frozen bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err err-not-allowed))
    (ok (var-set purchases-frozen frozen))
  )
)

;; all projects on marketplace v3
(try! (add-contract 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.free-punks-v0))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.funky-donuts))
(try! (add-contract 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.future-of-money))
(try! (add-contract 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-18))
(try! (add-contract 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3))
(try! (add-contract 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft))
(try! (add-contract 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.bitcoin-pizza))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-satoshi-knights))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-homagic))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blocks))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.testing-liquidity))
(try! (add-contract 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-kittens))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.pox-monks))
(try! (add-contract 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.miami-degens))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-genesis))
(try! (add-contract 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.miami-vice))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-dragons))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.satoshis-team))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-matryoshka-dolls))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-tulips))
(try! (add-contract 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.tiles))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.anime-girls))
(try! (add-contract 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.bulls))
(try! (add-contract 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.thisisnumberone-v2))
(try! (add-contract 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.zebras))
(try! (add-contract 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-1))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-animal-stacks))
(try! (add-contract 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.fruits))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.deruptars))
(try! (add-contract 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.stacks-army))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-blurred-museum))
(try! (add-contract 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.anime-boys))
(try! (add-contract 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boomboxes-cycle-12))
(try! (add-contract 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boomboxes-cycle-14))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-sadoughshis-bitcoin-pizza))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-snowball-rabbits))
(try! (add-contract 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.dreamcatchers))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.phases-of-satoshi))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-vampire-slayers))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.roads))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-fruitmen))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.hexstx))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots-v1))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.crypto-graffiti))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-cyborg))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.cybernetic-souls))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.byte-fighters))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-of-satoshi))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.metaraffes))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-vague-art-paintings))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-satoshi-2))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-english-hat-club))
(try! (add-contract 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.ruma-v1))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots))
(try! (add-contract 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-shroomies))
(try! (add-contract 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.rangoli))
(try! (add-contract 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-2))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.zombie-wabbits))
(try! (add-contract 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.stacks-roots))
(try! (add-contract 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boomboxes-cycle-16))
(try! (add-contract 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blue-ridge-biker))
(try! (add-contract 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts))

;; stxnft-launched projects
(try! (set-royalty 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV.Candy 'SPQZF23W7SEYBFG5JQ496NMY0G7379SRYEDREMSV u500))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.metaraffes 'SPP930EBFW6DVDRZ2Y84660J2R28T0HBB8S1ST5C u250))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.fruits 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25 u250))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.rangoli 'SP1W1KE3GGR07YB576P8KMA83TTKWPV8K9DJX01H1 u250))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.anime-girls 'SP2CC8YR1SV8VT1H3RBZJFBD2V8HA36S9C7JZKP2B u250))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.cybernetic-souls 'SPVVB6WRVE757VKEB2T0X5ZY4DMFJAX248XXQHHW u250))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.stacculents 'SP2FGW8E8455NA55FGC42MNA6XDPWJYQFGSXYWV2F u500))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.stacks-army 'SP3QYTYDMFBMBE398NB0770HJM65TAHRE86PD1KSS u250))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-angels 'SP21XYG67H6T2W91J0EXG4THR7S1G49S4RN9QDJXM u250))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.bitcoin-pizza 'SP3DADFZ5M352BV2XZY1RSPV307QH0JPKKEQMFAP3 u200))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-satoshi-2 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 u1000))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.straw-collection 'SP18BFREGEWVGNRG40MFA9Z9N3H2QQH0Q7TMC085Q u250))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.saints 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX u250))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.future-of-money 'SP3TYAQVV9378DDA1HF118CH6521NRCY7YBCWAX6G u500))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.zebras 'SP8Q0MG7K00RBZ6NPGA8J1EVMT093QDJNE8W9QNP u250))
(try! (set-royalty 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.dreamcatchers 'SP1W1KE3GGR07YB576P8KMA83TTKWPV8K9DJX01H1 u250))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.bulls 'SPEGDNNSRF6NPBF2YS6X6C8ZCC6FZQARN494NQP3 u1000))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.roads 'SP3S5Z0VT3KT4YG10MPPY9PJY33YAFPRYVVBC0W9G u250))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.owls 'SP3QZ7WMFGJ9HASJKG64SREM1YYT7BYF3YD2SCTPS u250))
(try! (set-royalty 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.anime-boys 'SP1M6T0C8EQTQM60RGS9WJFJGYFGFZJ2KC0W3ZWC4 u250))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.miami-vice 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 u1000))
(try! (set-royalty 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-1 'SP1B6FGZWBJK2WJHJP76C2E4AW3HA4BVAR5DGK074 u1000))
(try! (set-royalty 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.picasso-magic-2 'SP1B6FGZWBJK2WJHJP76C2E4AW3HA4BVAR5DGK074 u1000))
(try! (set-royalty 'SP2Z2BST4Z2RFSDTF7GJ4D07VXCFRBRTR1JPCCE7J.spooky-staccs 'SP2FGW8E8455NA55FGC42MNA6XDPWJYQFGSXYWV2F u900))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.ueberkatzen 'SP21R1S8QBZKW9VGKHEECVN6AJKDC8PCS50X34BXN u250))
(try! (set-royalty 'SP207ESW7AKHTPRYAAD9QP8Q1TE1F57D2S8RGPJCC.cyber-stx 'SPVVB6WRVE757VKEB2T0X5ZY4DMFJAX248XXQHHW u250))
(try! (set-royalty 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties 'SPPB55WCQ53904NCG71XF8YNG8D86JAJJEF6B1BV u750))
(try! (set-royalty 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.stacks-roots 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY u250))
(try! (set-royalty 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.tiles 'SP8890TMA8MV7BS7REBX65JZ74HVPZ2ZWK0MR51D u100))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.mother-of-satoshi 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 u1000))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.spacewhales 'SP19H1D5DV317DR2196ADZNN4P83H9KP5GA1PPEW5 u250))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.satoshis-team 'SP3BJSVA9E8MJAKK3ZNAGZKG91KY82G6299DY1YBW u400))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.hexstx 'SP2H4C1ACECDQ9R78AARQM3KGRMBRSGA4GJ455GWD u100))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.testing-liquidity 'SP3EYC57DC1K6NNNCPKSFJWHYG8F5MRX3X1Q1AJJ u100))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots-v1 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C u250))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.pox-monks 'SP11HD7QYN65VPZVRS1MM710ZHMKSFZDHVP1XZHW6 u250))
(try! (set-royalty 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.crypto-graffiti 'SP1B6FGZWBJK2WJHJP76C2E4AW3HA4BVAR5DGK074 u1000))

;; stacksart-launched
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.phases-of-satoshi 'SPBFZ5MRGDMEKWNQTJ57W2PA2GC0765ZFC5BY0KP u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blue-ridge-biker 'SPTQQE9SEV82CZ3DWCV5AY8ZSX3HK3GK7FTAZNV8 u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops 'SP1WGVYWSZJM1EKH1TYB2BH3W4ZPEJBMW1N2B9FG0 u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds 'SP2K9XEKEG7BE5BTYWZDAXJ8QAZBJ2TQZJJY3MV90 u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.belles-witches 'SP2S7AE08KCDQQ7S7JF4W6FH0GZ9920ENC3ET9ATP u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.byte-fighters 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570 u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.blocks 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-youth 'SP2V5BGR60147M8NGV0NV71Q6FDNFMC4E5S78224X u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stx-jokers 'SP2C1BVR38WHJK1RDACXDD6A4SSP10X01SVNC8EBX u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.virtual-tulips 'SP2EMYH0XQWJ1GZ036JCS9CA9S97KCN6W8A6RDSFB u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.funky-donuts 'SP3HCNR789SGMN18Y4SYBXBP38NB1BPRFVA9P010M u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.zombie-wabbits 'SP10W359VJZG7JWEXKVQH1ESFSGCTCST83VVWAC0S u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-mandala 'SP2C1BVR38WHJK1RDACXDD6A4SSP10X01SVNC8EBX u500))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.citadels 'SP3M7YP0F9V0F57VPCHJ0EF5CYNA3BT5R7K761KT1 u500))

;; byzantion-launched
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-snowball-rabbits 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-storm 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX u250))
(try! (set-royalty 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-ape-club-nft 'SP39E0V32MC31C5XMZEN1TQ3B0PW2RQSJB8TKQEV9 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-nakamoto-guardians 'SP35FG6SHERAY92DN14BBE42BFNFBVEHTN9DCG7EE u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcutties 'SP3PJBFHVSKYP33ZAEKQW8GQXWJYZ53S7AT0KYD4W u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-pixel-world-v1 'SP27BDVSXB2GY8RS13JJFQ9ZJ0YA8AQV9SBQY86MZ u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-vampire-slayers 'SP1W1KE3GGR07YB576P8KMA83TTKWPV8K9DJX01H1 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-cyborg 'SP2TKGQ8V47CKXN3P2AZBT0K93FMD69KJTPW4B54K u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-vague-art-paintings 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-homagic 'SP14YEEA2S46F5EE11G6Z7PJFDW5JAZFG86BACFXB u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-sadoughshis-bitcoin-pizza 'SP16H55N12MTAQMVWVN8WSBVQTSKMV7WRNVANA1CN u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-fruitmen 'SPA6FR2P1TJ9C5KDSXDXY30HHRXSFKNKCDWWCDN6 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-shroomies 'SP1AGWGJQZSZBJ5YA8KKPSXZ8M8RMGQB859WP3ACK u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-satoshi-knights 'SPMFK2FBQC79WS2087HT8SD2TTD54YEHFGWCYK5J u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-kittens 'SP23TJ0675AWVKPZQKMEQ37S0WQEKQZTCFTY6Q1BS u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-the-himalayan-trinity 'SP1HYPJ0P6VQ02AAFZFSME4KCYGWM590A82Z4YK1P u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-blurred-museum 'SP2BXYAER68S4ZJWA6VTY2E9CNXD6B0GJGMPPZ5Z1 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcoin-tulips 'SP21JJ0KVPTGAA1PD8RG1QR0ZSCFX39Q86T5NNFCY u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-foxes-community 'SP1W1KE3GGR07YB576P8KMA83TTKWPV8K9DJX01H1 u250))
(try! (set-royalty 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.bitcoin-birds 'SP2K9XEKEG7BE5BTYWZDAXJ8QAZBJ2TQZJJY3MV90 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-animal-stacks 'SP3H8JBZH62417NRMMFTKVN7HTE6R93R906VNDJA6 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-stacks-dragons 'SPCRS5E657H7FBXNHNM24GKJDDEN69MB303DFAX1 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-english-hat-club 'SP16H55N12MTAQMVWVN8WSBVQTSKMV7WRNVANA1CN u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-matryoshka-dolls 'SP1W1KE3GGR07YB576P8KMA83TTKWPV8K9DJX01H1 u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-genesis 'SP1J26MGNB0TEH4J6G2TVR5TKABDEWHW88SRE5QVQ u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.deruptars 'SP2BZ2YP68CABE7D32HE6308P6C7GMYN2ECJM8A7P u250))
(try! (set-royalty 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.mandelbrots-v1 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C u250))

