

;; creature-racer-nft
;; NFT contract for creatures
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;;
;; =========
;; CONSTANTS
;; =========
;;
(define-constant contract-owner tx-sender)

(define-constant total-fibbo-weight u230)


(define-constant err-forbidden (err u403))
(define-constant err-not-found (err u404))
(define-constant err-mint-cap-exceeded (err u7001))
(define-constant err-expiry-time-in-past (err u7002))
(define-constant err-invalid-creature-type (err u7003))
(define-constant err-value-out-of-range (err u7004))
(define-constant err-not-enough-arguments (err u7005))

;;
;; ==================
;; DATA MAPS AND VARS
;; ==================
;;

(define-non-fungible-token creature-racer-creature-nft uint)

(define-data-var last-token uint u0)

(define-map approvals {     owner: principal,
                            operator: principal } bool)
(define-map token-approvals { owner: principal,
                              token: uint,
                              operator: principal } bool)
    

(define-map free-mint principal bool)
(define-map creature-keys uint (buff 6))
(define-map creature-supply  (buff 6) uint)
(define-map creature-expiry-time uint uint)

(define-map royalties uint uint)
(define-map first-owner uint principal)

(define-map token-uri uint (string-ascii 256))

;; See CreatureLib.sol, partValue
(define-data-var part-value (list 5 uint) 
  (list 
   u4802410000  ;; part 1
   u13583266708 ;; part 2
   u24954054356 ;; part 3
   u38419280000 ;; part 4
   u53692576079 ;; part 5
   )
  )
;;
;; =================
;; PRIVATE FUNCTIONS
;; =================
;;

;; #[allow(unchecked_params)]
(define-private (byte-to-uint (value (buff 1)))
    ;; #[allow(unchecked_data)]
    (let 
        (
         (bytes
          (list 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08
                0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f 0x10 0x11
                0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a
                0x1b 0x1c 0x1d 0x1e 0x1f 0x20 0x21 0x22 0x23
                0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c
                0x2d 0x2e 0x2f 0x30 0x31 0x32 0x33 0x34 0x35
                0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e
                0x3f 0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47
                0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f 0x50
                0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59
                0x5a 0x5b 0x5c 0x5d 0x5e 0x5f 0x60 0x61 0x62
                0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b
                0x6c 0x6d 0x6e 0x6f 0x70 0x71 0x72 0x73 0x74
                0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d
                0x7e 0x7f 0x80 0x81 0x82 0x83 0x84 0x85 0x86
                0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
                0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98
                0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f 0xa0 0xa1
                0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa
                0xab 0xac 0xad 0xae 0xaf 0xb0 0xb1 0xb2 0xb3
                0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc
                0xbd 0xbe 0xbf 0xc0 0xc1 0xc2 0xc3 0xc4 0xc5
                0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce
                0xcf 0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7
                0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf 0xe0
                0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9
                0xea 0xeb 0xec 0xed 0xee 0xef 0xf0 0xf1 0xf2
                0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb
                0xfc 0xfd 0xfe 0xff )
           )
         )
      (unwrap-panic (index-of bytes value))
      )
  )


;; #[allow(unchecked_params)]
(define-private (char-to-uint (value (string-ascii 1)))
    ;; #[allow(unchecked_data)]
    (let 
        (
         (offset u32)
         (chars
          (list 
                " " "!" "\"" "#"
                "$" "%" "&" "'" "(" ")" "*" "+" ","
                "-" "." "/" "0" "1" "2" "3" "4" "5"
                "6" "7" "8" "9" ":" ";" "<" "=" ">"
                "?" "@" "A" "B" "C" "D" "E" "F" "G"
                "H" "I" "J" "K" "L" "M" "N" "O" "P"
                "Q" "R" "S" "T" "U" "V" "W" "X" "Y"
                "Z" "[" "\\" "]" "^" "_" "`" "a" "b"
                "c" "d" "e" "f" "g" "h" "i" "j" "k"
                "l" "m" "n" "o" "p" "q" "r" "s" "t"
                "u" "v" "w" "x" "y" "z" "{" "|" "}"
                "~"
                )
           )
         )
      (match (index-of? chars value)
             i (+ offset i)
             u0)
      )
  )

;; unpack 5 8-bit uint buffer into 5 128-bit uints list.
(define-private (unpack-args (args (buff 5)))
    (list (byte-to-uint (unwrap-panic (element-at args u0)))
          (byte-to-uint (unwrap-panic (element-at args u1)))
          (byte-to-uint (unwrap-panic (element-at args u2)))
          (byte-to-uint (unwrap-panic (element-at args u3)))
          (byte-to-uint (unwrap-panic (element-at args u4))))
  )

(define-private (ascii-char-or-0 (ascii (string-ascii 256))
                                 (index uint))
    (match (element-at? ascii index)
           char (char-to-uint char)
           u0)
  )

;; make-word packs (sub-)string at given index into 128 bit
;; uint. At most 16 characters are packed, 0-padding range
;; overflows.
(define-private (make-word (ascii (string-ascii 256))
                           (index uint))
    (bit-or
     (bit-shift-left (ascii-char-or-0 ascii index)         u120)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u1))  u112)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u2))  u104)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u3))  u96)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u4))  u88)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u5))  u80)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u6))  u72)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u7))  u64)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u8))  u56)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u9))  u48)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u10)) u40)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u11)) u32)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u12)) u24)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u13)) u16)
     (bit-shift-left (ascii-char-or-0 ascii (+ index u14)) u8)
     (ascii-char-or-0 ascii (+ index u15))
     )
  )

;; unpack ascii string as 128-bit uints. Returns list of 16 uints,
;; zero-padded in case string is shorter than max allowed length.
(define-private (ascii-to-uint (ascii (string-ascii 256)))
    (list (make-word ascii u0)   (make-word ascii u16)
          (make-word ascii u32)  (make-word ascii u48)
          (make-word ascii u64)  (make-word ascii u80)
          (make-word ascii u96)  (make-word ascii u112)
          (make-word ascii u128) (make-word ascii u144)
          (make-word ascii u160) (make-word ascii u176)
          (make-word ascii u192) (make-word ascii u208)
          (make-word ascii u224) (make-word ascii u240))
  )

(define-private (make-creature-key (type-id (buff 1))
                                   (parts (buff 5)))
    (concat type-id parts))

;; see mintCap in CreatureLib.sol
(define-private (cap-fold-func (part uint) (prev-cap uint))
    (* prev-cap (* u2 (- u6 part))))

(define-private (compute-cap (parts (list 5 uint)))
     (fold cap-fold-func parts u1)
  )

(define-private (get-block-time)
    ;; The primary reason of defaulting to block height
    ;; is to approximate time for unit tests, at time
    ;; is undefined there.
    (default-to block-height
        (get-block-info? time block-height)))

(define-private (unpack-creature (args (buff 6)))
    { type-id: (byte-to-uint (unwrap-panic (element-at args u0))),
      parts:
      (list 
       (byte-to-uint (unwrap-panic (element-at args u1)))
       (byte-to-uint (unwrap-panic (element-at args u2)))
       (byte-to-uint (unwrap-panic (element-at args u3)))
       (byte-to-uint (unwrap-panic (element-at args u4)))
       (byte-to-uint (unwrap-panic (element-at args u5)))
       )
    })
    

(define-private (part-to-val (part uint))
    (let
        (
         (vals (var-get part-value))
         )
      (default-to u0 (element-at vals part))
      )
  )

(define-private (stack-value (parts (list 5 uint)))
    (fold +
          (map part-to-val parts)
          u0)
  )

;; Check if tx-sender is authorized to transfer token
;; owned by sender.

;; #[allow(unchecked_params)]
(define-private (is-transfer-allowed (token-id uint)
                                     (sender principal))
    (if (is-eq sender tx-sender) true
        (if (default-to false (map-get? approvals
                                        { owner: sender,
                                        operator: tx-sender }))
            true
            (default-to false
                (map-get? token-approvals 
                          { owner: sender,
                          token: token-id,  
                          operator: tx-sender })
              )
            )
        )
  )
            

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;

;;
;; mint a new creature nft
;;
;; Arguments:
;; - nft-id:       nftId id of nft creature
;; - type-id:      typeId id of nft creature
;; - parts:        5-byte buffer describing part stats
;; - expiry:       timestamp of creature expiration
;; - price:        price paid for minting
;; - uri:          uri of metadata for this NFT
;; - operator-sig: backend signature
;; - sender-sig:   sender signature
;;
;; Returns:
;; - (ok true)     on success
;; - (err uint)    on failure (see error code defs)
;;
(define-public (mint (nft-id uint)
                     (type-id (buff 1))
                     (parts (buff 5))
                     (expiry uint)
                     (price uint)
                     (uri (string-ascii 256))
                     (operator-sig (buff 65))
                     (sender-pk (buff 33)))
    (let (
          (sender tx-sender)
          (unpacked-parts (unpack-args parts))
          (signed-args (concat
                        (concat (list nft-id
                                      (byte-to-uint type-id))
                                unpacked-parts)
                        (concat (list expiry
                                      price)
                                (ascii-to-uint uri))
                        
                        ))
          )
      (try! 
       (contract-call? .creature-racer-admin-v5
                       verify-signature
                       operator-sig
                       sender-pk
                       signed-args)
       )
      (if (> price u0)
          (try!
           (contract-call? .creature-racer-payment-v5
                           receive-funds  
                           price)) true)
      (let
          (
           (block-time (get-block-time))
           ;; #[allow(unchecked_data)]
           (creature-key (make-creature-key type-id parts))
           (mint-cap (compute-cap unpacked-parts))
           (supply (default-to u0 
                       (map-get? creature-supply
                                 creature-key)))
           )
        (asserts! (> mint-cap supply) err-mint-cap-exceeded)
        (asserts! (> expiry block-time) 
                  err-expiry-time-in-past)
        
        ;; #[allow(unchecked_data)]
        (try! (nft-mint? 
               creature-racer-creature-nft
               nft-id
               sender))
        (let (
              (plt (var-get last-token))
              )
          (var-set last-token (if (> nft-id plt) nft-id plt))
          )
        (map-set creature-expiry-time nft-id expiry)
        (map-set creature-keys nft-id creature-key)
        (map-set creature-supply creature-key (+ u1
                                                 supply))
        (map-set first-owner nft-id sender)
        (map-set token-uri nft-id uri)
        (ok true)
        )
      )
  )



(define-read-only (is-expired (nft-id uint))
    (let 
        (
         (block-time (get-block-time))
         (creature-expiry 
          (unwrap! (map-get? creature-expiry-time nft-id)
                   err-not-found))
         )
      (ok (< creature-expiry block-time))
      )
  )

;;
;; get-creature-data
;; 
;; Arguments:
;; - nft-id      - token id
;; 
;; Returns:
;; (buff 6)      - type-id followed by part1..part5
;;                 data
(define-read-only (get-creature-data (nft-id uint))
    (match (map-get? creature-keys nft-id)
           v (ok v)
           err-not-found)
  )



;; Returns mint cap of given creature
(define-read-only (get-mint-cap (parts (buff 5)))
    (ok (compute-cap (unpack-args parts)))
  )


;; Returns first owner of NFT creature
(define-read-only (get-first-owner (nft-id uint))
    (ok (unwrap! (map-get? first-owner nft-id) err-not-found)))

;; Set royalty on given creature
(define-public (set-royalty (nft-id uint) 
                            (percentage-points uint))
    (let (
          ;; #[allow(unchecked_data)]          
          (owner (try! (get-first-owner nft-id)))
          )
      (asserts! (is-eq owner tx-sender) err-forbidden)
      (asserts! (<= percentage-points u100) err-value-out-of-range)
      ;; #[allow(unchecked_data)]
      (ok (map-set royalties nft-id percentage-points))
      )
)

(define-read-only (royalty-info (nft-id uint) 
                                (sale-price uint))
    (let (
          (owner (try! (get-first-owner nft-id)))
          (royalty (unwrap! (map-get? royalties nft-id) 
                            err-not-found))
          )
      (ok { owner: owner, 
          royalty: (/ (* sale-price royalty) u10000) })
      )
)

(define-read-only (get-current-owner (nft-id uint))
    (nft-get-owner? creature-racer-creature-nft
                    nft-id))

;;
;; Computing creature staking value (see CreatureLib.sol
;; creatureWeight et al.)
;;
(define-read-only (creature-weight (nft-id uint))
    (let
        (
         (creature (unpack-creature
                    (try! 
                     ;; #[allow(unchecked_data)]
                     (get-creature-data nft-id)
                     )))
         (type-fibbo-weights
          (list u2 u2 u2 u3 u3 u3 u5 u8 u8 u8 u13 
                u13 u13 u21 u34 u34 u34 u55 u55
                u55 u89))
         (type-fibo-weight
          (unwrap! (element-at type-fibbo-weights 
                               (- (get type-id creature)
                                  u1))
                   err-invalid-creature-type))
                      
         )
      (ok
       (/ (* (* u100 type-fibo-weight)
             (stack-value (get parts creature)))
          total-fibbo-weight))
      )
  )

;;
;;
;; part value control
;; ------------------
;;

;;
;; Note: those functions can only be called by contract owner
;;

;;
;; returns (ok (list 5 uint)) current value of part-value
;; variable
(define-read-only (get-part-values)
    (if (is-eq tx-sender contract-owner)
        (ok (var-get part-value))
        err-forbidden)
  )

(define-public (set-part-values (vals (list 5 uint)))
    (if (is-eq tx-sender contract-owner)
        (if (> (len vals) u0)
            (begin
             (var-set part-value vals)
             (ok true)
             ) err-not-enough-arguments)
        
        err-forbidden)
  )
;;
;; Transfer approval management
;;

;; (Dis-)Approve operator for transfer of any NFT owned by
;; tx-sender. 
;; Returns: (ok true)  if setting's successfuly updated.
;;          (ok false) if operator is equal to sender.
(define-public (set-approved-for-all (operator principal)
                                     (approved bool))
    (if (is-eq operator tx-sender)
        (ok false)
        (ok
         ;; #[allow(unchecked_data)]
         (map-set approvals { owner: tx-sender,
                  operator: operator } approved)))
  )
  
;; (Dis-)Approve operator for transfer of given NFT owned
;; by tx-sender. 
;; Returns: (ok true)  if setting's successfuly updated.
;;          (ok false) if operator is equal to sender.
;;          (err u403) if sender doesn't own the NFT.
(define-public (approve (operator principal)
                        (token uint)
                        (approved bool))
    (if (is-eq (some tx-sender)
               (nft-get-owner? creature-racer-creature-nft
                               token))
        (if (is-eq operator tx-sender)
            (ok false)
            (ok
             ;; #[allow(unchecked_data)]
             (map-set token-approvals { owner: tx-sender,
                      token: token,
                      operator: operator }
                      approved))
            )
        err-forbidden
        )
  )


(define-public (set-uri (token-id uint)
                        (uri (string-ascii 256)))
    (begin
     (try! (contract-call? .creature-racer-admin-v5
                           assert-invoked-by-operator))
     (map-set token-uri token-id uri)
     (ok true)
     )
  )

;;
;; Functions required by nft-trait
;; -------------------------------
;;

(define-read-only (get-last-token-id)
    (ok (var-get last-token)))

(define-read-only (get-token-uri (token-id uint))
    (ok (map-get? token-uri token-id)))

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? creature-racer-creature-nft token-id))
  )

(define-public (transfer (token-id uint) (sender principal)
                         (recipient principal))
    (if (is-transfer-allowed token-id sender)
        ;; #[allow(unchecked_data)]
        (begin
         (unwrap!
          (nft-transfer? creature-racer-creature-nft
                         token-id
                         sender
                         recipient)
          err-forbidden)
         (map-delete token-approvals
                     { owner: sender, 
                       token: token-id,
                       operator: tx-sender })
         (ok true)
         )
        err-forbidden
        )
  )
