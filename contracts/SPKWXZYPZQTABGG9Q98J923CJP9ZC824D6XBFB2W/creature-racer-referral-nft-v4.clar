
;; creature-racer-referral-nft
;; wannabe rNFT contract for creature racer
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;
;; =========
;; CONSTANTS
;; =========
;;

;; Contract owner
(define-constant contract-owner tx-sender)


(define-constant fixed-bonus-amount-ustx u250)

(define-constant special-bps u5000)
;;
;; ERROR DEFINITIONS
;;


;; referral code was already used to mint rNFT
(define-constant err-refcode-used (err u3001))

;; user address already has an rNFT
(define-constant err-rnft-already-granted (err u3002))

;; referral already has fixed bonus
(define-constant err-has-fixed-bonus (err u3003))

;; only first owner of rNFT can perform this action
(define-constant err-only-first-owner (err u3004))

;; referral code too length error
(define-constant err-invalid-length (err u3005))

;; recipient invalid i.e. attempted to transfer to self
(define-constant err-invalid-recipient (err u3006))

;; numeric argument is out of allowed range
(define-constant err-argument-out-of-range (err u3007))

;; user not allowed to perform transfer
(define-constant err-forbidden (err u403))


;; asset not found
(define-constant err-not-found (err u404))
;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;
(define-non-fungible-token creature-racer-referral-nft uint)
(define-data-var last-token-id uint u0)

;; maps invited user address to token id
(define-map invitees principal uint)

;; first owner of minted token
(define-map first-owner uint principal)

;; tracking amount of rnfts owned by user
(define-map rnft-count principal uint)

;; maps token id to referral code
(define-map token-ids uint (string-utf8 150))
(define-map ref-codes (string-utf8 150) uint)

;; invitations counter
(define-map invitations uint uint)

;; token-id => if token has fixed bonus
(define-map has-fixed-referral-bonus uint bool)


(define-map fixed-bonus-charged {rnft-id: uint, invitee: principal} bool)


(define-map royalties uint uint)

;; token-id => eligible for special share
(define-map special-share uint bool)

;; transfer approval maps
(define-map approvals {     owner: principal,
                            operator: principal } bool)
(define-map token-approvals { owner: principal,
                              token: uint,
                              operator: principal } bool)
    

;;
;; =================
;; PRIVATE FUNCTIONS
;; =================
;;


;; Check if tx-sender is authorized to transfer token
;; owned by sender.
(define-private (is-transfer-allowed (token-id uint)
                                     (sender principal))
    (if (is-eq sender tx-sender) true
        (if (default-to false (map-get? approvals
                                        { owner: sender,
                                        operator: tx-sender }))
            true
            (default-to false
                (map-get? token-approvals 
                          { owner: sender,
                          token: token-id,  
                          operator: tx-sender })
              )
            )
        )
  )

(define-private (get-percentage-of-reward-for-invitations (ninv uint))
    (if (>= ninv u1501) u4000
        (if (>= ninv u500) u2000
            (if (>= ninv u75) u1000
                (if (>= ninv u25) u500
                    (if (>= ninv u1) u100
                        u0)
                    )
                )
            )
        )
  )


;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;
;;
;; Functions required by nft-trait
;;

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
  )

(define-read-only (get-token-uri (token-id uint))
  ;; NFT URI is not supported by this contract
  (ok none)
  )

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? creature-racer-referral-nft token-id))
  )

(define-public (transfer (token-id uint) (sender principal)
                         (recipient principal))
  (begin
   (asserts! (is-transfer-allowed token-id sender) err-forbidden)
   (asserts! (not (is-eq sender recipient)) 
             err-invalid-recipient)

   (try! (nft-transfer? creature-racer-referral-nft
                        ;; #[allow(unchecked_data)]
                        token-id
                        sender
                        recipient))
   (map-delete token-approvals
               { owner: sender,
                 token: token-id,
                 operator: tx-sender })
   (map-set rnft-count sender 
            (- (unwrap-panic (map-get? rnft-count sender))
                             u1))
   (ok (map-set rnft-count recipient
                (match (map-get? rnft-count recipient)
                       val (+ val u1)
                       u1))
       )
                        
   )
  )

;;
;; Transfer approval management
;;

;; (Dis-)Approve operator for transfer of any NFT owned by
;; tx-sender. 
;; Returns: (ok true)  if setting's successfuly updated.
;;          (ok false) if operator is equal to sender.
(define-public (set-approved-for-all (operator principal)
                                     (approved bool))
    (if (is-eq operator tx-sender)
        (ok false)
        (ok
         ;; #[allow(unchecked_data)]
         (map-set approvals { owner: tx-sender,
                  operator: operator } approved)))
  )
  
;; (Dis-)Approve operator for transfer of given NFT owned
;; by tx-sender. 
;; Returns: (ok true)  if setting's successfuly updated.
;;          (ok false) if operator is equal to sender.
;;          (err u403) if sender doesn't own the NFT.
(define-public (approve (operator principal)
                        (token uint)
                        (approved bool))
    (if (is-eq (some tx-sender)
               (nft-get-owner? creature-racer-referral-nft
                               token))
        (if (is-eq operator tx-sender)
            (ok false)
            (ok
             ;; #[allow(unchecked_data)]
             (map-set token-approvals { owner: tx-sender,
                      token: token,
                      operator: operator }
                      approved))
            )
        err-forbidden
        )
  )

;;
;; rNFT public interface
;;
(define-public (mint (refcode (string-utf8 150))) 
    (let (
          (recipient tx-sender)
          (your-token-id (+ (var-get last-token-id) u1))
          (last-count (default-to u0 (map-get? rnft-count recipient)))
          )
      (asserts! (> (len refcode) u3) err-invalid-length)

      (if (is-none (map-get? ref-codes refcode))
          ;; #[allow(unchecked_data)]
          (begin
           (map-set rnft-count recipient (+ u1 last-count))
           (map-insert first-owner your-token-id recipient)
           (map-insert ref-codes refcode your-token-id)
           (try! (nft-mint? creature-racer-referral-nft 
                            your-token-id
                            tx-sender))
           (var-set last-token-id your-token-id)
           (ok your-token-id)
           )
          err-refcode-used)
      )
  )
  

(define-read-only (get-first-owner (token-id uint))
    (match (map-get? first-owner token-id)
           val (ok val)
           err-not-found)
  )

(define-public (special-mint (refcode (string-utf8 150))
                             (operator-sig (buff 65))
                             (sender-pk (buff 33)))
    (begin
     (try! (contract-call? .creature-racer-admin-v4
                           verify-signature-string
                           operator-sig
                           sender-pk
                           refcode))
     (let (
           (token-id (try! (mint refcode)))
           )
       ;; #[allow(unchecked_data)]
       (map-set special-share token-id true)
       (ok token-id)
       )
     )
  )
      

;;
;; Arguments: refcode - utf-8 string[150]
;; Returns: (result uint uint) number of invitations on success
(define-read-only (get-invitations-by-ref-code (refcode (string-utf8 150)))
    (let (
          (token-id (unwrap! (get-token-id refcode) err-not-found))
          )
      (ok (unwrap! (map-get? invitations token-id) err-not-found))
      )
  )

(define-read-only (get-invitations-by-invitee (invitee principal))
    (let (
          (token-id (unwrap! (map-get? invitees invitee)
                             err-not-found))
          )
      (ok (unwrap! (map-get? invitations token-id)
                   err-not-found))
      )
  )

(define-read-only (get-token-id (refcode (string-utf8 150)))
    (match (map-get? ref-codes refcode)
           val (ok val)
           err-not-found)
  )

(define-read-only (get-percentage-of-reward-bps (invitee principal))
    (let (
          (ninv (match (get-invitations-by-invitee invitee)
                       val val not-found u0))
          )
      (ok (get-percentage-of-reward-for-invitations ninv))
      )
  )

(define-read-only (is-special-rnft (token-id uint))
    (match (map-get? special-share token-id)
           v (ok v)
           err-not-found))

(define-read-only (get-referral-token (ref-code (string-utf8 150)))
    (match (map-get? ref-codes ref-code)
           v (ok v)
           err-not-found))

(define-public (set-referral-to-receiving-fixed-bonus 
                (refcode (string-utf8 150)))
    (let (
          (token-id (try! (get-token-id refcode)))
          )
      (try! (contract-call? .creature-racer-admin-v4
                            assert-invoked-by-operator))
      ;; #[allow(unchecked_data)]
      (if (map-insert has-fixed-referral-bonus token-id true)
          (ok true)
          err-has-fixed-bonus))
  )


(define-public (increment-invitations (refcode (string-utf8 150))
                                      (invitee principal))
    (let (
          (token-id (try! (get-token-id refcode)))
          )
     (try! (contract-call? .creature-racer-admin-v4
                           assert-invoked-by-operator))
     ;; #[allow(unchecked_data)]
     (map-set invitees invitee token-id)
     ;; #[allow(unchecked_data)]
     (ok (map-set invitations token-id
                  (match (map-get? invitations token-id)
                         cnt (+ cnt u1)
                         u1)
                  ))
     )
  )

(define-public (set-royalty (token-id uint)
                            (percentage-basis-points uint))
    (let (
          (owner (unwrap! (get-first-owner token-id)
                          err-not-found))
          )
      (asserts! (is-eq owner tx-sender) err-only-first-owner)
      (asserts! (<= percentage-basis-points u100)
                err-argument-out-of-range)

      (ok (map-set royalties token-id percentage-basis-points))
      )
  )


(define-read-only (royalty-info (token-id uint)
                                (sale-price uint))
    (let (
          (owner (unwrap! (get-first-owner token-id)
                          err-not-found))
          (royalty (unwrap! (map-get? royalties
                                      token-id)
                            err-not-found))
          )
      (ok { amount: (/ (* sale-price royalty) u10000),
          receiver: owner })
      )
  )


(define-public (calculate-referral-profit (invitee principal) 
                                          (amount uint))
    (let
        (
         (rnft-id (unwrap! (map-get? invitees invitee)
                           (ok { profit: u0, rnft-id: u0 })))
         (is-special (default-to false (map-get? special-share rnft-id)))
         (ref-bps (if is-special
                      special-bps
                      (unwrap-panic (get-percentage-of-reward-bps invitee))))
         (has-fb (default-to false 
                              (map-get? has-fixed-referral-bonus rnft-id)))
         (fb-charged (default-to false 
                                  (map-get? fixed-bonus-charged 
                                            {rnft-id: rnft-id, invitee: invitee})
                                ))
         (bonus (if (and has-fb (not fb-charged))
                    (begin
                     ;; #[allow(unchecked_data)]
                     (map-set fixed-bonus-charged
                              {rnft-id: rnft-id, invitee: invitee}
                              true)
                     fixed-bonus-amount-ustx)
                    u0))
         )
      (ok { profit: (+ bonus (/ (* amount ref-bps) u10000)),
          rnft-id: rnft-id })
    )
  )

(define-read-only (get-refcode-profit (refcode (string-utf8 150)))
    (let
        (
         (rnft-id (try! (get-token-id refcode)))
         (is-special (default-to false (map-get? special-share rnft-id)))
         (ninv (default-to u0 (map-get? invitations rnft-id)))
         )
      (ok (if is-special special-bps (get-percentage-of-reward-for-invitations ninv)))
      )
  )
