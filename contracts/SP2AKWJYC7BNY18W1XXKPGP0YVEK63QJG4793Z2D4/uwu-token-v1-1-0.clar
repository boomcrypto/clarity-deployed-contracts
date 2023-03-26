;; UWU TOKEN CONTRACT Version 1.1.0
;; UWU PROTOCOL Version 1.1.0

;; This file is part of UWU PROTOCOL.

;; UWU PROTOCOL is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; UWU PROTOCOL is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with UWU PROTOCOL. If not, see <http://www.gnu.org/licenses/>.

(impl-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token uwu)

(define-constant ERR_NOT_AUTHORIZED (err u1001))

(define-constant CONTRACT_OWNER tx-sender)

(define-data-var token-uri (string-utf8 256) u"")

(define-read-only (get-name)
  (ok "UWU Cash")
)

(define-read-only (get-symbol)
  (ok "UWU")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply uwu))
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance uwu account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (var-set token-uri uri))
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)
    (print (default-to 0x memo))
    (ft-transfer? uwu amount sender recipient)
  )
)

(define-public (mint (amount uint) (account principal))
  (begin
    (asserts! (is-eq contract-caller .uwu-factory-v1-1-0) ERR_NOT_AUTHORIZED)
    (ft-mint? uwu amount account)
  )
)

(define-public (burn (amount uint) (account principal))
  (begin
    (asserts! (is-eq contract-caller .uwu-factory-v1-1-0) ERR_NOT_AUTHORIZED)
    (ft-burn? uwu amount account)
  )
)