(define-constant ERR_NOT_INVESTER u1001)
(define-constant ERR_NOT_AUTHORIZED u1002)

(define-constant EVENT_START u44460)
(define-constant LOCKUP_BLOCK_1 u44550)
(define-constant LOCKUP_BLOCK_2 u44650)

(define-data-var contract-owner principal tx-sender)

(define-map investers
  principal
  {
    stsw_reward : uint,
    event1_1_claimed : bool,
    event1_2_claimed : bool,
    event1_3_claimed : bool
  }
)

(define-read-only (get-user-rewards (user principal))
  (map-get? investers user)
)

(define-public (claim-reward)
  (let (
      (user_data (unwrap! (map-get? investers tx-sender) (err ERR_NOT_INVESTER)))
      (user tx-sender)
    )
    (if (and (not (get event1_1_claimed user_data)) (< EVENT_START block-height ))
      (begin 
        (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer (get stsw_reward user_data) tx-sender user none)))
        (map-set investers user (merge user_data {event1_1_claimed : true}))
      )
      false
    )
    (if (and (not (get event1_2_claimed user_data)) (< LOCKUP_BLOCK_1 block-height ))
      (begin 
        (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer (get stsw_reward user_data) tx-sender user none)))
        (map-set investers user (merge (unwrap-panic (map-get? investers tx-sender)) {event1_2_claimed : true}))
      )
      false
    )
    (if (and (not (get event1_3_claimed user_data)) (< LOCKUP_BLOCK_2 block-height ))
      (begin 
        (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer (get stsw_reward user_data) tx-sender user none)))
        (map-set investers user (merge (unwrap-panic (map-get? investers tx-sender)) {event1_3_claimed : true}))
      )
      false
    )
    (ok true)
  )
)

(define-public (emergency-withdraw)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_NOT_AUTHORIZED))
    (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance (as-contract tx-sender))) tx-sender (var-get contract-owner) none))
  )
)

(try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer (* u5000000 u3) tx-sender (as-contract tx-sender) none))

(begin
  (map-set investers
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275    {
      stsw_reward : u1000000,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPDP8YK19CE3G3J2PGCRWXK770VQC8P5GC341JZM    {
      stsw_reward : u1000000,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SPDVAGX3EGETB7BJ6737FRS4DTNXC7CVSNFK7TSR    {
      stsw_reward : u1000000,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP1C4RQ1BH04EWQZFFBN4NTFPN9T5FKG6ZSGCHFYS    {
      stsw_reward : u1000000,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
  (map-set investers
    'SP2HB7FPDGKB2AZW0XCH1WDEATDXFNQBN2CYMC3JB    {
      stsw_reward : u1000000,
      event1_1_claimed : false,
      event1_2_claimed : false,
      event1_3_claimed : false
    }
  )
)