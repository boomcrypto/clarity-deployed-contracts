---
title: "Trait uwu-usm-setup-v1-1-0"
draft: true
---
```
;; UWU USM SETUP CONTRACT Version 1.1.0
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

(contract-call? .uwu-stability-module-v1-1-0 set-swap-status false)
(contract-call? .uwu-stability-module-v1-1-2 set-swap-status false)
(contract-call? .uwu-stability-module-v1-1-3 set-swap-status false)

(contract-call? .uwu-stability-module-v1-1-0 withdraw-reserve 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.uwu-token-v1-1-0 u992036075)
(contract-call? .uwu-stability-module-v1-1-0 withdraw-reserve 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt u21646838693)

(contract-call? .uwu-stability-module-v1-1-2 withdraw-reserve 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.uwu-token-v1-1-0 u352328900 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.uwu-stability-module-v1-1-4)
(contract-call? .uwu-stability-module-v1-1-2 withdraw-reserve 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt u140971537503 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.uwu-stability-module-v1-1-4)

(contract-call? .uwu-stability-module-v1-1-2 remove-token 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(contract-call? .uwu-stability-module-v1-1-2 remove-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

(contract-call? .uwu-token-v1-1-0 transfer u992036075 tx-sender 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.uwu-stability-module-v1-1-4 none)

(contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt transfer u21646838693 tx-sender 'SP6BE9VJRG7YDAH46FC26FC3YYHNE8FA4E4EADTV none)

(contract-call? .uwu-stability-module-v1-1-4 set-fee-address 'SP6BE9VJRG7YDAH46FC26FC3YYHNE8FA4E4EADTV)

(contract-call? .uwu-stability-module-v1-1-4 add-token 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt true u100000000 u50 u0 u1000000 'SP6BE9VJRG7YDAH46FC26FC3YYHNE8FA4E4EADTV)
(contract-call? .uwu-stability-module-v1-1-4 add-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc true u1000000 u50 u0 u1000000 'SP6BE9VJRG7YDAH46FC26FC3YYHNE8FA4E4EADTV)
```
