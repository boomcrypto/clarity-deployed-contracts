---
title: "Trait stx-raffle"
draft: true
---
```
;; Author: Eriq Ferrari  
;; Name: eriq.btc  
;; Title: STX Raffle
;; Version: 1.0
;; Website: www.stxmap.co
;; License: MIT
;;
;; The STX Raffle is an innovative on-chain raffle system built on the Stacks 
;; blockchain, offering a secure and transparent mechanism for organizing raffles 
;; with unpredictable randomness. This contract supports three types of raffles: 
;; STX, fungible tokens (FT), and non-fungible tokens (NFT). Participants can 
;; enjoy a fair and trustless raffle experience where the creator receives the 
;; collected funds and the winner receives the prize.
;;
;; Key features include the ability to set a maximum ticket limit per wallet, 
;; ensuring fair participation. For FT and NFT raffles, tickets can be offered 
;; for free, with users only covering the transaction fees. The randomness is 
;; derived from a combination of the block Header ID Hash, the timestamp, and 
;; the raffle's name hash, creating a robust source of entropy.
;;
;; The draw function works by first generating a keccak256 hash of the raffle's 
;; name. This name hash is then combined with the timestamp and hashed again 
;; using keccak256. The resulting hash is further combined with the block Header 
;; ID Hash and hashed once more using keccak256, like this:
;; keccak256(id header + keccak256(timestamp + keccak256(name))). This process 
;; produces a final hash that is used to determine the winner, ensuring a high 
;; level of unpredictability and security in the raffle outcome.
;;
;; The draw function is a read-only function, allowing anyone to verify the 
;; results of the raffle at any time without incurring any costs. This function 
;; is crucial for maintaining transparency and fairness, as participants can 
;; independently confirm the outcome of the raffle without relying on third parties. 
;; The read-only nature ensures that the function is accessible and cost-free, 
;; encouraging broader participation in the verification process.
;;
;; Additionally, the function responsible for sending the prize is public, meaning 
;; that any participant or observer can trigger it. This design choice reinforces 
;; the decentralized nature of the contract, ensuring that the prize distribution 
;; is open and transparent. By allowing anyone to trigger the prize distribution, 
;; the contract minimizes the risk of centralized control or manipulation.
;;
;; This on-chain randomness is both transparent and verifiable, providing all 
;; participants with confidence in the fairness of the raffle process. The raffle 
;; operates without a predefined time limit, allowing the draw to be triggered 
;; only after all tickets are sold. This ensures that the raffle progresses 
;; fairly and that the draw can only occur once the participation criteria are 
;; fully met. This feature provides participants with certainty that the raffle 
;; will only conclude when all tickets are accounted for, further enhancing the 
;; overall transparency and fairness of the system.
;;
;; In terms of functionality, the contract is designed to be user-friendly and 
;; accessible, with clear parameters for entering and managing raffles. Users 
;; can easily participate in raffles using STX to purchase tickets, with 
;; the entire process being managed on-chain to ensure full transparency. The 
;; use of blockchain technology guarantees that every step of the raffle, from 
;; ticket purchase to winner selection, is recorded and cannot be altered or 
;; tampered with.
;;
;; This contract leverages the power of Stacks to deliver a fully decentralized, 
;; transparent, and secure raffle experience. Users can rest assured that the 
;; randomness and the process as a whole are immune to manipulation, providing 
;; a trustworthy and enjoyable platform for decentralized raffles. Furthermore, 
;; the combination of multiple sources of randomness, along with the public draw 
;; function, establishes a robust system where fairness is at the forefront of 
;; every raffle.
;;
;; The STX Raffle represents a new era in decentralized gaming and fundraising, 
;; offering users a reliable and transparent way to engage in raffles. Whether 
;; for entertainment, charity, or other purposes, this contract ensures that 
;; every participant has a fair chance to win, with the entire process being 
;; open to scrutiny and verification by anyone with access to the blockchain.
;;
;;;;;;;;;;;;;;;;;;;;;;;; Copyright 2024 Enrico Ferrari ;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy 
;; of this software and associated documentation files (the Software), to deal 
;; in the Software without restriction, including without limitation the rights 
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
;; copies of the Software, and to permit persons to whom the Software is furnished 
;; to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in 
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
;; IN THE SOFTWARE.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;HERE START THE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mainnet nft trait implementation
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; sip-09 function implementation
(define-private (transfer-nft (token-contract <nft-trait>) (token-id uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer token-id sender recipient)
)

;; Mainnet ft trait implementation
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; sip-010 function implementation
(define-private (transfer-ft (token-contract <sip-010-trait>) (quantity uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer quantity sender recipient none)
)

;; Errors

(define-constant NO-RAFFLE u100)
(define-constant RAFFLE-EXIST u101)
(define-constant EMPTY-VALUE u102)
(define-constant NOT-ZERO u103)
(define-constant NOT-ENOUGH-TICKETS u104)
(define-constant LIMIT-EXCEED u105)
(define-constant ACTIVE-EXCEED u106)
(define-constant HASH-ERROR u200)
(define-constant DATA-ERROR u201)
(define-constant ENDED u300)
(define-constant ACTIVE u301)
(define-constant DRAFTED u302)
(define-constant WRONG-TYPE u303)
(define-constant WRONG-ASSET u304)
(define-constant NOT-THE-OWNER u400)
(define-constant OUT-OF-RANGE u401)

;; Defining main maps for raffles

(define-map raffles
  uint
  { 
    creator: principal,
    name: (string-ascii 32),
    ticket-price: uint,
    max-tickets: uint,
    wallet-limit: uint,
    next-ticket: uint,
    prize-type: (string-ascii 4),
    prize-contract: principal,
    prize-id: uint,
    prize-quantity: uint,
    protocol-fee: uint,
    end-block: uint,
    status: (string-ascii 8)
  }
)

(define-map raffle-tickets
  {raffle: uint, ticket: uint}
  {buyer: principal, block: uint, winner: bool}
)

(define-map raffle-tickets-per-wallet
  {buyer: principal, raffle: uint}
  uint
)

(define-map raffle-winners
  uint
  {winner: principal, ticket: uint}
)

;; Contract variables

(define-data-var owner principal tx-sender)
(define-data-var protocol principal 'SPXYTPQSRP2J3H76Z1V0P5S55VX2ZC3Q58JXANTJ)
(define-data-var protocol-fee uint u250)
(define-data-var creation-cost uint u1000000)
(define-data-var raffle-count uint u1)
(define-data-var active-raffle (list 64000 uint) (list))
(define-data-var ready-to-draw-raffle (list 64000 uint) (list))

;; Filters

(define-private (is-not-zero (num uint))
(> num u0)
)

;; Functions to manage the contract variable

(define-public (set-new-owner (new-owner principal))
(begin 
(asserts! (is-eq tx-sender (var-get owner)) (err NOT-THE-OWNER))
(var-set owner new-owner)
(ok true)
))

(define-public (set-new-protocol (new-protocol principal))
(begin
(asserts! (is-eq tx-sender (var-get owner)) (err NOT-THE-OWNER))
(var-set protocol new-protocol)
(ok true)
))

(define-public (set-new-protocol-fee (new-fee uint))
(begin 
(asserts! (is-eq tx-sender (var-get owner)) (err NOT-THE-OWNER))
(asserts! (and (>= u100 new-fee) (<= u500 new-fee)) (err OUT-OF-RANGE))
(var-set protocol-fee new-fee)
(ok true)
))

(define-public (set-new-cost (new-cost uint))
(begin 
(asserts! (is-eq tx-sender (var-get owner)) (err NOT-THE-OWNER))
(asserts! (> new-cost u0) (err NOT-ZERO))
(var-set creation-cost new-cost)
(ok true)
))

;; stx-raffle

(define-public (create-raffle-stx (name (string-ascii 32)) (price uint) (max uint) (wallet-limit uint))
  (let (
        (current-raffle-count (var-get raffle-count))
        (prize-contract (as-contract tx-sender))
        (active (var-get active-raffle))
    )
    (begin
      ;; Ensure the raffle ID does not already exist and parameters are correct
      (asserts! (is-none (map-get? raffles current-raffle-count)) (err RAFFLE-EXIST))
      (asserts! (> (len name) u0) (err EMPTY-VALUE))
      (asserts! (> price u0) (err NOT-ZERO))
      (asserts! (>= max u10) (err NOT-ENOUGH-TICKETS))
      (asserts! (< wallet-limit max) (err LIMIT-EXCEED))
      (asserts! (< (len active) u64000) (err ACTIVE-EXCEED) )
      ;; Add the map to active raffles
      (var-set active-raffle (unwrap-panic (as-max-len? (append active current-raffle-count) u64000)))
      ;; Insert the new raffle with initial values
      (map-set raffles current-raffle-count {
        creator: tx-sender,
        name: name,
        ticket-price: price,
        max-tickets: max,
        wallet-limit: wallet-limit,
        next-ticket: u1,
        prize-type: "stx",
        prize-contract: (as-contract tx-sender),
        prize-id: u1,
        prize-quantity: (* price max),
        protocol-fee: (var-get protocol-fee),
        end-block: u0,
        status: "created"
      })

      ;; Increment the raffle count
      (var-set raffle-count (+ current-raffle-count u1))
      (print {a: "create", raffle: current-raffle-count, type: "stx", price: price, max: max})
      (try! (stx-transfer? (var-get creation-cost) tx-sender (var-get protocol)))
    )
    (ok true)
  )
)

;; nft-raffle

(define-public (create-raffle-nft (name (string-ascii 32)) (price uint) (max uint) (nft-contract <nft-trait>) (token-id uint) (wallet-limit uint))
  (let (
        (current-raffle-count (var-get raffle-count))
        (active (var-get active-raffle))
    )
    (begin
      ;; Ensure the raffle ID does not already exist
      (asserts! (is-none (map-get? raffles current-raffle-count)) (err RAFFLE-EXIST))
      (asserts! (> (len name) u0) (err EMPTY-VALUE))
      (asserts! (> max u10) (err NOT-ENOUGH-TICKETS))
      (asserts! (< wallet-limit max) (err LIMIT-EXCEED))
      (asserts! (< (len active) u64000) (err ACTIVE-EXCEED) )
      ;; Add the map to active raffles
      (var-set active-raffle (unwrap-panic (as-max-len? (append active current-raffle-count) u64000)))
      ;; Insert the new raffle with initial values
      (map-set raffles current-raffle-count {
        creator: tx-sender,
        name: name,
        ticket-price: price,
        max-tickets: max,
        wallet-limit: wallet-limit,
        next-ticket: u1,
        prize-type: "nft",
        prize-contract: (contract-of nft-contract),
        prize-id: token-id,
        prize-quantity: u1,
        protocol-fee: (var-get protocol-fee),
        end-block: u0,
        status: "created"
      })

      ;; Increment the raffle count
      (var-set raffle-count (+ current-raffle-count u1))
      (print {a: "create", raffle: current-raffle-count, type: "nft", price: price, max-tickets: max, prize-contract: nft-contract, prize-id: token-id})
      ;; if ticket is free send a creation fee
      (if (> price u0)
          (try! (transfer-nft nft-contract token-id tx-sender (as-contract tx-sender)))
          (begin 
          (try! (transfer-nft nft-contract token-id tx-sender (as-contract tx-sender)))
          (try! (stx-transfer? (var-get creation-cost) tx-sender (var-get protocol)))
          )
      )
      
      (ok name)
    )
  )
)

;; ft-raffle

(define-public (create-raffle-ft (name (string-ascii 32)) (price uint) (max uint) (ft-contract <sip-010-trait>) (quantity uint) (wallet-limit uint))
  (let (
        (current-raffle-count (var-get raffle-count))
        (active (var-get active-raffle))
    )
    (begin
      ;; Ensure the raffle ID does not already exist
      (asserts! (is-none (map-get? raffles current-raffle-count)) (err RAFFLE-EXIST))
      (asserts! (> (len name) u0) (err EMPTY-VALUE))
      (asserts! (> max u10) (err NOT-ENOUGH-TICKETS))
      (asserts! (< wallet-limit max) (err LIMIT-EXCEED))
      (asserts! (< (len active) u64000) (err ACTIVE-EXCEED) )
      ;; Add the map to active raffles
      (var-set active-raffle (unwrap-panic (as-max-len? (append active current-raffle-count) u64000)))
      ;; Insert the new raffle with initial values
      (map-set raffles current-raffle-count {
        creator: tx-sender,
        name: name,
        ticket-price: price,
        max-tickets: max,
        wallet-limit: wallet-limit,
        next-ticket: u1,
        prize-type: "ft",
        prize-contract: (contract-of ft-contract),
        prize-id: u1,
        prize-quantity: quantity,
        protocol-fee: (var-get protocol-fee),
        end-block: u0,
        status: "created"
      })

      ;; Increment the raffle count
      (var-set raffle-count (+ current-raffle-count u1))
      (print {a: "create", raffle: current-raffle-count, type: "ft", price: price, max-tickets: max, token: ft-contract, quantity: quantity})
      ;; if ticket is free send a creation fee
      (if (> price u0)
          (try! (transfer-ft ft-contract quantity tx-sender (as-contract tx-sender) ))
          (begin 
          (try! (transfer-ft ft-contract quantity tx-sender (as-contract tx-sender) ))
          (try! (stx-transfer? (var-get creation-cost) tx-sender (var-get protocol)))
          )
      )
      
      (ok name)
    )
  )
)

;; buy-ticket

(define-public (buy-ticket (raffle-id uint))
  (let (
        ;; Fetch raffle details
        (raffle (map-get? raffles raffle-id))
    )
    ;; Ensure the raffle exists
    (asserts! (is-some raffle) (err NO-RAFFLE))

    (let (
          (raffle-data (unwrap! raffle (err DATA-ERROR)))
          (current-ticket (get next-ticket raffle-data))
          (max-ticket (get max-tickets raffle-data))
          (ticket-holder tx-sender)
          (type (get prize-type raffle-data))
          (price (get ticket-price raffle-data))
          (fee (get protocol-fee raffle-data))
          (wallet-limit (get wallet-limit raffle-data))
          (wallet-count (get-ticket-per-wallet raffle-id tx-sender))
          
    )
    
    ;; Ensure we haven't exceeded the max number of tickets
    (asserts! (<= current-ticket max-ticket) (err ENDED))
    (asserts! (and (< wallet-count wallet-limit) (> wallet-limit u0)) (err LIMIT-EXCEED))
    
    ;; Add the new ticket to the raffle-tickets map
    (map-set raffle-tickets {raffle: raffle-id, ticket: current-ticket} {buyer: ticket-holder, block: block-height, winner: false})

    ;; Add the new ticket to wallet count
    (map-set raffle-tickets-per-wallet {buyer: ticket-holder,raffle: raffle-id} (+ wallet-count u1))
    (print {a: "buy", raffle: raffle-id, ticket: current-ticket})
    ;; Check if max tickets reached
    (if (<= (+ current-ticket u1) max-ticket)
      (begin 
      ;; Update the raffle with the new ticket number
      (map-set raffles raffle-id
      {
        creator: (get creator raffle-data),
        name: (get name raffle-data),
        ticket-price: price,
        max-tickets: max-ticket,
        wallet-limit: (get wallet-limit raffle-data),
        next-ticket: (+ current-ticket u1),
        prize-type: type,
        prize-contract: (get prize-contract raffle-data),
        prize-id: (get prize-id raffle-data),
        prize-quantity: (get prize-quantity raffle-data),
        protocol-fee: fee,
        end-block: u0,
        status: "open"
      }
      )
      (pay-ticket price)
      )
      (let (
        (active (var-get active-raffle))
        (replaced (replace-at? active (unwrap-panic (index-of? active raffle-id)) u0) )
        (filtered (filter is-not-zero (unwrap-panic replaced)))
        (ready (var-get ready-to-draw-raffle))
        (added (unwrap-panic (as-max-len? (append ready raffle-id) u64000)))
      )
      ;; Remove the raffle from active list
      (var-set active-raffle filtered)
      ;; Add the raffle to ready to draw list
      (var-set ready-to-draw-raffle added)
      ;; Finalize the raffle with the last ticket number
      (map-set raffles raffle-id
      {
        creator: (get creator raffle-data),
        name: (get name raffle-data),
        ticket-price: price,
        max-tickets: max-ticket,
        wallet-limit: (get wallet-limit raffle-data),
        next-ticket: (+ current-ticket u1),
        prize-type: type,
        prize-contract: (get prize-contract raffle-data),
        prize-id: (get prize-id raffle-data),
        prize-quantity: (get prize-quantity raffle-data),
        protocol-fee: fee,
        end-block: block-height,
        status: "closed"
      }
      )

      (print {a: "closed", raffle: raffle-id, block: block-height})
      (pay-ticket price)
      )
      
    )))
)

;; pay-ticket if not free

(define-private (pay-ticket (price uint))
  (if (> price u0)
        (stx-transfer? price tx-sender (as-contract tx-sender))
        (ok true)
      )
)

;; check-err to loop in bulk functions

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

;; buy many tickets

(define-public (buy-many-tickets (raffles-list (list 100 uint)))
  (fold check-err (map buy-ticket raffles-list) (ok true))
)

;; verify many raffle

(define-read-only (draw-many (raffles-to-draw (list 100 uint)))
(map draw raffles-to-draw)
)

;; draw and verify the results

(define-read-only (draw (raffle-id uint))
 
    (let (
      ;; First we get the raffle data
      (raffle (unwrap! (map-get? raffles raffle-id) (err NO-RAFFLE)))
      (block-time (unwrap! (get-block-info? time (get end-block raffle)) (err ACTIVE)))
      (block-id (unwrap! (get-block-info? id-header-hash (get end-block raffle)) (err DATA-ERROR)))
      ;; Hash conbination of raffle name, block-time and id header hash
      (name-hash (keccak256 (unwrap-panic (to-consensus-buff? (get name raffle)))))
      (time-hash (keccak256 (concat (unwrap-panic (to-consensus-buff? block-time)) name-hash)))
      (full-hash (keccak256 (concat block-id time-hash)))
      (hash-slice (as-max-len? (unwrap! (slice? full-hash u16 u32) (err HASH-ERROR)) u16) )
      (hash-uint (buff-to-uint-le (unwrap! hash-slice (err HASH-ERROR))))
      (uint-str (int-to-ascii hash-uint))
      (uint-len (len uint-str))
      (ticket-len (len (int-to-ascii (get max-tickets raffle))))
      (start  (- uint-len ticket-len))
        (sel (slice? uint-str start uint-len))
        (sel-two (slice? uint-str (+ u1 start) uint-len))
        (sel-some (string-to-uint? (unwrap! sel (err DATA-ERROR))))
        (sel-two-some (string-to-uint? (unwrap! sel-two (err DATA-ERROR))))
        (selected (unwrap! sel-some (err DATA-ERROR)))
        (selected-two (unwrap! sel-two-some (err DATA-ERROR)))
    )
    (asserts! (> (get end-block raffle) u0) (err ACTIVE))
    (if (is-eq selected u0)
        (ok (get max-tickets raffle))
        (if (> selected (get max-tickets raffle))
        (if (is-eq selected-two u0)
        (ok u1)
        (ok selected-two)
        )
        (ok selected)
    )
    )
    )
)

;; Send the prize for STX Raffle

(define-public (send-prize-stx (raffle-id uint)) 
  (let (
    ;; Fetch raffle details
    (raffle (unwrap! (map-get? raffles raffle-id) (err NO-RAFFLE) ))
    (type (get prize-type raffle))
    (status (get status raffle))
    (end-block (get end-block raffle))
    (max-tickets (get max-tickets raffle))
    (price (get ticket-price raffle))
    (total-amount (* max-tickets price))
    )
    (asserts! (is-eq type "stx")  (err WRONG-TYPE))
    (asserts! (> end-block u0)  (err ACTIVE))
    (asserts! (is-eq status "closed") (err DRAFTED))
    (let (
      (winner (unwrap! (draw raffle-id) (err DATA-ERROR) ))
      (winner-address (unwrap-panic (get-ticket-owner raffle-id winner )))
      (ready (var-get ready-to-draw-raffle))
      (replaced (replace-at? ready (unwrap-panic (index-of? ready raffle-id)) u0) )
      (filtered (filter is-not-zero (unwrap-panic replaced)))
    )
    ;; Remove the raffle from ready to draw list
    (var-set ready-to-draw-raffle filtered)
    (map-set raffle-winners raffle-id {winner: winner-address, ticket: winner})
    (map-set raffle-tickets {raffle: raffle-id, ticket: winner} {buyer: winner-address, block: (unwrap-panic (get-ticket-block raffle-id winner)), winner: true})
    (as-contract (stx-transfer? total-amount tx-sender winner-address ))
    )
  )
)

;; Send the prize for NFT Raffle

(define-public (send-prize-nft (raffle-id uint) (nft-contract <nft-trait>)) 
  (let (
    ;; Fetch raffle details
    (raffle (unwrap! (map-get? raffles raffle-id) (err NO-RAFFLE) ))
    (type (get prize-type raffle))
    (status (get status raffle))
    (end-block (get end-block raffle))
    (max-tickets (get max-tickets raffle))
    (prize-contract (get prize-contract raffle))
    (price (get ticket-price raffle))
    (token-id (get prize-id raffle))
    )
    (asserts! (is-eq prize-contract (contract-of nft-contract)) (err WRONG-ASSET))
    (asserts! (is-eq type "nft")  (err WRONG-TYPE))
    (asserts! (> end-block u0)  (err ACTIVE))
    (asserts! (is-eq status "closed") (err DRAFTED))
    (let (
      (winner (unwrap! (draw raffle-id) (err DATA-ERROR) ))
      (winner-address (unwrap-panic (get-ticket-owner raffle-id winner )))
      (ready (var-get ready-to-draw-raffle))
      (replaced (replace-at? ready (unwrap-panic (index-of? ready raffle-id)) u0) )
      (filtered (filter is-not-zero (unwrap-panic replaced)))
    )
    ;; Remove the raffle from ready to draw list
    (var-set ready-to-draw-raffle filtered)
    (map-set raffle-winners raffle-id {winner: winner-address, ticket: winner})
    (map-set raffle-tickets {raffle: raffle-id, ticket: winner} {buyer: winner-address, block: (unwrap-panic (get-ticket-block raffle-id winner)), winner: true})
    (print {a: "draw-nft", winner: winner, prize-collection: nft-contract, prize-id: token-id})
    (if (> price u0)
    ;; if the raffle is not free send fee to protocol and remainder to creator 
    (let (
      (total-amount (* max-tickets price))
      (fee-amount (/ (* total-amount (get protocol-fee raffle)) u10000))
      (prize (- total-amount fee-amount))
    )
  (try! (as-contract (stx-transfer? fee-amount tx-sender (var-get protocol))))
  (try! (as-contract (stx-transfer? prize  tx-sender (get creator raffle))))
  (as-contract (transfer-nft nft-contract token-id  tx-sender winner-address))
  )
  (as-contract (transfer-nft nft-contract token-id tx-sender winner-address))
  )
  )
  )
)

;; Send the prize for FT Raffle

(define-public (send-prize-ft (raffle-id uint) (ft-contract <sip-010-trait>)) 
  (let (
    ;; Fetch raffle details
    (raffle (unwrap! (map-get? raffles raffle-id) (err NO-RAFFLE) ))
    (type (get prize-type raffle))
    (status (get status raffle))
    (end-block (get end-block raffle))
    (max-tickets (get max-tickets raffle))
    (prize-contract (get prize-contract raffle))
    (price (get ticket-price raffle))
    (quantity (get prize-quantity raffle))
    )
    (asserts! (is-eq prize-contract (contract-of ft-contract)) (err WRONG-ASSET))
    (asserts! (is-eq type "ft")  (err WRONG-TYPE))
    (asserts! (> end-block u0)  (err ACTIVE))
    (asserts! (is-eq status "closed") (err DRAFTED))
    (let (
      (winner (unwrap! (draw raffle-id) (err DATA-ERROR) ))
      (winner-address (unwrap-panic (get-ticket-owner raffle-id winner )))
      (ready (var-get ready-to-draw-raffle))
      (replaced (replace-at? ready (unwrap-panic (index-of? ready raffle-id)) u0) )
      (filtered (filter is-not-zero (unwrap-panic replaced)))
    )
    ;; Remove the raffle from ready to draw list
    (var-set ready-to-draw-raffle filtered)
    (map-set raffle-winners raffle-id {winner: winner-address, ticket: winner})
    (map-set raffle-tickets {raffle: raffle-id, ticket: winner} {buyer: winner-address, block: (unwrap-panic (get-ticket-block raffle-id winner)), winner: true})
    (print {a: "draw-ft", winner: winner, tokens: ft-contract, quantity: quantity})
    (if (> price u0)
    ;; if the raffle is not free send fee to protocol and remainder to creator 
    (let (
      (total-amount (* max-tickets price))
      (fee-amount (/ (* total-amount (get protocol-fee raffle)) u10000))
      (prize (- total-amount fee-amount))
    )
  (try! (as-contract (stx-transfer? fee-amount tx-sender (var-get protocol))))
  (try! (as-contract (stx-transfer? prize  tx-sender (get creator raffle))))
  (as-contract (transfer-ft ft-contract quantity tx-sender winner-address))
  )
  (as-contract (transfer-ft ft-contract quantity (as-contract tx-sender) winner-address))
  )
  )
  )
)

;; Read-only functions

(define-read-only (get-ticket-owner (raffle-id uint) (ticket uint ))
 (let (
  (raffle-ticket (map-get? raffle-tickets {raffle: raffle-id, ticket: ticket}))
 )
 (if (is-some raffle-ticket)
 (ok (unwrap-panic (get buyer raffle-ticket)))
 (ok (as-contract tx-sender))
 )
 )
)

(define-read-only (get-ticket-block (raffle-id uint) (ticket uint ))
 (let (
  (raffle-ticket (map-get? raffle-tickets {raffle: raffle-id, ticket: ticket}))
 )
 (if (is-some raffle-ticket)
 (ok (unwrap-panic (get block raffle-ticket)))
 (ok u0)
 )
 )
)

(define-read-only (is-ticket-winner (raffle-id uint) (ticket uint ))
 (let (
  (raffle-ticket (map-get? raffle-tickets {raffle: raffle-id, ticket: ticket}))
 )
 (if (is-some raffle-ticket)
 (ok (unwrap-panic (get winner raffle-ticket)))
 (ok false)
 )
 )
)

(define-read-only (get-raffle-winner (raffle-id uint) )
 (let (
  (raffle-winner (map-get? raffle-winners raffle-id))
 )
 (if (is-some raffle-winner)
 (ok (unwrap-panic (get winner raffle-winner)))
 (ok (as-contract tx-sender))
 )
 )
)

(define-read-only (get-raffle-ticket-winner (raffle-id uint) )
 (let (
  (raffle-winner (map-get? raffle-winners raffle-id))
 )
 (if (is-some raffle-winner)
 (ok (unwrap-panic (get ticket raffle-winner)))
 (ok u0)
 )
 )
)

;; get all the info about a single ticket

(define-read-only (get-ticket-info (raffle-id uint) (ticket uint ))
  (ok {
    buyer: (unwrap-panic (get-ticket-owner raffle-id ticket)),
    block: (unwrap-panic (get-ticket-block raffle-id ticket)),
    winner: (unwrap-panic (is-ticket-winner raffle-id ticket))
  })
)

;; get the full status of a raffle

(define-read-only (get-raffle (raffle-id uint))
  (let (
    (raffle (unwrap! (map-get? raffles raffle-id) (err NO-RAFFLE) ))
  )
  (ok { 
        id: raffle-id,
        creator: (get creator raffle),
        name: (get name raffle),
        ticket-price: (get ticket-price raffle),
        max-tickets: (get max-tickets raffle),
        wallet-limit: (get wallet-limit raffle),
        next-ticket: (get next-ticket raffle),
        prize-type: (get prize-type raffle),
        prize-contract: (get prize-contract raffle),
        prize-id: (get prize-id raffle),
        prize-quantity: (get prize-quantity raffle),
        protocol-fee: (get protocol-fee raffle),
        end-block: (get end-block raffle),
        status: (get status raffle),
        winner: (get-raffle-winner raffle-id),
        ticket-winner: (get-raffle-ticket-winner raffle-id)
      }
    )
  )
)

;; single raffle counter to limit purchase

(define-read-only (get-ticket-per-wallet (raffle-id uint) (user principal))
 (default-to u0 (map-get? raffle-tickets-per-wallet {buyer: user, raffle: raffle-id}))
)

;; lists of active, ready to draw raffles

(define-read-only (get-active-raffle)
(var-get active-raffle)
)

(define-read-only (get-ready-to-draw-raffle)
(var-get ready-to-draw-raffle)
)

;; check how many raffles was created

(define-read-only (get-last-raffle)
  (var-get raffle-count)
)

;; protocol information

(define-read-only (get-owner)
  (var-get owner)
)

(define-read-only (get-protocol-fee)
  (var-get protocol-fee)
)

(define-read-only (get-protocol)
  (var-get protocol)
)

(define-read-only (get-cost)
  (var-get creation-cost)
)
```
