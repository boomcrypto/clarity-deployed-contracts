;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (try! (contract-call? .lydian-token set-token-uri u"https://www.lydian.xyz/metadata/ldn-token.json"))

    (try! (contract-call? .staked-lydian-token set-token-uri u"https://www.lydian.xyz/metadata/sldn-token.json"))

    (try! (contract-call? .wrapped-lydian-token set-token-uri u"https://www.lydian.xyz/metadata/wldn-token.json"))

    (ok true)
  )
)