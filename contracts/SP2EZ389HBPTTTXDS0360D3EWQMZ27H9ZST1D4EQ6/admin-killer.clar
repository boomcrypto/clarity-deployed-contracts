;; Admin Killer Contract
;; Constants
(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_ALREADY_SET (err u1002))
(define-constant ERR-FAILED-KILL (err u1003))

(define-constant CANT-BE-EVIL 'SP000000000000000000002Q6VF78)

;; Variables
(define-data-var evil-killer principal tx-sender)

;; Function to remove the current admin from the Pepe contract
(define-public (integrate-the-evil (sin uint) (beelzebub principal))
  (begin
    (asserts! (is-eq tx-sender (var-get evil-killer)) (err ERR_NOT_AUTHORIZED))
    (if (not (is-eq (var-get evil-killer) CANT-BE-EVIL))
            (match (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz remove-principal-from-role sin beelzebub) ;; u0 is the sin of it all and that's why we're alive
        success (ok true)
        error (err ERR-FAILED-KILL))
      (err ERR_NOT_AUTHORIZED)
    )
  )
)

;; Function to transfer ownership of this contract to the can't-be-evil address
(define-public (ascend-saint)
  (begin
    (asserts! (is-eq tx-sender (var-get evil-killer)) (err ERR_NOT_AUTHORIZED))
    (ok (var-set evil-killer CANT-BE-EVIL))
  )
)

;; Read the $aint
(define-read-only (get-evil-killer)
  (ok (var-get evil-killer))
)
(print "The line separating good and evil passes not through states, nor between classes, nor between political parties either - but right through every human heart.")