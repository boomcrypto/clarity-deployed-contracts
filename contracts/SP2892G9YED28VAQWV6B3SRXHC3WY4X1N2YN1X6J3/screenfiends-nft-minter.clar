(define-constant CONTRACT-OWNER tx-sender)
(define-constant MAX-SUPPLY u5000)

(define-data-var artist-address principal 'SP3CFHSKDCW3761DD1P6X3VEC3NHKTJ4H0XJT79D6)
(define-data-var member1-address principal 'SPN7M36SSAZQZZ1T4JRQF6PRJDXPT4VRW7Y8QRR)
(define-data-var member2-address principal 'SP2JVKEW0YKTNT3SCTQSPF2V3DDVFFNG6B2TF9ZSV)
(define-data-var project-address principal 'SPSSETN3G8A1V7PB0M6A8Q27WFG5J9EMWTDE1WZA)
(define-data-var price uint u25000000)
(define-data-var nft-contract principal .screenfiends-nft)
(define-data-var premint-live bool false)
(define-data-var mint-live bool false)
(define-map mint-passes principal uint)
(define-map mint-count principal uint)

(define-data-var current-phase uint u1)
(define-map phase-active uint bool)
(define-map phase-supply uint {start: uint, end: uint})
(define-map whitelist-next-phase principal uint)
(define-map phase-presale-active uint bool)
(define-map phase-publicsale-active uint bool)


(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-MINT-NOT-LIVE (err u402))
(define-constant ERR-SOLD-OUT (err u403))
(define-constant ERR-NOT-ENOUGH-MINT-PASSES (err u405))
(define-constant ERR-SUPPLY-NOT-DEFINED (err u404))


(define-private (is-owner)
    (is-eq tx-sender CONTRACT-OWNER))

(define-public (set-price (new-price uint))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set price new-price)
        (ok true)))

(define-read-only (get-price)
    (ok (var-get price)))

(define-public (set-nft-contract (contract principal))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set nft-contract contract)
        (ok true)))

(define-public (set-artist-address (address principal ))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set artist-address address)
        (ok true)))

(define-public (set-member1-address (address principal ))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set member1-address address)
        (ok true)))

(define-public (set-member2-address (address principal ))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set member2-address address)
        (ok true)))


(define-public (set-project-address (address principal ))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set project-address address)
        (ok true)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: initialize-phase-supply
;; Description:
;;   Dynamically calculates and populates the `phase-supply` map with values
;;   for 5 phases, where the total supply is evenly divided among the phases.
;;
;; Parameters:
;;   - max-supply (uint): The total supply of NFTs to be divided into phases.
;;
;; Returns:
;;   - (ok true) if the initialization is successful.
;;   - (err u401) if called by a non-owner.
;;
;; Notes:
;;   - Divides the max-supply into 5 equal chunks.
;;   - Handles cases where max-supply is not divisible by 5.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (initialize-phase-supply (max-supply uint))
  (begin
    (asserts! (is-owner) ERR-NOT-AUTHORIZED)

    ;; Calculate the phase size
    (let 
      (
        (phase-size (/ max-supply u5)) ;; Divide the supply into 5 phases
      )

      ;; Initialize each phase
      (map-set phase-supply u1 {start: u1, end: phase-size})
      (map-set phase-supply u2 {start: (+ phase-size u1), end: (* phase-size u2)})
      (map-set phase-supply u3 {start: (+ (* phase-size u2) u1), end: (* phase-size u3)})
      (map-set phase-supply u4 {start: (+ (* phase-size u3) u1), end: (* phase-size u4)})
      (map-set phase-supply u5 {start: (+ (* phase-size u4) u1), end: max-supply})

      (ok true)
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: set-current-phase
;; Description:
;;   Sets the current active phase for the contract. Only callable by the contract owner.
;;
;; Parameters:
;;   - phase (uint): The phase number to set as the current phase.
;;
;; Returns:
;;   - (ok true) if the operation is successful.
;;   - (err u401) if the caller is not authorized.
;;
;; Notes:
;;   - This function updates the contract's `current-phase` variable.
;;   - Ensures that only the contract owner can make this change.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (set-current-phase (phase uint))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set current-phase phase)
        (ok true)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: get-current-phase
;; Description:
;;   Retrieves the current active phase of the contract.
;;
;; Parameters:
;;   - None
;;
;; Returns:
;;   - (ok uint): The current phase number.
;;
;; Notes:
;;   - This function provides a read-only view of the `current-phase` variable.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get-current-phase)
    (ok (var-get current-phase)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: get-phase-supply
;; Description:
;;   Retrieves the supply range for a given phase, including the start and end
;;   token IDs for the phase.
;;
;; Parameters:
;;   - phase (uint): The phase number whose supply range is to be retrieved.
;;
;; Returns:
;;   - (ok {start: uint, end: uint}) if the phase exists.
;;   - (ok none) if the phase is not set.
;;
;; Notes:
;;   - The supply range is defined as a map with `start` and `end` values.
;;   - This function provides a read-only view of the phase supply.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get-phase-supply (phase uint))
    (ok (map-get? phase-supply phase)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: get-phase-remaining-supply
;; Description:
;;   Retrieves the remaining supply for a given phase, calculated based
;;   on the last minted token ID and the phase's `start` and `end` values.
;;
;; Parameters:
;;   - phase-id (uint): The phase number whose remaining supply is to be retrieved.
;;
;; Returns:
;;   - (ok uint): The remaining supply for the given phase.
;;
;; Notes:
;;   - Calls the `.screenfiends-nft` contract to get the last minted token ID.
;;   - Retrieves the `start` and `end` values from the `phase-supply` map.
;;   - If `last-id` is outside the phase's range, adjusts the remaining supply accordingly.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get-phase-remaining-supply (phase-id uint))
  (let
    (
      (last-id (unwrap-panic (contract-call? .screenfiends-nft get-last-token-id)))
      (phase-supply-config (unwrap! (map-get? phase-supply phase-id) (err ERR-SUPPLY-NOT-DEFINED)))
      (start-supply (get start phase-supply-config))
      (end-supply (get end phase-supply-config))
    )
    (if (>= last-id end-supply)
        ;; If `last-id` is beyond or equal to the phase's range, no supply left
        (ok u0)
        ;; Otherwise, calculate remaining supply within the phase range
        (if (< last-id start-supply)
            ;; If `last-id` is below the phase's range, full supply remains
            (ok (- (+ end-supply u1) start-supply))
            ;; Else, remaining supply is adjusted for minted tokens
            (ok (- end-supply last-id))
        )
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: set-phase-active
;; Description:
;;   Sets a phase actve
;;
;; Parameters:
;;   - phase (uint) - The phase number to set active
;;   - active (bool) - The status to set the phase
;;
;; Returns:
;;   - (ok bool): true indicating successful update
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (set-phase-active (phase uint) (active bool))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (map-set phase-active phase active)
        (ok true)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: is-phase-active
;; Description:
;;   Checks whether a specific phase is active.
;;
;; Parameters:
;;   - phase (uint): The phase number to check.
;;
;; Returns:
;;   - (ok bool): `true` if the phase is active, `false` otherwise.
;;
;; Notes:
;;   - Uses the `phase-active` map to determine the active status of the phase.
;;   - If no value is set for the phase in the `phase-active` map, defaults to `false`.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (is-phase-active (phase uint))
    (ok (default-to false (map-get? phase-active phase))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: set-phase-presale-active
;; Description:
;;   Enables or disables the presale status for a specific phase.
;;
;; Parameters:
;;   - phase (uint): The phase number to update.
;;   - active (bool): `true` to enable presale, `false` to disable it.
;;
;; Returns:
;;   - (ok true) if the operation is successful.
;;   - (err u401) if the caller is not authorized.
;;
;; Notes:
;;   - Only callable by the contract owner.
;;   - Updates the `phase-presale-active` map with the provided status.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (set-phase-presale-active (phase uint) (active bool))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (map-set phase-presale-active phase active)
        (ok true)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: set-phase-publicsale-active
;; Description:
;;   Enables or disables the public sale status for a specific phase.
;;
;; Parameters:
;;   - phase (uint): The phase number to update.
;;   - active (bool): `true` to enable public sale, `false` to disable it.
;;
;; Returns:
;;   - (ok true) if the operation is successful.
;;   - (err u401) if the caller is not authorized.
;;
;; Notes:
;;   - Only callable by the contract owner.
;;   - Updates the `phase-publicsale-active` map with the provided status.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (set-phase-publicsale-active (phase uint) (active bool))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (map-set phase-publicsale-active phase active)
        (ok true)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: is-phase-presale-active
;; Description:
;;   Checks whether the presale is active for a specific phase.
;;
;; Parameters:
;;   - phase (uint): The phase number to check.
;;
;; Returns:
;;   - (ok bool): `true` if the presale is active, `false` otherwise.
;;
;; Notes:
;;   - Uses the `phase-presale-active` map to determine the status.
;;   - Defaults to `false` if the phase is not set in the map.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (is-phase-presale-active (phase uint))
    (ok (default-to false (map-get? phase-presale-active phase))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: is-phase-publicsale-active
;; Description:
;;   Checks whether the public sale is active for a specific phase.
;;
;; Parameters:
;;   - phase (uint): The phase number to check.
;;
;; Returns:
;;   - (ok bool): `true` if the public sale is active, `false` otherwise.
;;
;; Notes:
;;   - Uses the `phase-publicsale-active` map to determine the status.
;;   - Defaults to `false` if the phase is not set in the map.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (is-phase-publicsale-active (phase uint))
    (ok (default-to false (map-get? phase-publicsale-active phase))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: add-mintpasses
;; Description:
;;   Adds or updates the mint passes for a list of addresses. Each address
;;   can be assigned a specific number of mint passes.
;;
;; Parameters:
;;   - entries (list 2000 {address: principal, quantity: uint}):
;;       A list of objects where:
;;       - `address` (principal): The principal address to assign mint passes to.
;;       - `quantity` (uint): The number of mint passes to assign.
;;
;; Returns:
;;   - (ok true) if the operation is successful.
;;   - (err u401) if the caller is not authorized.
;;
;; Notes:
;;   - Only callable by the contract owner.
;;   - Iterates over the `entries` list and uses the `add-mintpasses-iter` function
;;     to update the `mint-passes` map.
;;   - Prints the total number of addresses processed for debugging purposes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (add-mintpasses (entries (list 2000 {address: principal, quantity: uint})))
  (begin
    (asserts! (is-owner) ERR-NOT-AUTHORIZED)
    (let
      ((index-reached (fold add-mintpasses-iter entries u0)))
      (print {total-mintpasses-added: index-reached})
      (ok true))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function Name: get-mint-passes-remaining
;; Description:
;;   Calculates the remaining number of mint passes available for a given address.
;;
;; Parameters:
;;   - address (principal): The address to check for remaining mint passes.
;;
;; Returns:
;;   - (ok uint): The number of remaining mint passes for the given address.
;;
;; Notes:
;;   - Retrieves the total mint passes (`allowed`) from the `mint-passes` map.
;;   - Retrieves the number of NFTs minted (`minted`) from the `mint-count` map.
;;   - Calculates the remaining passes as `allowed - minted`. Defaults both
;;     values to `u0` if no entry exists in their respective maps.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get-mint-passes-remaining (address principal))
    (let (
        (minted (default-to u0 (map-get? mint-count address)))
        (allowed (default-to u0 (map-get? mint-passes address)))
    )
        (ok (- allowed minted))))


(define-read-only (get-mint-passes (address principal))
  (ok (default-to u0 (map-get? mint-passes address))))


(define-public (clear-mintpasses (addresses (list 2000 principal)))
  (begin
    (asserts! (is-owner) ERR-NOT-AUTHORIZED)
    (let
      ((index-reached (fold clear-mintpasses-iter addresses u0)))
      (print {total-mintpasses-cleared: index-reached})
      (ok true))))


(define-private (clear-mintpasses-iter (address principal) (next-index uint))
  (begin
    (map-delete mint-passes address)
    (+ next-index u1)))

(define-private (add-mintpasses-iter (entry {address: principal, quantity: uint}) (next-index uint))
  (begin
    (map-set mint-passes (get address entry) (get quantity entry))
    (+ next-index u1)))

(define-read-only (get-mint-count (address principal))
  (ok (default-to u0 (map-get? mint-count address))))


(define-private (direct-mint (new-owner principal))
    (contract-call? .screenfiends-nft mint new-owner))


(define-private (mnt)
  (let
    (
      (active-phase (var-get current-phase))
      (phase-is-active (unwrap-panic (is-phase-active active-phase)))
      (phase-premint-live (default-to false (map-get? phase-presale-active active-phase)))
      (phase-public-mint-live (default-to false (map-get? phase-publicsale-active active-phase)))
      (phase-supply-config (unwrap-panic (get-phase-supply active-phase)))
      (remaining-supply (unwrap-panic (get-phase-remaining-supply active-phase)))
      (mintpass-passes (unwrap-panic (get-mint-passes-remaining tx-sender)))
      (max-phase-supply (get end phase-supply-config))
    )

    ;; Check if there are NFTs left to mint
    (asserts! (> remaining-supply u0) ERR-SOLD-OUT)

    (asserts! phase-is-active ERR-MINT-NOT-LIVE)

    ;; Check if mint-live or premint-live is true, otherwise throw error
    (if (or phase-public-mint-live phase-premint-live)
        ;; If mint-live is true, allow public mint
        (if phase-public-mint-live
            (direct-mint tx-sender)

            ;; Otherwise, check if premint mint is live and mintpass passes are available
            (if (> mintpass-passes u0)
                (begin
                  ;; Update mint count and mint for mintpass pass holders
                  (map-set mint-count tx-sender (+ (default-to u0 (map-get? mint-count tx-sender)) u1))
                  (direct-mint tx-sender)
                )
                ERR-NOT-ENOUGH-MINT-PASSES))
        ERR-MINT-NOT-LIVE)))

(define-private (mint-iter (ignore uint) (prior {minted: uint, error: (optional (response bool uint)), continue: bool, count: uint}))
    (if (and (< (get minted prior) (get count prior)) (get continue prior))
        (match (mnt)
            success (merge prior {minted: (+ u1 (get minted prior))})
            error (merge prior {error: (some (err error)), continue: false}))
        prior))

(define-public (mint (count uint))
    (let
        (
            (total-price (* (var-get price) count))
            (art-addr (var-get artist-address))
            (member1-addr (var-get member1-address))
            (member2-addr (var-get member2-address))
            (project-addr (var-get project-address))
            (total-artist-comm (/ (* total-price u4750) u10000))
            (total-member1-comm (/ (* total-price u2375) u10000))
            (total-member2-comm (/ (* total-price u2375) u10000))
            (total-project-comm (/ (* total-price u500) u10000))
            (loop-result
                (begin
                    (try! (stx-transfer? total-artist-comm tx-sender art-addr))
                    (try! (stx-transfer? total-member1-comm tx-sender member1-addr))
                    (try! (stx-transfer? total-member2-comm tx-sender member2-addr))
                    (try! (stx-transfer? total-project-comm tx-sender project-addr))
                    (fold mint-iter
                        (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25)
                        {minted: u0, error: none, continue: true, count: count}
                    )
                )
            )
        )
        (if (is-some (get error loop-result))
            (unwrap-panic (get error loop-result))
            (ok true))))




