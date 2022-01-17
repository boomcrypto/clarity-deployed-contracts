;;  Copyright (c) 2021 by The Bitfari Foundation.
;;  This file is part of Bitfari.

;;  Bitfari is free software. You may redistribute or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License or
;;  (at your option) any later version.

;;  Bitfari is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY, including without the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;  GNU General Public License for more details.

;;  You should have received a copy of the GNU General Public License
;;  along with Bitfari. If not, see <http://www.gnu.org/licenses/>.

;; This file contains the code to implement the Fari Token as specified in https://bitfari.org/token/
;; The token allows for discounted advertising, network governance and deep-discount shopping.

;; Part shopping club token, part loyalty card and part advertising token, Bitfari implements a novel idea:
;; all customers are marketers, discounts contribute to loyalty, and, all token holders should have a say in the
;; destiny of the network.

;; The following token code is to be considered immutable with the exception of any required emergency adjustments.

;; ---------------------------------------------------------------------------------------------------------------------

;; implement the `ft-trait` trait defined in the `ft-trait` contract

;; trait in testnet
;;(impl-trait 'ST3FYGS9F88Y5FW2DT2Q5C7FVX99Y9HREGCXH5T9D.ft-trait.sip-010-trait)

;; trait in mainnet
(impl-trait 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.sip-010-trait.sip-010-trait)

;; limit supply to 100M Faris
(define-constant MAX_MINT u10000000000000000)

;; max six decimal places
(define-constant DECIMAL_PLACES u8)

;; errors
(define-constant ERR_NO_VOID_MINT u1000)
(define-constant ERR_NO_AUTH_MINT u1002)
(define-constant ERR_NO_MORE_MINT u1004)
(define-constant ERR_INVALID_TRANSFER u1008)
 
;; name the token
(define-fungible-token fari)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok (ft-get-balance fari owner))))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply fari)))

;; returns the token name
(define-read-only (get-name)
  (ok "Fari"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "FARI"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok DECIMAL_PLACES))

;; get the token uri
(define-public (get-token-uri)
  (ok (some u"https://bitfari.org/token/")))

;; transfer tokens to a recipient, check for non-zero, valid transfers
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
(if
  (> (ft-get-balance fari tx-sender) u0)
    (begin
      (if (is-eq tx-sender sender)
        (begin
          (try! (ft-transfer? fari amount sender recipient))
          (print memo)
          (ok true)
        )
        (err ERR_INVALID_TRANSFER)))
    (err u0)))

;; execute mining after sanitization
(define-private (execute-mint (amount uint) (account principal))
    (if (< MAX_MINT (+ (ft-get-supply fari) amount))
      (err ERR_NO_MORE_MINT)
      (begin
       (try! (ft-mint? fari amount account))
        (ok true))))

;; mint new tokens, check minted amount is valid
(define-private (validate-mint (amount uint) (account principal))
  (if (<= amount u0)
      (err ERR_NO_VOID_MINT)
      (execute-mint amount account)))

;; validate minting auth, amount, supply and then execute 
(define-public (mint (amount uint) (account principal))
    (if
    ;; auth minter for testnet
    ;;(is-eq tx-sender 'ST3FYGS9F88Y5FW2DT2Q5C7FVX99Y9HREGCXH5T9D)
    ;; auth minter for mainnet
     (is-eq tx-sender 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA)
        (validate-mint amount account)
        (err ERR_NO_AUTH_MINT)))

;; initialize the foundation treasury
;; mint dev fund, investor fund, marketing fund, advisor fund, and grant fund
;; 80M tokens to be minted to the community
;; find the token allocations and distribution schedule at https://bitfari.org/token/

;; testnet mint - to be distributed over 3 years
;;(mint u2000000000000000 'ST22CGGASNT176J764WXGD5ZKDK2ZEQ6XNRC660DX)

;; mainnet mint - to be distributed over 3 years
(mint u2000000000000000 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA)