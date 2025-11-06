(define-map consultation-records
  {
    id-patient: (string-ascii 36),
    created-at: (string-ascii 64) ;; allow up to 64 chars
  }
  {
    hash: (buff 64)
  }
)

(define-public (store-consultation-record
    (id-patient (string-ascii 36))
    (created-at (string-ascii 64))  ;; increased limit
    (hash (buff 64)))
  (begin
    (map-insert consultation-records
      {
        id-patient: id-patient,
        created-at: created-at
      }
      {
        hash: hash
      }
    )
    (ok true)
  )
)

(define-read-only (get-consultation-record
    (id-patient (string-ascii 36))
    (created-at (string-ascii 64)))  ;; match updated size
  (match (map-get? consultation-records {
    id-patient: id-patient,
    created-at: created-at
  })
    entry (ok (get hash entry))
    (err u404)
  )
)

;; Map for clinical records (one active per patient)
(define-map clinical-records
  {
    id-patient: (string-ascii 36)
  }
  {
    hash: (buff 64),
    created-at: (string-ascii 64)
  }
)

;; Store or update the active clinical record for a patient
(define-public (store-clinical-record
    (id-patient (string-ascii 36))
    (created-at (string-ascii 64))
    (hash (buff 64)))
  (begin
    (map-set clinical-records
      { id-patient: id-patient }
      {
        hash: hash,
        created-at: created-at
      }
    )
    (ok true)
  )
)

;; Get the current active clinical record for a patient
(define-read-only (get-clinical-record
    (id-patient (string-ascii 36)))
  (match (map-get? clinical-records { id-patient: id-patient })
    entry (ok entry)   ;; returns both hash and created-at
    (err u404)
  )
)
