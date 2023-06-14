;;Contract that enables the subscription of nfts in collection SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.the-cavalry to gain spoints.
(impl-trait .subscriber-trait.subscriber-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)
;;consts
(define-constant ERR-NOT-AUTHORIZED u404)
(define-constant ERR-INSUFFICIENT-BALANCE u401)
(define-constant collection-address 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.the-cavalry)
;;maps
(define-map subscription-per-address { address: principal } {  time: uint, points-balance: uint, total-multiplier: uint , lifetime-earnings: uint})
(define-map subscribed-nfts-per-address { address: principal} { ids: (list 2500 uint) })
(define-map items-subscribers {item: uint} { address: principal })
(define-data-var admin principal tx-sender)
;;vars
(define-data-var subscribed-items uint u0)
(define-data-var multipliers principal 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.the-cavalry-multipliers)
(define-data-var removing-item-id uint u0)
(define-data-var blocks-per-spoint uint u72)
(define-data-var shutoff-valve bool false)
;;checks the subscription data of an address
(define-read-only (get-subscription-per-address (address principal))
    (default-to 
      {time: u0, points-balance: u0, total-multiplier: u0 , lifetime-earnings: u0} 
      (map-get? subscription-per-address { address: address })))
;;Given an nft, returns the address that last subscribed it
(define-read-only (get-item-subscriber (item uint))
  (ok (get address (map-get? items-subscribers { item: item}))))
;;returns the base number of spoints allocated to an address per block
(define-read-only (get-blocks-per-spoint)
    (default-to u0 (some (var-get blocks-per-spoint))))
;;returns multipliers for the collection
(define-read-only (get-multipliers)
    (ok (var-get multipliers)))
;;returns contract admin
(define-read-only (get-admin)
    (ok (var-get admin))) 
;;returns the number of spoints that can be collected for an address
(define-read-only (get-collect (address principal))
    (ok (check-collect address)))
;;returns the list of nfts subscribed by an address
(define-read-only (get-subscribed-nfts-per-address (address principal))
    (ok (check-subscribed-nfts-per-address address)))
;;returns the total number of nfts subscribed for this collection
(define-read-only (get-subscribed-items-count) 
  (ok (var-get subscribed-items)))

;;private functions
(define-private (check-subscribed-nfts-per-address (address principal))
  (default-to (list ) (get ids (map-get? subscribed-nfts-per-address { address: address}))))
(define-private (check-collect (address principal))
    (let (
        (subscription (get-subscription-per-address address))
        (block block-height)
        (balance (get points-balance subscription))
        (total-multiplier (get total-multiplier subscription))
        (prev-time (get time subscription))
        (blocks-per-sp (get-blocks-per-spoint))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-sp))
        (to-collect (+ balance points-added))       
    )
        to-collect))
(define-private (remove-item-id (item-id uint))
  (if (is-eq item-id (var-get removing-item-id)) false true))

(define-private (unsubscribe (lookup-table <lookup-trait>) (item uint))
    (let (
        (subscriber (unwrap-panic (unwrap-panic (get-item-subscriber item))))
        (subscription (get-subscription-per-address subscriber))
        (balance (get points-balance subscription))
        (total-multiplier (get total-multiplier subscription))
        (prev-time (get time subscription))
        (lifetime (get lifetime-earnings subscription))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (block block-height)
        (blocks-per-sp (get-blocks-per-spoint))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-sp))
        (ids (check-subscribed-nfts-per-address subscriber))
    )
    (asserts! (is-eq (var-get multipliers) (contract-of lookup-table)) (err ERR-NOT-AUTHORIZED))
    (var-set removing-item-id item)
    (begin 
        (map-set subscription-per-address { address: subscriber} { time: block, points-balance: (+ balance points-added), total-multiplier: (- total-multiplier multiplier), lifetime-earnings: lifetime })
        (map-set subscribed-nfts-per-address { address: subscriber} { ids: (filter remove-item-id ids) })
        (var-set subscribed-items (- (var-get subscribed-items) u1))
        (ok true))))

;;public functions

;;subscribes an nft in the collection to allocate spoints, 
;;it will remain subscribed until another address subscribes the same nft
(define-public (subscribe (lookup-table <lookup-trait>) (item uint)) 
    (let (
        (subscriber (unwrap-panic (get-item-subscriber item)))
        (unsubscribe-old-address (if (not (or (is-none subscriber) (is-eq subscriber (some tx-sender)))) (unsubscribe lookup-table item) (ok true)))
        (subscription (get-subscription-per-address tx-sender))
        (balance (get points-balance subscription))
        (total-multiplier (get total-multiplier subscription))
        (prev-time (get time subscription))
        (lifetime (get lifetime-earnings subscription))
        (multiplier (unwrap-panic (contract-call? lookup-table lookup (- item u1))))
        (block block-height)
        (blocks-per-sp (get-blocks-per-spoint))
        (points-added (/ (/ (* u1000000 (* total-multiplier (- block prev-time))) u10000) blocks-per-sp))
        (ids (check-subscribed-nfts-per-address tx-sender))
        )
        (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED)) 
        (asserts! (not (is-some (index-of (check-subscribed-nfts-per-address tx-sender) item))) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (var-get multipliers) (contract-of lookup-table)) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.the-cavalry get-owner item))) tx-sender) (err ERR-NOT-AUTHORIZED))
        (map-set subscription-per-address { address: tx-sender } { time: block, points-balance: (+ balance points-added), total-multiplier: (+ total-multiplier multiplier), lifetime-earnings: lifetime })
        (map-set subscribed-nfts-per-address { address: tx-sender } { ids: (unwrap-panic (as-max-len? (append ids item) u2500)) })
        (var-set subscribed-items (+ (var-get subscribed-items) u1))
        (map-set items-subscribers { item: item } { address: tx-sender })
        (ok true)))
;;generates the allocated spoints and links them to an nft in the collection SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club
(define-public (collect (spc-id uint) (amount uint))
  (let (
      (block block-height)
      (owner tx-sender)
      (subscription (get-subscription-per-address tx-sender))
      (lifetime (get lifetime-earnings subscription))
      (total-multiplier (get total-multiplier subscription))
      (to-collect (check-collect tx-sender))
    )
    (asserts! (is-eq (var-get shutoff-valve) false) (err ERR-NOT-AUTHORIZED))
    (asserts! (<= amount to-collect) (err ERR-INSUFFICIENT-BALANCE))
    (begin      
      (map-set subscription-per-address { address: tx-sender} {time: block-height, points-balance: u0, total-multiplier: total-multiplier , lifetime-earnings: (+ lifetime to-collect)})
      (try! (contract-call? .spoints collect spc-id amount))
      (ok true))))

;;admin functions   
(define-public (admin-unsubscribe (lookup-table <lookup-trait>) (item uint))
    (begin 
      (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
      (try! (unsubscribe lookup-table item))
      (map-delete items-subscribers { item: item })
      (ok true)))
(define-public (change-multipliers (new-multipliers principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set multipliers new-multipliers))
    (err ERR-NOT-AUTHORIZED)))
(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)))
(define-public (change-blocks-per-spoint (new-blocks-per-spoint-rate uint))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set blocks-per-spoint new-blocks-per-spoint-rate))
    (err ERR-NOT-AUTHORIZED)))

(contract-call? .spoints principal-approve (as-contract tx-sender))