;; staking
;; This contract will...

;; traits
(use-trait nft-trait 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.nft-trait.nft-trait)

;;badgers contracts
;;SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2
;;SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers

;;Admin
(define-constant admin-one tx-sender)

;;Errors
(define-constant ERR-NFT-STAKED-BEFORE (err u101))
(define-constant ERR-NOT-AUTH (err u102))
(define-constant ERR-NOT-STAKED (err u103))
(define-constant ERR-STAKED (err u104))
(define-constant ERR-UNWRAP (err u105))
(define-constant ERR-NOT-BABY-OWNER (err u106))
(define-constant ERR-NOT-BADGER-OWNER (err u107))
(define-constant ERR-NUMBER-BADGERS (err u108))
(define-constant ERR-NOT-HUNDRED-DAYS (err u109))
(define-constant ERR-ALREADY-ADMIN (err u110))
(define-constant ERR-NOT-IN-LIST (err u111))
(define-constant ERR-SENDER-STAKED-BEFORE (err u112))


;; data maps and vars
(define-data-var hundred-days-staking uint u14400)
(define-data-var floor-price uint u10)
(define-data-var owner principal 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8)
(define-data-var admins (list 100 principal) (list tx-sender))
(define-data-var helper-admin-principal principal tx-sender)
(define-data-var all-staked-principals (list 100 principal) (list))
(define-data-var helper-staked-principal principal tx-sender)
(define-data-var all-staked-badgers-history (list 10000 uint) (list))
(define-data-var all-staked-baby-badgers-history (list 10000 uint) (list))




;;map that defines which NFTs of which collection are staked and the time of the staking
(define-map staked-by-principal principal
    { 
        collection-badger: principal,
        staked-badger: (list 100 uint),

        collection-baby: principal,
        staked-baby: (list 100 uint),

        stake: uint,         
    }  
)

;;map to track all stakes by collection
;;  (define-map all-staked principal (list 10000 uint))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;read functions;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Get all admins 
(define-read-only (get-admins)
    (var-get admins) 
)

;;(define-read-only (get-staked-badgers)
  ;;  (map-get? all-staked .badgers) 
;;)

;;(define-read-only (get-staked-baby-badgers)
  ;;  (map-get? all-staked .babybadgers) 
;;)

;;Get all NFTs staked by user
(define-read-only (get-staked-by-user (staker principal))
    (map-get? staked-by-principal staker) 
)

;;Get time remaining 
(define-read-only (get-time-remaining-to-unstake (staker principal)) 
       (let 
            (
                (time-when-staked (unwrap! (get stake (map-get? staked-by-principal staker)) ERR-UNWRAP))
                (time-passed (- block-height time-when-staked))
            ) 

            (asserts! (is-eq u0 time-passed) ERR-NOT-STAKED)
            
            (ok 
                (print (- (var-get hundred-days-staking) time-passed))
            )
        )
)

(define-read-only (get-stake-requirements)
    (var-get floor-price)
)

(define-read-only (get-staked-principals)
    (ok (var-get all-staked-principals))
)

(define-read-only (get-all-staked-badgers)
    (var-get all-staked-badgers-history)
)

(define-read-only (get-all-staked-baby-badgers)
    (var-get all-staked-baby-badgers-history)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;public functions;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (add-admin-address (new-admin principal))
  (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (param-principal-position-in-list (index-of current-admin-list new-admin))
    )

    ;; asserts tx-sender is an existing whitelist address
    ;; right now admin-one isn't in this list 
    (asserts! (or (is-some caller-principal-position-in-list) (is-eq tx-sender admin-one)) ERR-NOT-AUTH)

    ;; asserts param principal (new whitelist) doesn't already exist
    (asserts! (is-none param-principal-position-in-list) ERR-ALREADY-ADMIN)

    ;; append new whitelist address
    (ok (var-set admins (unwrap! (as-max-len? (append (var-get admins) new-admin) u100) ERR-UNWRAP)))
  )
)

(define-public (remove-admin-address (admin principal))
  (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (removeable-principal-position-in-list (index-of current-admin-list admin))
    )

    ;; asserts tx-sender is an existing whitelist address
    ;; right now admin-one isn't in this list 
    (asserts! (or (is-some caller-principal-position-in-list) (is-eq tx-sender admin-one)) ERR-NOT-AUTH)

    ;; asserts param principal (new whitelist) doesn't already exist
    (asserts! (is-eq removeable-principal-position-in-list) ERR-NOT-IN-LIST)

    (var-set helper-admin-principal admin)

    ;; append new whitelist address
    (ok (var-set admins (filter is-not-removeable (var-get admins))))
  )
)

;;Floor price update by admin
(define-public (set-floor-price (new-floor uint))
    (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
    )

    ;;make sure that caller is admin
    (asserts! (is-some caller-principal-position-in-list) ERR-NOT-AUTH)

    ;; change floor-price
    (ok (var-set floor-price new-floor))
  )
)

;;Stake for discount function
(define-public (stake-for-discount (baby-list (list 100 uint)) (badger-list (list 100 uint)))
    (let 
        (
            (number-of-nfts (var-get floor-price))
            (baby-list-owner (map baby-badger-ownership-proof baby-list))
            (badger-list-owner (map badger-ownership-proof badger-list))
            (complete-list-of-nfts-to-stake (concat baby-list badger-list))
            (staker-map (map-get? staked-by-principal tx-sender))
            (badgers-staked-history (map badger-not-staked-proof badger-list))
            (baby-badgers-staked-history (map baby-badger-not-staked-proof baby-list))

        )
        ;; checking the list of baby-badger ownership
        (asserts! (not (is-some (index-of baby-list-owner (err u106)))) ERR-NOT-BABY-OWNER)
        ;; checking the list of badgers ownership 
        (asserts! (not (is-some (index-of badger-list-owner (err u107)))) ERR-NOT-BADGER-OWNER)
        ;;chechinkg to see if badger hasn't been staked before
        (asserts! (not (is-some (index-of badgers-staked-history (err u104)))) ERR-NFT-STAKED-BEFORE)
        ;;chechinkg to see if badger hasn't been staked before
        (asserts! (not (is-some (index-of baby-badgers-staked-history (err u104)))) ERR-NFT-STAKED-BEFORE)
        ;; checking number of badgers + baby-badgers = to price floor
        (asserts! (is-eq (len complete-list-of-nfts-to-stake) number-of-nfts) ERR-NUMBER-BADGERS)

        ;;asserts that the staker hasn't staked before
        (asserts! (is-none staker-map) ERR-SENDER-STAKED-BEFORE)

                 ;; maps to execute the transfers
                (map badger-transfer badger-list)
                (map baby-badger-transfer baby-list)

                

                ;; set maps for staked by collection
                ;;(map-set all-staked .badgers
                ;;(unwrap! (as-max-len? (concat (default-to (list) (map-get? all-staked .badgers)) badger-list) u10000) ERR-UNWRAP)
                ;;)

                ;;(map-set all-staked .babybadgers
                ;;(unwrap! (as-max-len? (concat (default-to (list) (map-get? all-staked .babybadgers)) baby-list) u10000) ERR-UNWRAP)
                ;;)

                ;; set map staked by principal with each list
                (map-set staked-by-principal tx-sender
                    {
                        collection-badger: 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2,
                        staked-badger: badger-list,

                        collection-baby: 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers,
                        staked-baby: baby-list,

                        stake: block-height,
                    }
                )

                ;;updating list of staked principals, appending 
                (var-set all-staked-principals (unwrap! (as-max-len? (append (var-get all-staked-principals) tx-sender) u100) ERR-UNWRAP))
                ;;upadting list of staked badgers historically
                (var-set all-staked-baby-badgers-history (unwrap! (as-max-len? (concat (var-get all-staked-baby-badgers-history) baby-list) u10000) ERR-UNWRAP))
                ;;upadting list of staked baby badgers historically
                (ok (var-set all-staked-badgers-history (unwrap! (as-max-len? (concat (var-get all-staked-badgers-history) badger-list) u10000) ERR-UNWRAP))
                )
    )
)

;;Unstake function just calling the function
(define-public (unstake) 
    (let 
        (
            (staker-map (map-get? staked-by-principal tx-sender))
            (list-of-baby-badgers (unwrap! (get staked-baby (map-get? staked-by-principal tx-sender)) ERR-UNWRAP))
            (list-of-badgers (unwrap! (get staked-badger (map-get? staked-by-principal tx-sender)) ERR-UNWRAP))
            (time-when-staked (unwrap! (get stake (map-get? staked-by-principal tx-sender)) ERR-UNWRAP))
            (time-to-unstake (var-get hundred-days-staking))
        ) 
        
        ;;asserts that the staker has a map
        (asserts! (is-some staker-map) ERR-NOT-STAKED)

        ;;asserts that the 100 days have passed
        (asserts! (> (- block-height time-when-staked) time-to-unstake) ERR-NOT-HUNDRED-DAYS)

                ;; setting var so the contract knows who the owner is
                (var-set owner tx-sender)
                
                ;; private functions to transfer from contract to owner
                (map badger-transfer-from-contract list-of-badgers)
                (map baby-badger-transfer-from-contract list-of-baby-badgers)

                ;; set map to remove staked by user reseting
                (ok 
                    (map-set staked-by-principal tx-sender
                        {
                            collection-badger: 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2,
                            staked-badger: (list),

                            collection-baby: 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers,
                            staked-baby: (list),

                            stake: u0,
                        }
                    )
                )

                ;; preparing to remove the principal from staked principals
                ;;(var-set helper-staked-principal tx-sender)
                
                ;; removing the principal from staked principals
               ;;(ok (var-set all-staked-principals (filter is-not-removeable-staked (var-get all-staked-principals)))) 
    
    )
)

;;Admin emergency unstake
(define-public (admin-emergency-unstake (address principal))
    (let 
        (
            (staker-map (map-get? staked-by-principal address))
            (current-admin-list (var-get admins))
            (caller-principal-position-in-list (index-of current-admin-list tx-sender))
            (list-of-baby-badgers (unwrap! (get staked-baby (map-get? staked-by-principal address)) ERR-UNWRAP))
            (list-of-badgers (unwrap! (get staked-badger (map-get? staked-by-principal address)) ERR-UNWRAP))
        ) 
        
        ;;make sure that caller is admin
        (asserts! (is-some caller-principal-position-in-list) ERR-NOT-AUTH)

        ;;asserts that the staker has a map to unstake
        (asserts! (not (is-none staker-map)) ERR-NOT-STAKED)

        
        (ok
            (begin 

                ;; setting var so the contract knows who the owner is
                (var-set owner address)

                ;; private functions to transfer from contract to owner
                (map badger-transfer-from-contract list-of-badgers)
                (map baby-badger-transfer-from-contract list-of-baby-badgers)

                ;;reseting map from principal to unstake
                (map-set staked-by-principal address
                    {
                        collection-badger: 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2,
                        staked-badger: (list),

                        collection-baby: 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers,
                        staked-baby: (list),

                        stake: u0,
                    }
                )  
            )
        )
    
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;private-functions;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; private function to proof ownerhsip of baby-badgers
(define-private (baby-badger-ownership-proof (item uint))
    (let
        ( 
            (baby-owner (unwrap! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers get-owner item) ERR-UNWRAP))
        )

        ;;checking ownership of every baby-badger
        (ok (asserts! (is-eq (some tx-sender) baby-owner) ERR-NOT-BABY-OWNER))
    )
)

(define-private (baby-badger-not-staked-proof (item uint))
    (let
        ( 
            (baby-badger-staked (var-get all-staked-baby-badgers-history))
        )

        ;;checking ownership of every baby-badger
        (ok (asserts! (not (is-some (index-of baby-badger-staked item))) ERR-STAKED))
    )
)



;; private function to proof ownerhsip of badgers
(define-private (badger-ownership-proof (item uint))
    (let
        ( 
            (badger-owner (unwrap! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 get-owner item) ERR-UNWRAP))
        )

        ;;checking ownership of every baby-badger
        (ok (asserts! (is-eq (some tx-sender) badger-owner) ERR-NOT-BADGER-OWNER))
    )
)

(define-private (badger-not-staked-proof (item uint))
    (let
        ( 
            (badger-staked (var-get all-staked-badgers-history))
        )

        ;;checking ownership of every baby-badger
        (ok (asserts! (not (is-some (index-of badger-staked item))) ERR-STAKED))
    )
)

;; private function to do the transfer from the owner to the staking contract
(define-private (baby-badger-transfer (item uint))
    (ok (unwrap! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers transfer item tx-sender 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.staking-discount) ERR-UNWRAP))
)

(define-private (badger-transfer (item uint))
    (ok (unwrap! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer item tx-sender 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.staking-discount) ERR-UNWRAP))
)

;; private function to do the transfer from the staking contract to the owner
(define-private (baby-badger-transfer-from-contract (item uint))
    (ok (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers transfer item 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.staking-discount (var-get owner))) ERR-UNWRAP))
)

(define-private (badger-transfer-from-contract (item uint))
    (ok (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer item 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.staking-discount (var-get owner))) ERR-UNWRAP))
)

;;private functions to help remove principals from list
(define-private (is-not-removeable (admin-principal principal))
  (not (is-eq admin-principal (var-get helper-admin-principal)))
)

(define-private (is-not-removeable-staked (staked-principal principal))
  (not (is-eq staked-principal (var-get helper-staked-principal)))
)

;;(define-private (is-not-id (list-id (list 100 uint)))
  ;;(not (is-eq list-id (var-get id-being-removed)))
;;)

;;(define-read-only (get-all-staked-badgers)
  ;;  (let 
    ;;(
      ;;  (staked-principals (var-get all-staked-principals))
    ;;) 
    
    ;;(ok (map get-all-badgers-helper staked-principals))
    
    ;;)

;;)

;;(define-private (get-all-badgers-helper (item principal))
  ;;(get staked-badger (map-get? staked-by-principal item))
;;)

;;(define-read-only (get-all-staked-baby-badgers)
  ;;  (let 
    ;;(
      ;;  (staked-principals (var-get all-staked-principals))
    ;;) 
    
    ;;(ok (map get-all-baby-badgers-helper staked-principals))
    
    ;;)

;;)

;;(define-private (get-all-baby-badgers-helper (item principal))
  ;;(get staked-baby (map-get? staked-by-principal item))
;;)
