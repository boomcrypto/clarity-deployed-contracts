;; On-chain first-is-first inscription text indexer
;; By https://stacksinscription.com

(define-constant REWARD_MICRO_STX_UINT u1000)
(define-constant LIST_10 (list u0 u0 u0 u0 u0 u0 u0 u0 u0 u0))
(define-constant LIST_20 (concat LIST_10 LIST_10))
(define-constant LIST_50 (concat (concat LIST_20 LIST_20) LIST_10))
(define-constant LIST_100 (concat LIST_50 LIST_50))
(define-constant LIST_200 (concat LIST_100 LIST_100))
(define-constant LIST_400 (concat LIST_200 LIST_200))

(define-data-var m_last_synced_token_id uint u0)

(define-map map_note
  (buff 128)  ;; text
  uint        ;; first occur token_id
)

;; Search token id by text.
;; @dev bufferCV(new TextEncoder().encode(content))
(define-read-only (find_token_id (text (buff 128)))
  (map-get? map_note text)
)

(define-read-only (find_token_ids (text_list (list 28 (buff 128))))
  (map find_token_id text_list)
)

(define-read-only (find_owner (text (buff 128)))
  (match (map-get? map_note text) token_id
    (unwrap-panic (contract-call? .inscription get-owner token_id))
    none
  )
)

(define-read-only (find_owners (text_list (list 28 (buff 128))))
  (map find_owner text_list)
)

(define-read-only (find_token_id_and_owner (text (buff 128)))
  (match (map-get? map_note text) token_id
    {
      token_id: token_id,
      owner: (unwrap-panic (contract-call? .inscription get-owner token_id))
    }
    {
      token_id: u0,
      owner: none
    }
  )
)

(define-read-only (find_token_ids_and_owners (text_list (list 14 (buff 128))))
  (map find_token_id_and_owner text_list)
)

(define-read-only (get_last_synced_token_id)
  (var-get m_last_synced_token_id)
)

(define-read-only (get_summary)
  {
    last_synced_token_id: (var-get m_last_synced_token_id),
    latest_token_id: (unwrap-panic (contract-call? .inscription get-last-token-id)),
    balance: (stx-get-balance (as-contract tx-sender)),
  }
)

(define-public (drive)
  (let
    (
      (sender tx-sender)
      (start_token_id (var-get m_last_synced_token_id))
      (end_token_id (iter_drive u0 (var-get m_last_synced_token_id)))
      (need_reward_stx (if (> end_token_id start_token_id) REWARD_MICRO_STX_UINT u0))
      (balance (stx-get-balance (as-contract tx-sender)))
      (real_reward_stx (if (>= balance need_reward_stx) need_reward_stx balance))
    )
    (var-set m_last_synced_token_id end_token_id)
    (and (> real_reward_stx u0) (try! (as-contract (stx-transfer? real_reward_stx tx-sender sender))))
    (ok (print {
      type: "drive",
      start_token_id: start_token_id,
      end_token_id: end_token_id,
      reward_stx: real_reward_stx,
    }))
  )
)

(define-public (drive_50)
  (let
    (
      (sender tx-sender)
      (start_token_id (var-get m_last_synced_token_id))
      (end_token_id (fold iter_drive LIST_50 (var-get m_last_synced_token_id)))
      (need_reward_stx (* (- end_token_id start_token_id) REWARD_MICRO_STX_UINT))
      (balance (stx-get-balance (as-contract tx-sender)))
      (real_reward_stx (if (>= balance need_reward_stx) need_reward_stx balance))
    )
    (var-set m_last_synced_token_id end_token_id)
    (and (> real_reward_stx u0) (try! (as-contract (stx-transfer? real_reward_stx tx-sender sender))))
    (ok (print {
      type: "drive_50",
      start_token_id: start_token_id,
      end_token_id: end_token_id,
      reward_stx: real_reward_stx,
    }))
  )
)

(define-public (drive_100)
  (let
    (
      (sender tx-sender)
      (start_token_id (var-get m_last_synced_token_id))
      (end_token_id (fold iter_drive LIST_100 (var-get m_last_synced_token_id)))
      (need_reward_stx (* (- end_token_id start_token_id) REWARD_MICRO_STX_UINT))
      (balance (stx-get-balance (as-contract tx-sender)))
      (real_reward_stx (if (>= balance need_reward_stx) need_reward_stx balance))
    )
    (var-set m_last_synced_token_id end_token_id)
    (and (> real_reward_stx u0) (try! (as-contract (stx-transfer? real_reward_stx tx-sender sender))))
    (ok (print {
      type: "drive_100",
      start_token_id: start_token_id,
      end_token_id: end_token_id,
      reward_stx: real_reward_stx,
    }))
  )
)

(define-public (drive_200)
  (let
    (
      (sender tx-sender)
      (start_token_id (var-get m_last_synced_token_id))
      (end_token_id (fold iter_drive LIST_200 (var-get m_last_synced_token_id)))
      (need_reward_stx (* (- end_token_id start_token_id) REWARD_MICRO_STX_UINT))
      (balance (stx-get-balance (as-contract tx-sender)))
      (real_reward_stx (if (>= balance need_reward_stx) need_reward_stx balance))
    )
    (var-set m_last_synced_token_id end_token_id)
    (and (> real_reward_stx u0) (try! (as-contract (stx-transfer? real_reward_stx tx-sender sender))))
    (ok (print {
      type: "drive_200",
      start_token_id: start_token_id,
      end_token_id: end_token_id,
      reward_stx: real_reward_stx,
    }))
  )
)

(define-public (drive_400)
  (let
    (
      (sender tx-sender)
      (start_token_id (var-get m_last_synced_token_id))
      (end_token_id (fold iter_drive LIST_400 (var-get m_last_synced_token_id)))
      (need_reward_stx (* (- end_token_id start_token_id) REWARD_MICRO_STX_UINT))
      (balance (stx-get-balance (as-contract tx-sender)))
      (real_reward_stx (if (>= balance need_reward_stx) need_reward_stx balance))
    )
    (var-set m_last_synced_token_id end_token_id)
    (and (> real_reward_stx u0) (try! (as-contract (stx-transfer? real_reward_stx tx-sender sender))))
    (ok (print {
      type: "drive",
      start_token_id: start_token_id,
      end_token_id: end_token_id,
      reward_stx: real_reward_stx,
    }))
  )
)

(define-private (iter_drive (unused uint) (token_id uint))
  (match (contract-call? .inscription get_inscription (+ token_id u1)) insc_data
    (if (is-eq (get type insc_data) "text")
      (match (as-max-len? (get payload insc_data) u128) trim_payload
        (begin
          (and (is-none (map-get? map_note trim_payload)) (map-set map_note trim_payload (+ token_id u1)))
          (+ token_id u1)
        )
        (+ token_id u1)
      )
      (+ token_id u1)
    )
    token_id
  )
)

(define-public (donate (amount uint))
  (stx-transfer? amount tx-sender (as-contract tx-sender))
)
