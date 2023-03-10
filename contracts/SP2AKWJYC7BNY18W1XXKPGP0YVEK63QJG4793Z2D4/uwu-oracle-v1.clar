;; UWU ORACLE CONTRACT V1
;; UWU Protocol Version 1.0.0

;; This file is part of UWU Protocol.

;; UWU Protocol is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; UWU Protocol is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with UWU Protocol. If not, see <http://www.gnu.org/licenses/>.

(define-public (send-to-proxy)
  (let (
    (oracle (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-1 fetch-price "STX")))
  )
    (contract-call? .uwu-oracle-proxy-v1 update-stx-price (get last-price oracle))
  )
)