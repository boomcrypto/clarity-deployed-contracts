;; UWU ORACLE PROXY CONTRACT Version 1.1.0
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

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_PROXY_FROZEN (err u4001))

(define-constant CONTRACT_OWNER tx-sender)

(define-data-var is-proxy-frozen bool false)
(define-data-var oracle-address principal tx-sender)
(define-data-var stx-price uint u0)

(define-read-only (get-oracle-address)
  (ok (var-get oracle-address))
)

(define-read-only (get-is-proxy-frozen)
  (ok (var-get is-proxy-frozen))
)

(define-read-only (get-stx-price)
  (ok (var-get stx-price))
)

(define-public (set-oracle-address (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (var-get is-proxy-frozen) false) ERR_PROXY_FROZEN)
    (ok (var-set oracle-address address))
  )
)

(define-public (freeze-proxy)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (var-get is-proxy-frozen) false) ERR_PROXY_FROZEN)
    (ok (var-set is-proxy-frozen true))
  )
)

(define-public (update-stx-price (price uint))
  (begin
    (asserts! (is-eq contract-caller (var-get oracle-address)) ERR_NOT_AUTHORIZED)
    (ok (var-set stx-price price))
  )
)