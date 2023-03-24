;; Name of contract
;; This contract will handle the staking of 100 days for the badgers and baby badgers collections so that users can get a 50% discount on the 100 days of clarity course
;; Written by ClarityClear

;; traits
(use-trait nft-trait 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.nft-trait.nft-trait)
;; (use-trait nft-trait .nft-trait.nft-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;
;; Error Cons ;;
;;;;;;;;;;;;;;;;

;;need to change errors to bigger numbers

(define-constant ERR-NFT-STAKED-BEFORE (err u100001))
(define-constant ERR-NOT-AUTH (err u100002))
(define-constant ERR-NOT-STAKED (err u100003))
(define-constant ERR-STAKED (err u100004))
(define-constant ERR-UNWRAP (err u100005))
(define-constant ERR-NOT-BABY-OWNER (err u100006))
(define-constant ERR-NOT-BADGER-OWNER (err u100007))
(define-constant ERR-NUMBER-BADGERS (err u100008))
(define-constant ERR-NOT-HUNDRED-DAYS (err u100009))
(define-constant ERR-ALREADY-ADMIN (err u110000))
(define-constant ERR-NOT-IN-LIST (err u111000))
(define-constant ERR-SENDER-STAKED-BEFORE (err u112000))

;;;;;;;;;;;;;;;;;
;; Vars & Maps ;;
;;;;;;;;;;;;;;;;;

(define-data-var hundred-days-staking uint u14400)
(define-data-var stake-requirements uint u2)
(define-data-var owner principal 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8)
(define-data-var admins (list 100 principal) (list tx-sender))
(define-data-var helper-admin-principal principal tx-sender)
(define-data-var all-staked-principals (list 100 principal) (list))
(define-data-var helper-staked-principal principal tx-sender)
(define-data-var all-staked-badgers-history (list 10000 uint) (list))
(define-data-var all-staked-baby-badgers-history (list 10000 uint) (list))

;;map that defines which NFTs are staked and the time of the staking
(define-map staked-by-principal principal
    { 
        staked-badger: (list 100 uint),

        staked-baby: (list 100 uint),

        staking-blocks: uint,   

        staked: bool,  
    }  
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Read Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Get all admins 
(define-read-only (get-admins)
    (var-get admins) 
)

;;Get all NFTs staked by user
(define-read-only (get-staked-by-user (staker principal))
    (map-get? staked-by-principal staker) 
)

;;Get time remaining to unstake by principal
(define-read-only (get-time-remaining-to-unstake (staker principal)) 
       (let 
            (
                (time-when-staked (unwrap! (get staking-blocks (map-get? staked-by-principal staker)) ERR-UNWRAP))
                (time-passed (- block-height time-when-staked))
            ) 

            (asserts! (> (var-get hundred-days-staking) time-passed) ERR-NOT-STAKED)

            (ok 
                (- (var-get hundred-days-staking) time-passed)
            )             
        )
)

;; get amount of badgers and baby badgers to be able to stake
(define-read-only (get-stake-requirements)
    (var-get stake-requirements)
)

;; historically staked principals
(define-read-only (get-staked-principals)
    (var-get all-staked-principals)
)

;; historically staked badgers
(define-read-only (get-all-staked-badgers)
    (var-get all-staked-badgers-history)
)

;; historically staked baby badgers
(define-read-only (get-all-staked-baby-badgers)
    (var-get all-staked-baby-badgers-history)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;public functions;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Admin Functions ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @desc admins in the list will be able to add other admins
;; @param new admin principal

(define-public (add-admin-address (new-admin principal))
  (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (param-principal-position-in-list (index-of current-admin-list new-admin))
    )

    ;; asserts tx-sender is an existing whitelist address
    (asserts! (is-some caller-principal-position-in-list) ERR-NOT-AUTH)

    ;; asserts param principal (new whitelist) doesn't already exist
    (asserts! (is-none param-principal-position-in-list) ERR-ALREADY-ADMIN)

    ;; append new whitelist address
    (ok (var-set admins (unwrap! (as-max-len? (append (var-get admins) new-admin) u100) ERR-UNWRAP)))
  )
)

;; @desc admins in the list will be able to remove other admins
;; @param admin principal to be removed

(define-public (remove-admin-address (admin principal))
  (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
      (removeable-principal-position-in-list (index-of current-admin-list admin))
    )

    ;; asserts tx-sender is an existing whitelist address
    ;; right now admin-one isn't in this list 
    (asserts! (is-some caller-principal-position-in-list) ERR-NOT-AUTH)

    ;; asserts param principal (new whitelist) doesn't already exist
    (asserts! (is-eq removeable-principal-position-in-list) ERR-NOT-IN-LIST)

    (var-set helper-admin-principal admin)

    ;; append new whitelist address
    (ok (var-set admins (filter is-not-removeable (var-get admins))))
  )
)

;; @desc admins can modify the stake requirements for the amount of badgers
;; @param new staking uint requirements

(define-public (set-stake-requirements (new-req uint))
    (let
    (
      (current-admin-list (var-get admins))
      (caller-principal-position-in-list (index-of current-admin-list tx-sender))
    )

    ;;make sure that caller is admin
    (asserts! (is-some caller-principal-position-in-list) ERR-NOT-AUTH)

    ;; change floor-price
    (ok (var-set stake-requirements new-req))
  )
)

;; @desc main staking function to get the discount
;; @param baby badgers list and badgers list

(define-public (stake-for-discount (baby-list (list 100 uint)) (badger-list (list 100 uint)))
    (let 
        (
            (number-of-nfts (var-get stake-requirements))
            (baby-list-owner (map baby-badger-ownership-proof baby-list))
            (badger-list-owner (map badger-ownership-proof badger-list))
            (complete-list-of-nfts-to-stake (concat baby-list badger-list))
            (staker-map (map-get? staked-by-principal tx-sender))
            (badgers-staked-history (map badger-not-staked-proof badger-list))
            (baby-badgers-staked-history (map baby-badger-not-staked-proof baby-list))

        )
        ;; checking the list of baby-badger ownership
        (asserts! (is-none (index-of baby-list-owner (err u106))) ERR-NOT-BABY-OWNER)
        ;; checking the list of badgers ownership 
        (asserts! (is-none (index-of badger-list-owner (err u107))) ERR-NOT-BADGER-OWNER)
        ;; checking to see if badger hasn't been staked before
        (asserts! (is-none (index-of badgers-staked-history (err u104))) ERR-NFT-STAKED-BEFORE)
        ;; checking to see if baby badger hasn't been staked before
        (asserts! (is-none (index-of baby-badgers-staked-history (err u104))) ERR-NFT-STAKED-BEFORE)
        ;; checking number of badgers + baby-badgers = to stake reqs
        (asserts! (is-eq (len complete-list-of-nfts-to-stake) number-of-nfts) ERR-NUMBER-BADGERS)

        ;;asserts that the staker hasn't staked before
        (asserts! (is-none staker-map) ERR-SENDER-STAKED-BEFORE)

                 ;; maps to execute the transfers
                (map badger-transfer badger-list)
                (map baby-badger-transfer baby-list)

                ;; set map staked by principal with each list
                (map-set staked-by-principal tx-sender
                    {
                        staked-badger: badger-list,
                        
                        staked-baby: baby-list,

                        staking-blocks: block-height,

                        staked: true,
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

;; @desc unstaking function once the blocks have passed
;; @param none needed since we get the information from the map of the staker
(define-public (unstake) 
    (let 
        (
            (staker-map (map-get? staked-by-principal tx-sender))
            (list-of-baby-badgers (unwrap! (get staked-baby (map-get? staked-by-principal tx-sender)) ERR-UNWRAP))
            (list-of-badgers (unwrap! (get staked-badger (map-get? staked-by-principal tx-sender)) ERR-UNWRAP))
            (time-when-staked (unwrap! (get staking-blocks (map-get? staked-by-principal tx-sender)) ERR-UNWRAP))
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
                            staked-badger: (list),

                            staked-baby: (list),

                            staking-blocks: u0,

                            staked: true,
                        }
                    )
                )
    )
)

;; @desc unstaking function to be called only by admin
;; @param the pirncipal to be unstaked
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
                        staked-badger: (list),
                        
                        staked-baby: (list),

                        staking-blocks: u0,

                        staked: true,
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
            ;; (baby-owner (unwrap! (contract-call? .babybadgers get-owner item) ERR-UNWRAP))
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
            ;; (badger-owner (unwrap! (contract-call? .badgers get-owner item) ERR-UNWRAP))
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
    (ok (unwrap! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers transfer item tx-sender 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.badgers-staking-discount) ERR-UNWRAP))
    ;; (ok (unwrap! (contract-call? .babybadgers transfer item tx-sender .staking) ERR-UNWRAP))
)

(define-private (badger-transfer (item uint))
    (ok (unwrap! (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer item tx-sender 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.badgers-staking-discount) ERR-UNWRAP))
    ;; (ok (unwrap! (contract-call? .badgers transfer item tx-sender .staking) ERR-UNWRAP))
)

;; private function to do the transfer from the staking contract to the owner
(define-private (baby-badger-transfer-from-contract (item uint))
    (ok (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.baby-badgers transfer item 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.badgers-staking-discount (var-get owner))) ERR-UNWRAP))
    ;; (ok (unwrap! (as-contract (contract-call? .babybadgers transfer item .staking (var-get owner))) ERR-UNWRAP))
)

(define-private (badger-transfer-from-contract (item uint))
    (ok (unwrap! (as-contract (contract-call? 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.btc-badgers-v2 transfer item 'SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8.badgers-staking-discount (var-get owner))) ERR-UNWRAP))
    ;; (ok (unwrap! (as-contract (contract-call? .badgers transfer item .staking (var-get owner))) ERR-UNWRAP))
)

;;private functions to help remove principals from list
(define-private (is-not-removeable (admin-principal principal))
  (not (is-eq admin-principal (var-get helper-admin-principal)))
)


