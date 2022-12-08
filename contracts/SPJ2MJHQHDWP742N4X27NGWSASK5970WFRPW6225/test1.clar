;;  copyright: (c) 2013-2019 by Blockstack PBC, a public benefit corporation.

;;  This file is part of Blockstack.

;;  Blockstack is free software. You may redistribute or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License or
;;  (at your option) any later version.

;;  Blockstack is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY, including without the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;  GNU General Public License for more details.

;;  You should have received a copy of the GNU General Public License
;;  along with Blockstack. If not, see <http://www.gnu.org/licenses/>.

;; Fungible Token, modeled after ERC-20

(define-fungible-token fungible-token)

;; Storage
(define-map allowances
  { spender: principal, owner: principal }
  { allowance: uint }
)
(define-data-var total-supply uint u0)

;; Internals

;; Total number of tokens in existence.
(define-private (get-total-supply)
  (var-get total-supply))

;; Gets the amount of tokens that an owner allowed to a spender.
(define-private (allowance-of (spender principal) (owner principal))
  (begin
    (print
      (map-get? allowances { spender: spender, owner: owner }))
    (print
      (get allowance
        (map-get? allowances { spender: spender, owner: owner })
      )
    )
    (default-to u0
      (get allowance
        (map-get? allowances { spender: spender, owner: owner })
      )
    )
  )
)

(define-public (get-allowance-of (spender principal) (owner principal))
  (ok (allowance-of spender owner))
)

;; Transfers tokens to a specified principal.
(define-public (transfer (recipient principal) (amount uint))
  (ft-transfer? fungible-token amount tx-sender recipient)
)

;; Decrease allowance of a specified spender.
(define-private (decrease-allowance (spender principal) (owner principal) (amount uint))
  (let ((allowance (allowance-of spender owner)))
    (if (or (> amount allowance) (<= amount u0))
      true
      (begin
        (map-set allowances
          { spender: spender, owner: owner }
          { allowance: (- allowance amount) }
        )
        true
      )
    )
  )
)

;; Internal - Increase allowance of a specified spender.
(define-private (increase-allowance (spender principal) (owner principal) (amount uint))
  (let ((allowance (allowance-of spender owner)))
    (if (<= amount u0)
      false
      (begin
        (print (tuple (spender spender) (owner owner)))
        (print (map-set allowances
          { spender: spender, owner: owner }
          { allowance: (+ allowance amount) }
          )
        )
        true
      )
    )
  )
)

;; Public functions

;; Transfers tokens to a specified principal.
(define-public (transfer-token (recipient principal) (amount uint))
  (transfer recipient amount)
)

;; Transfers tokens to a specified principal, performed by a spender
(define-public (transfer-from (owner principal) (recipient principal) (amount uint))
  (let ((allowance (allowance-of tx-sender owner)))
      (if (or (> amount allowance) (<= amount u0))
        (err false)
        (if (and
              (is-ok (ft-transfer? fungible-token amount owner recipient))
              (decrease-allowance tx-sender owner amount))
          (ok true)
          (err false)))))

;; Update the allowance for a given spender
(define-public (approve (spender principal) (amount uint))
  (if (and (> amount u0)
           (increase-allowance spender tx-sender amount))
      (ok amount)
      (err false)))

;; Revoke a given spender
(define-public (revoke (spender principal))
  (let ((allowance (allowance-of spender tx-sender)))
    (if (and (> allowance u0)
             (decrease-allowance spender tx-sender allowance))
        (ok 0)
        (err false))))

(define-public (balance-of (owner principal))
  (begin
      (print owner)
      (ok (ft-get-balance fungible-token owner))
  )
)
;; Mint new tokens.
(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err false)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (unwrap-panic (ft-mint? fungible-token amount account))
        (ok amount))))

;; Initialize the contract
(begin
  (try! (mint! 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u20))
  (try! (mint! 'S02J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKPVKG2CE u10))
)