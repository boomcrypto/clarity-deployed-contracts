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

(define-fungible-token micro-nothing)

(define-data-var total-supply uint u0)

;; Internals

;; Total number of tokens in existence.
(define-read-only (get-total-supply)
  (var-get total-supply))

;; Public functions

;; Mint new tokens.
(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err u0)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? micro-nothing amount account))))


(define-public (transfer (to principal) (amount uint)) 
  (ft-transfer? micro-nothing amount tx-sender to))

;; Initialize the contract

(mint! 'SP1AWFMSB3AGMFZY9JBWR9GRWR6EHBTMVA9JW4M20 u20000000000000)
(mint! 'SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60 u20000000000000)
(mint! 'SP2F2NYNDDJTAXFB62PJX351DCM4ZNEVRYJSC92CT u20000000000000)
(mint! 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ u20000000000000)
(mint! 'SPT9JHCME25ZBZM9WCGP7ZN38YA82F77YM5HM08B  u20000000000000)