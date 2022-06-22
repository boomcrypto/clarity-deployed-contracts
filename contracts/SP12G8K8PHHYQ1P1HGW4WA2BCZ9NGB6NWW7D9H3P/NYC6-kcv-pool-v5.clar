;; pool for kcvdao v5. (220316)

;; Constant values
(define-constant CONTRACT-OWNER tx-sender)
(define-constant BURN-ADDRESS 'SP15VRJX29FKDQDYSWPFJV315AZ5A0FGNJ9YCT5GA)
(define-constant ERR-BAD-REQUESTED (err u400))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-FORBIDDEN (err u403))
(define-constant MAX-MEMBER-NUM u200)
(define-constant LIST-200 (list
    u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20
    u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40
    u41 u42 u23 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60
    u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80
    u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100
    u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120
    u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140
    u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153 u154 u155 u156 u157 u158 u159 u160
    u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180
    u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200
))

;; Store the last issues token ID
(define-data-var pool-open bool false)
(define-data-var pool-max-amount uint u10000000000) ;; default MAX: 10,000 STX
(define-data-var pool-balance uint u0)
(define-data-var mined-token uint u0)
(define-data-var last-id uint u0)
(define-data-var pool-fee uint u10) ;; default: fee is set as 1.0%
(define-data-var cycle-done bool false)
(define-data-var fee-wallet principal tx-sender) ;; default principal
(define-data-var op-wallet principal tx-sender) ;; default principal
(define-map pool-member uint {member-wallet: principal, member-deposit: uint, time-requested: uint})
(define-map pool-member-id principal uint)

;; read-only functions for operation
(define-read-only (get-fee-wallet)
  (var-get fee-wallet))

(define-read-only (get-op-wallet)
  (var-get op-wallet))

(define-read-only (get-pool-open)
  (var-get pool-open))

(define-read-only (get-pool-max-amount)
  (var-get pool-max-amount))

(define-read-only (get-pool-fee)
  (var-get pool-fee))

(define-read-only (get-total-members)
  (var-get last-id))

(define-read-only (get-current-pool-balance)
  (var-get pool-balance))

(define-read-only (get-member-stat (target-id uint))
  (default-to {member-wallet: CONTRACT-OWNER, member-deposit: u0, time-requested: u1557860301} (map-get? pool-member target-id)))

;; operation functions for admin
(define-public (set-pool-open (flag bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set pool-open flag)
    (ok true)))

(define-public (initialize (target-op-wallet principal) (target-fee-wallet principal) (target-pool-fee uint) (target-pool-max uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set op-wallet target-op-wallet)
    (var-set fee-wallet target-fee-wallet)
    (var-set pool-fee target-pool-fee)
    (var-set pool-max-amount target-pool-max)
    (var-set pool-open true)  ;; default: pool-open becomes true when init begins
    (ok true)))

(define-public (set-mining-done (totalMinedToken uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set mined-token totalMinedToken)
    (var-set cycle-done true)
    (ok true)))

;; Only func needed to be called by user
(define-public (send-pool-stx (send-amount uint) (send-time uint))
  (begin
    (let ((target-pool-fee (/ (* send-amount (var-get pool-fee) ) u1000))
        (target-target-deposit (- send-amount target-pool-fee))
        (tmp-pool-balance (+ send-amount (var-get pool-balance)))
        (next-id (+ u1 (var-get last-id))))
        (asserts! (>= MAX-MEMBER-NUM next-id) ERR-FORBIDDEN)                        ;; Maximum number of members is 200
        (asserts! (is-eq (var-get pool-open) true) ERR-FORBIDDEN)                   ;; accepts only pool is open
        (asserts! (>= (var-get pool-max-amount) tmp-pool-balance) ERR-FORBIDDEN)    ;; Capped by Pool Max balance
        (asserts! (>= send-amount u1000000) ERR-BAD-REQUESTED)                      ;; 1 STX or higher is accepted
        (try! (stx-transfer? target-target-deposit tx-sender (var-get op-wallet)))
        (try! (stx-transfer? target-pool-fee tx-sender (var-get fee-wallet)))
        (map-set pool-member next-id {member-wallet: tx-sender, member-deposit: send-amount, time-requested: send-time })
        (map-set pool-member-id tx-sender next-id)
        (var-set pool-balance tmp-pool-balance)
        (var-set last-id next-id)
        (ok true))))

;; In case of reseting the whole pool (i.e. re-start the cycle..)
(define-public (reset-pool)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (var-get cycle-done) true) ERR-FORBIDDEN)    ;; Only possible when the cycle is done
        (fold remove-member-map LIST-200 true)
        (var-set pool-balance u0)
        (var-set last-id u0)
        (var-set cycle-done false)
        (var-set mined-token u0)
        (ok true)))

(define-private (remove-member-map (target-id uint) (tmpBool bool))
  (let
    ((tmp-member-wallet (default-to BURN-ADDRESS (get member-wallet (map-get? pool-member target-id)))))
    (map-delete pool-member target-id)
    (map-delete pool-member-id tmp-member-wallet)))

;; Token trafer trait
(define-trait sip010-transferable-trait
	((transfer (uint principal principal (optional (buff 34))) (response bool uint))))

;; Batch Token Payout
(define-public (token-payout (sip010-token <sip010-transferable-trait>))
	(begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (asserts! (is-eq (var-get cycle-done) true) ERR-NOT-AUTHORIZED)
      (fold token-payout-iter LIST-200 sip010-token)
      (ok true)))

(define-private (token-payout-iter (target-id uint) (sip010-token <sip010-transferable-trait>))
	(begin
    (let
      ((target-deposit (default-to u0 (get member-deposit (map-get? pool-member target-id)))))
      (if (is-eq target-deposit u0) sip010-token (token-transfer target-id target-deposit sip010-token)))))

(define-private (token-transfer (target-id uint) (target-deposit uint) (sip010-token <sip010-transferable-trait>))
	(begin
    (let
      ((target-wallet (default-to BURN-ADDRESS (get member-wallet (map-get? pool-member target-id))))
        (target-deserved (/ (* target-deposit (var-get mined-token)) (var-get pool-balance))))
      (unwrap-panic (contract-call? sip010-token transfer target-deserved tx-sender target-wallet none)) sip010-token)))

;; Legacy token multi-send
(define-public (multi-send (data (list 200 {amount: uint, sender: principal, recipient: principal})) (sip010-token <sip010-transferable-trait>))
	(begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
		(fold multi-send-iter data sip010-token)
		(ok true)))

(define-private (multi-send-iter (data {amount: uint, sender: principal, recipient: principal}) (sip010-token <sip010-transferable-trait>))
	(begin
		(unwrap-panic (contract-call? sip010-token transfer (get amount data) (get sender data) (get recipient data) none)) sip010-token))

;; Individual Token Payout
(define-public (send-token (data {amount: uint, sender: principal, recipient: principal}) (sip010-token <sip010-transferable-trait>))
	(begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (var-get cycle-done) true) ERR-NOT-AUTHORIZED)
		(unwrap-panic (contract-call? sip010-token transfer (get amount data) (get sender data) (get recipient data) none))
    (ok true)))
