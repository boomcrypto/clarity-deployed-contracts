;;  Copyright (c) 2022 by The Bitfari Foundation.
;;  This file is part of the Bitfari Community Toolkit.

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

;;  Assigns ownership, metadata and ID to a top community member or VIP event attendant
;;  preventing unathorized users from joining selected resources en masse

;;  This token is transferable.
 
;; ------------------------------------------------------------------------------------------------------------------
 
;; SIP090 interface (testnet)
;;(impl-trait 'ST32XCD69XPS3GKDEXAQ29PJRDSD5AR643GY0C3Q5.nft-trait.nft-trait)
 
;; SIP090 interface (mainnet)
(impl-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)
 
;; Register a new VIP Member - Stratospheric Leaders
 (define-non-fungible-token fari-leader-nft uint)
 
;; Store the variables
 (define-data-var last-id uint u0)
 
;; Claim a new NFT
 (define-public (claim)
    (mint tx-sender))
 
;; SIP009: Transfer the token to a specified principal
  (define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (if (and
         (is-eq tx-sender sender))
       (match (nft-transfer? fari-leader-nft token-id sender recipient)
          success (ok success)
          error (err error))
       (err u500)))
 
;; SIP009: Get the owner of the specified token ID
 (define-read-only (get-owner (token-id uint))
   (ok (nft-get-owner? fari-leader-nft token-id)))
 
;; SIP009: Get the last token ID
 (define-read-only (get-last-token-id)
 
  (ok (var-get last-id)))
 
;; SIP009: Get the token URI
 (define-read-only (get-token-uri (token-id uint))
    (ok (some "https://bitfari.org/stratospheric-leaders")))
 
;; Mint a New Stratospheric Leader NFT
 (define-private (mint (new-owner principal))
      (let ((next-id (+ u1 (var-get last-id))))
        (match (nft-mint? fari-leader-nft next-id new-owner)
          success
            (begin
              (var-set last-id next-id)       
              (ok true))
          error (err error))))