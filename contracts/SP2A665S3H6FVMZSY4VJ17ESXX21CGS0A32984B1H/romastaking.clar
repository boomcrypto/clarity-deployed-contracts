(use-trait token-trait 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.token-trait.token-trait)

;; blocks after the contract deploy for first cycle
(define-data-var start-block-till-deploy uint u288)
;; interval between cycles
(define-data-var cycle-interval uint u144)
;; cycle length
(define-data-var cycle-length uint u2016)
;; percentage of contract amount
(define-data-var cycle-percentage uint u20)
;; autobuild cycle
(define-data-var cycle-auto-build bool true)

(define-constant error-opening-cycle (err u17))
(define-constant stake-cycle-not-found (err u404))
(define-constant stake-cycle-closed (err u403))
(define-constant stake-cycle-open (err u403))
(define-constant sender-just-staking-for-cycle (err u403))
(define-constant permission-denied-err (err u403))
(define-constant err-collection-not-found (err u404))
(define-constant contract-err (err u500))
(define-constant err-invalid-value (err u422))
(define-constant no-stx-transfers (err u12))
(define-constant error-ending-stake (err u13))
(define-constant error-continuing-stake (err u14))
(define-constant error-setting-map-delegate (err u15))
(define-constant error-delegate-not-found (err u404))
(define-constant error-setting-last-cycle (err u500))
(define-constant error-closing-staking (err u501))


(define-constant cntrct-owner tx-sender)
(define-data-var daily-blocks uint u144)

(define-public (set-daily-blocks (num uint))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (var-set daily-blocks num))
  )
)

(define-data-var administrative-contracts (list 100 principal) (list) )
(define-data-var current-removing-administrative (optional principal) none )
(define-private (is-administrative (address principal))
  (or
    (is-eq cntrct-owner address )
    (not (is-none (index-of (var-get administrative-contracts) address)) )
  )
)
(define-read-only (is-admin (address principal))
  (begin
    (asserts! (is-administrative address) permission-denied-err)
    (ok u1)
  )
)
(define-public (add-address-to-administrative
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set administrative-contracts (unwrap-panic (as-max-len? (append (var-get administrative-contracts) address) u100) )) contract-err )
    (ok true)
  )
)
(define-private (filter-remove-from-administrative 
    (address principal )
  )
  (
    not (is-eq (some address) (var-get current-removing-administrative))
  )
)
(define-public (remove-address-from-adminstrative
    (address principal)
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (var-set current-removing-administrative (some address) ) contract-err )
    (asserts! (var-set administrative-contracts (filter filter-remove-from-administrative (var-get administrative-contracts) ) ) contract-err )
    (ok true)
  )
)





;; defining current staking addresses
(define-data-var stake-cycle-id uint u0)

(define-data-var current-stake-cycle-id uint u1)
(define-data-var next-stake-cycle-id uint u2)

(define-map stake-cycle uint {
  start-block-height: uint,
  end-block-height: uint,
  stacks-ctx-percentage: uint,
  open-registration: bool,
  released: bool,
  total-staked: uint,
  addresses: (list 1000 principal)
})

;; CREATE CYCLE
(define-public (create-stake-cycle (start-block uint) (end-block uint) (percentage uint) )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (map-insert stake-cycle (+ (var-get stake-cycle-id) u1) {
        start-block-height: start-block,
        end-block-height: end-block,
        stacks-ctx-percentage: percentage,
        open-registration: false,
        released: false,
        total-staked: u0,
        addresses: (list)
      })
    (var-set stake-cycle-id (+ (var-get stake-cycle-id) u1))
    (ok (var-get stake-cycle-id))
  )
)

;; EDIT CYCLE
(define-public (update-stake-cycle 
    (stake-cycle-id-to-edit uint) 
    (start-block uint) 
    (end-block uint) 
    (percentage uint) 
    (open-registration bool) 
  )
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (map-set stake-cycle stake-cycle-id-to-edit 
      (merge 
        (unwrap-panic (map-get? stake-cycle stake-cycle-id-to-edit))
        {
          start-block-height: start-block,
          end-block-height: end-block,
          stacks-ctx-percentage: percentage,
          open-registration: open-registration
        }
      )
    )
    (ok (var-get stake-cycle-id))
  )
)

;; init contract
(define-private (init)
  (if (var-get cycle-auto-build)
    (begin
      (and 
        (and 
          (is-ok (create-stake-cycle 
            (+ block-height (var-get start-block-till-deploy)) 
            (+ (+ block-height (var-get start-block-till-deploy)) (var-get cycle-length))
            (var-get cycle-percentage)
          ))
          (is-ok (update-stake-cycle
            u1 
            (+ block-height (var-get start-block-till-deploy)) 
            (+ (+ block-height (var-get start-block-till-deploy)) (var-get cycle-length))
            (var-get cycle-percentage)
            true
          ))
        )
        (is-ok (create-stake-cycle 
          (+ (+ (+ block-height (var-get start-block-till-deploy)) (var-get cycle-length)) (var-get cycle-interval))
          (+ (+ (+ (+ block-height (var-get start-block-till-deploy)) (var-get cycle-length)) (var-get cycle-interval)) (var-get cycle-length))
          (var-get cycle-percentage)
        ))
      )
    )
    true
  )
)

(init)

;; for each address set staking status transfered

;; set multiple cycles stake



;; single reference stake status
(define-map address-delegate principal {
  amount: uint,
  cycles-number: uint,
  done-cycles: uint
})
;; pos reserved for next cycle
(define-data-var reserved-delegated-for-next uint u0)
(define-map reserved-positions-map uint uint)

;; partecipate in staking delegating token
(define-public (delegate-token (start-cycle-id uint) (cycles-number uint) (amount uint) )
  (let (
    (current-staking-cycle (unwrap-panic (map-get? stake-cycle start-cycle-id) ) )
    (reserved-pos (default-to u0 (map-get? reserved-positions-map start-cycle-id) ))
    (reserved-pos-next (default-to u0 (map-get? reserved-positions-map (+ start-cycle-id u1)) ))
  )
    (asserts! (is-eq true (get open-registration current-staking-cycle) ) stake-cycle-closed)
    (asserts! (< block-height (get start-block-height current-staking-cycle)) stake-cycle-closed)
    (asserts! (< (+ (len (get addresses current-staking-cycle)) reserved-pos) u1000 ) stake-cycle-closed)
    (asserts! (is-none (map-get? address-delegate tx-sender)) sender-just-staking-for-cycle)
    
    (asserts! (map-set address-delegate tx-sender {
      amount: amount, 
      cycles-number: cycles-number,
      done-cycles: u0
    }) error-setting-map-delegate)
    
    (if 
      (> cycles-number u1)
      (map-set reserved-positions-map (+ start-cycle-id u1) (+ reserved-pos-next u1) )
      true
    )
    (asserts! (map-set stake-cycle 
              start-cycle-id 
              (merge current-staking-cycle 
                {
                  addresses: (unwrap-panic (as-max-len? (append (get addresses current-staking-cycle) tx-sender) u1000) ),
                  total-staked: (+ (get total-staked current-staking-cycle) amount)
                }
              ) ) (err u1) )
    (asserts! (is-ok (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken transfer amount tx-sender (as-contract tx-sender) none ) ) (err u0))
    (ok (map-get? address-delegate tx-sender ))
  )
)



;; map for end-cycle
;; assign earned stx
;; if has multiple earning continue and assign to next
;; instead release data-map
(define-data-var total-amount-to-assign uint u0)
(define-private (assign-stx-to-address (address principal))
  (let (
    (total-amount (var-get total-amount-to-assign))
    (current-cycle (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id))))
    (next-cycle (unwrap-panic (map-get? stake-cycle (var-get next-stake-cycle-id))))
    (address-delegate-map (unwrap-panic (map-get? address-delegate address)) )
    (has-to-end-staking (is-eq (- (get cycles-number address-delegate-map) (get done-cycles address-delegate-map) ) u1) )
    (stx-amount (/
        total-amount
        (/ (get total-staked current-cycle) (get amount address-delegate-map))
      ))
  )
    (asserts! (is-ok (as-contract (stx-transfer? stx-amount (as-contract tx-sender) address ) ) ) no-stx-transfers )
    (if 
      has-to-end-staking
      (asserts! (if 
        (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken transfer (get amount address-delegate-map) (as-contract tx-sender) address none ) ) )
        (map-delete address-delegate address)
        false
      ) error-ending-stake)
      (begin
        (asserts! 
          (map-set stake-cycle 
            (var-get next-stake-cycle-id) 
            (merge next-cycle
              {
                addresses: (unwrap-panic (as-max-len? (append (get addresses next-cycle) address) u1000) ),
                total-staked: (+ (get total-staked next-cycle) (get amount address-delegate-map) )
              }
          ) ) error-continuing-stake)
        (asserts! 
          (map-set address-delegate 
            address 
            (merge address-delegate-map
              {
                done-cycles: (+ (get done-cycles address-delegate-map) u1),
              }
          ) ) error-continuing-stake)
        (asserts! 
          (map-set reserved-positions-map 
            (+ (var-get next-stake-cycle-id) u1) 
            (+  
              (default-to u0 (map-get? reserved-positions-map (+ (var-get next-stake-cycle-id) u1)) )
            u1) 
          )
         error-continuing-stake)
      )
    )
    (ok address)
  )
)


;; OPEN THE CURRENT CYCLE AFTER OLD END
(define-private (auto-open-cycle )
  (let (
      (next-cycle (map-get? stake-cycle (+ (var-get current-stake-cycle-id) u1) ))
      (next-next-cycle (map-get? stake-cycle (+ (var-get current-stake-cycle-id) u2) ))
      (current-cycle (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id))))
    )
    (begin
      (
        if 
        (is-none next-next-cycle)
        (begin 
          (and (is-ok (create-stake-cycle 
              (+ (+ (+ (get end-block-height current-cycle) (var-get cycle-interval)) (var-get cycle-length)) (var-get cycle-interval)) 
              (+ (+ (+ (+ (get end-block-height current-cycle) (var-get cycle-interval)) (var-get cycle-length)) (var-get cycle-interval)) (var-get cycle-length))
              (var-get cycle-percentage)
            ))
            (is-ok (update-stake-cycle
              (+ (var-get current-stake-cycle-id) u2) 
              (+ (+ (+ (get end-block-height current-cycle) (var-get cycle-interval)) (var-get cycle-length)) (var-get cycle-interval)) 
              (+ (+ (+ (+ (get end-block-height current-cycle) (var-get cycle-interval)) (var-get cycle-length)) (var-get cycle-interval)) (var-get cycle-length))
              (var-get cycle-percentage)
              true
            ))
          )
        )
        true
      )
      (
      if 
        (is-none next-cycle)
        (begin 
          (and (is-ok (create-stake-cycle 
              (+ (get end-block-height current-cycle) (var-get cycle-interval)) 
              (+ (+ (get end-block-height current-cycle) (var-get cycle-interval)) (var-get cycle-length))
              (var-get cycle-percentage)
            ))
            (is-ok (update-stake-cycle
              (+ (var-get current-stake-cycle-id) u1) 
              (+ (get end-block-height current-cycle) (var-get cycle-interval)) 
              (+ (+ (get end-block-height current-cycle) (var-get cycle-interval)) (var-get cycle-length))
              (var-get cycle-percentage)
              true
            ))
          )
        )
        (map-set stake-cycle (+ (var-get current-stake-cycle-id) u1) 
          (merge (unwrap-panic (map-get? stake-cycle (+ (var-get current-stake-cycle-id) u1) ))
            {
              open-registration: true  
            }
          )
        )
      )
    )
  )
)

;; release stx at the end of a cycle
(define-public (end-current-cycle)
  (begin
    (asserts! (< (get end-block-height (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id)) )) block-height) stake-cycle-open)
    (asserts! (auto-open-cycle) error-opening-cycle)
    ;; if autoopen make a new cycle
    (if (var-get cycle-auto-build)
      (auto-open-cycle)
      true
    )
    (var-set total-amount-to-assign (get-current-cycle-amount))
    (map assign-stx-to-address (get addresses (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id)) ) ))
    (map-set stake-cycle (var-get current-stake-cycle-id) (merge 
      (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id)) ) 
      {released: true})
    )
    (var-set current-stake-cycle-id (+ (var-get current-stake-cycle-id) u1 ))
    (var-set next-stake-cycle-id (+ (var-get next-stake-cycle-id) u1 ))

    
    (ok true)
  )
)



;; REMOVE STAKING ADDRESSES AND GIVE BACK ROMA WITH OR WITHOUT STACKS
(define-data-var current-removing-address-from-cycle principal tx-sender)
(define-private (filter-remove-from-cycle (address principal))
  (not (is-eq (var-get current-removing-address-from-cycle) address))
)
(define-private (force-unstake-address-with-stx (address principal))
  (let (
    (total-amount (get-current-cycle-amount))
    (current-cycle (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id))))
    (address-delegate-map (unwrap-panic (map-get? address-delegate address)) )
    (stx-amount (/
        total-amount
        (/ (get total-staked current-cycle) (get amount address-delegate-map))
      ))
  )
    (asserts! (is-ok (as-contract (stx-transfer? stx-amount (as-contract tx-sender) address ) ) ) no-stx-transfers )
    (asserts! (if 
      (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken transfer (get amount address-delegate-map) (as-contract tx-sender) address none ) ) )
      (map-delete address-delegate address)
      false
    ) error-ending-stake)
    (asserts! (var-set current-removing-address-from-cycle address) error-ending-stake)
    (map-set stake-cycle (var-get current-stake-cycle-id) (merge current-cycle
        {
          addresses: (filter filter-remove-from-cycle (get addresses current-cycle) ),
          total-staked: (- (get total-staked current-cycle) (get amount address-delegate-map) )
        }
      ))
    (ok address)
  )
)
(define-private (force-unstake-address-without-stx (address principal))
  (let (
    (total-amount (get-current-cycle-amount))
    (current-cycle (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id))))
    (address-delegate-map (unwrap-panic (map-get? address-delegate address)) )
  )
    (asserts! (if 
      (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken transfer (get amount address-delegate-map) (as-contract tx-sender) address none ) ) )
      (map-delete address-delegate address)
      false
    ) error-ending-stake)
    (if 
      ;; has reserved positions
      (> (get cycles-number address-delegate-map) (+ (get done-cycles address-delegate-map) u1) )
      (map-set reserved-positions-map (+ (var-get current-stake-cycle-id) u1) (- (default-to u1 (map-get? reserved-positions-map (+ (var-get current-stake-cycle-id) u1) ) ) u1) )
      true
    )
    (asserts! (var-set current-removing-address-from-cycle address) error-ending-stake)
    (map-set stake-cycle (var-get current-stake-cycle-id) (merge current-cycle
        {
          addresses: (filter filter-remove-from-cycle (get addresses current-cycle) ),
          total-staked: (- (get total-staked current-cycle) (get amount address-delegate-map) )
        }
      ))

    (ok address)
  )
)
;; REMOVE ADDRESS FROM STAKING
;; ADMIN CAN REMOVE ADDRESSES FROM STAKING FOR SECURITY REASONS
(define-public (free-address-staking (address principal) (with-stacks bool))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (asserts! (is-ok (if 
      with-stacks
      (force-unstake-address-with-stx address)
      (force-unstake-address-without-stx address)
    )) error-closing-staking)
    (ok u0)
  )
)

;; FOR SECURITY FUNCTIONS GIVE ROMA
(define-public (transfer-token (amount uint) (address principal))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (is-ok (as-contract (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken transfer amount (as-contract tx-sender) address none ) ) )
    (ok u0)
  )
)




;; STOP AUTO RENEW FROM STAKING CYCLE
;; FOR HOLDERS
(define-public (stop-staking-till-next (address-stopping principal))
  (let (
      (address-delegated (unwrap-panic (map-get? address-delegate address-stopping ) ) )
    )
    (asserts! (or 
        (is-eq address-stopping tx-sender)
        (is-administrative tx-sender)
      ) permission-denied-err )
    (asserts! (
      map-set address-delegate address-stopping (merge address-delegated {
        cycles-number: (+ (get done-cycles address-delegated) u1)
      })
    ) error-setting-last-cycle)
    (ok (unwrap-panic (map-get? address-delegate address-stopping ) ))
  )
)
;; view if address can undelegate
(define-read-only (can-undelegate (address principal))
  (let (
      (address-delegated (map-get? address-delegate address ) )
    )
    (asserts! (not (is-none address-delegated)) (err u404))
    (asserts! (and 
        (is-eq (get done-cycles (unwrap-panic address-delegated) ) u0)
        (> (get start-block-height (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id) )) ) block-height)
      ) permission-denied-err )
    (ok u1)
  )
)
;; undelegate token before cycle launch
(define-public (undelegate (address principal))
  (let (
      (address-delegated (unwrap-panic (map-get? address-delegate address ) ) )
    )
    (asserts! (or 
        (is-eq address tx-sender)
        (is-administrative tx-sender)
      ) permission-denied-err )
    (asserts! (is-ok (can-undelegate address)) permission-denied-err )
    (asserts! (is-ok (force-unstake-address-without-stx address) ) (err u422))
    (ok u1)
  )
)



;; GET CURRENT STAKING STX TOTAL AMOUNT
(define-private (get-current-cycle-amount)
  (begin
    (*
      (/
        (stx-get-balance (as-contract tx-sender))
        u100 
      ) 
      ( get stacks-ctx-percentage (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id))))
    )
  )
)

;; RETURN IF WE HAVE TO CLOSE CYCLE
(define-read-only (is-to-close-cycle)
    (ok (< (get end-block-height (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id)))) block-height))
  )

;; get current block height
(define-read-only (get-net-current-height)
    (ok block-height)
  )

;; get current stx amount for the cycle
(define-read-only (get-extimated-current-total-gain)
  (ok (get-current-cycle-amount))
)

;; current staking status by id
(define-read-only (get-staking-status (staking-id uint))
  (let (
      (stake (unwrap-panic (map-get? stake-cycle staking-id )))
    )
    (ok {
      start-block-height: (get start-block-height stake),
      end-block-height: (get end-block-height stake),
      stacks-ctx-percentage: (get stacks-ctx-percentage stake),
      open-registration: (get open-registration stake),
      released: (get released stake),
      total-staked: (get total-staked stake),
      addresses: (len (get addresses stake) )
    })
  )
)

;; address staking info
(define-read-only (is-staking-address (address principal))
  (let (
      (current-stake (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id) )))
    )
    (ok {
      is-staking: (not (is-none (index-of (get addresses current-stake) address))),
      staking-data: (map-get? address-delegate address)
    })
  )
)

;; if an address can delegate
(define-read-only (can-delegate (address principal))
  (
    ok (and 
      (and
        (is-none (index-of (get addresses (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id) ))) address))
        (and 
          (is-eq true (get open-registration (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id)) )) )
          (< block-height (get start-block-height (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id)) )))
        )
      )
      (< (+ (len (get addresses (unwrap-panic (map-get? stake-cycle (var-get current-stake-cycle-id) )))) (default-to u0 (map-get? reserved-positions-map (var-get current-stake-cycle-id)) ) ) u1000 )
    )
  )
)

;; staking cycles avaible with max id added, current and next
(define-read-only (ctx-cycles-ids)
    (ok {
      stake-cycle-id: (var-get stake-cycle-id),
      current-stake-cycle-id: (var-get current-stake-cycle-id),
      next-stake-cycle-id: (var-get next-stake-cycle-id)
    })
  )

;; loop into staking addresses list
(define-private (map-list-and-go-on (address principal) (context {
      current-index: uint,
      start: uint,
      end: uint,
      addresses: (list 1000 {address: principal, amount: uint})
    }) )
    (if 
      (or
        (or 
          (< (get current-index context) (get start context) )
          (> (get current-index context) (get end context) )
        )
        (is-none (map-get? address-delegate address))
      )
      (merge context {current-index: (+ (get current-index context) u1)})
      (merge context {
          current-index: (+ (get current-index context) u1),
          addresses: (unwrap-panic (as-max-len? (append (get addresses context) {
              address: address,
              amount: (get amount (unwrap-panic (map-get? address-delegate address) ) )
            }) u1000) )
        })
    )
)

;; get paginated list of staking addresses
(define-read-only (get-staking-addresses (staking-id uint) (address-num uint) (address-start uint))
  (let (
      (stake (unwrap-panic (map-get? stake-cycle staking-id )))
    )
    (ok (fold map-list-and-go-on (get addresses stake) {
      current-index: u0,
      start: address-start,
      end: (- (+ address-start address-num) u1),
      addresses: (list)
    }) )
  )
)


(define-public (fund (amount uint))
  (ok (stx-transfer? amount tx-sender (as-contract tx-sender) ) )
  )


(define-public (address-balance (address principal))
  (ok {
      stx: (stx-get-balance address),
      token: (unwrap-panic (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken get-balance address ))
    } )
  )

(define-read-only (get-contract-info)
  (ok 
    {
      start-block-till-deploy: (var-get start-block-till-deploy),
      cycle-interval: (var-get cycle-interval),
      cycle-length: (var-get cycle-length),
      cycle-percentage: (var-get cycle-percentage),
      cycle-auto-build: (var-get cycle-auto-build)
    }
  )
)


(define-public (set-start-block-till-deploy (value uint))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (var-set start-block-till-deploy value))
  )
)
(define-public (set-cycle-interval (value uint))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (var-set cycle-interval value))
  )
)
(define-public (set-cycle-length (value uint))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (var-set cycle-length value))
  )
)
(define-public (set-cycle-percentage (value uint))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (var-set cycle-percentage value))
  )
)
(define-public (set-cycle-auto-build (value bool))
  (begin
    (asserts! (is-administrative tx-sender) permission-denied-err)
    (ok (var-set cycle-auto-build value))
  )
)


(define-read-only (get-contract-user-info (address principal))
  (let (
      (current-stake (map-get? stake-cycle (var-get current-stake-cycle-id) ))
      (next-stake (map-get? stake-cycle (var-get current-stake-cycle-id) ))
    )
    (ok 
        {
          start-block-till-deploy: (var-get start-block-till-deploy),
          cycle-interval: (var-get cycle-interval),
          cycle-length: (var-get cycle-length),
          cycle-percentage: (var-get cycle-percentage),
          cycle-auto-build: (var-get cycle-auto-build),
          stx-balance: (stx-get-balance address),
          token-balance: (contract-call? 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken get-balance address ),
          stake-cycle-id: (var-get stake-cycle-id),
          current-stake-cycle-id: (var-get current-stake-cycle-id),
          next-stake-cycle-id: (var-get next-stake-cycle-id),
          current-cycle: (if 
              (not (is-none current-stake))
              {
                start-block-height: (get start-block-height (unwrap-panic current-stake)),
                end-block-height: (get end-block-height (unwrap-panic current-stake)),
                stacks-ctx-percentage: (get stacks-ctx-percentage (unwrap-panic current-stake)),
                open-registration: (get open-registration (unwrap-panic current-stake)),
                released: (get released (unwrap-panic current-stake)),
                total-staked: (get total-staked (unwrap-panic current-stake)),
                addresses: (len (get addresses (unwrap-panic current-stake)) )
              }
              {
                start-block-height: u0,
                end-block-height: u0,
                stacks-ctx-percentage: u0,
                open-registration: false,
                released: false,
                total-staked: u0,
                addresses: u0
              }
          ),
          next-cycle: (if 
              (not (is-none next-stake))
              {
                start-block-height: (get start-block-height (unwrap-panic next-stake)),
                end-block-height: (get end-block-height (unwrap-panic next-stake)),
                stacks-ctx-percentage: (get stacks-ctx-percentage (unwrap-panic next-stake)),
                open-registration: (get open-registration (unwrap-panic next-stake)),
                released: (get released (unwrap-panic next-stake)),
                total-staked: (get total-staked (unwrap-panic next-stake)),
                addresses: (len (get addresses (unwrap-panic next-stake)) )
              }
              {
                start-block-height: u0,
                end-block-height: u0,
                stacks-ctx-percentage: u0,
                open-registration: false,
                released: false,
                total-staked: u0,
                addresses: u0
              }
          ),
          current-block-height: block-height,
          is-staking: (if 
              (not (is-none current-stake))
              (not (is-none (index-of (get addresses (unwrap-panic current-stake) ) address)))
              false
          ),
          staking-data: (map-get? address-delegate address),
          is-admin: (is-administrative address),
          can-delegate: (is-ok (can-delegate address)),
          can-undelegate: (is-ok (can-undelegate address))
        }
      )
  )
)