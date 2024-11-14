---
title: "Trait path-db_v1_0_0"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; max 2047 edge tuples
(define-constant MAX-EDGES    u250) ;;effectively max nr of pools (stx -> *)
(define-constant MAX-PATH-LEN u4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pool types
(define-constant UNIV2   "u")
(define-constant UNIV2V2 "v")
(define-constant CURVE   "c")

(define-read-only
  (is-kind (kind (string-ascii 1)))
  (or (is-eq kind UNIV2) (is-eq kind UNIV2V2) (is-eq kind CURVE)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; edges
(define-read-only
  (mkedge
   (kind          (string-ascii 1))
   (contract       principal)
   (id             uint)
   (from           principal)
   (to             principal)
   (from-is-token0 bool))
  {a:kind,b:contract,c:id,d:from,e:to,f:from-is-token0})

(define-read-only
  (cons
   (x            {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (xs (list 250 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
  (unwrap-panic (as-max-len? (concat (list x) xs) u250)) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; storage
(define-map EDGES
  principal
  (list 250 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool} ))

(define-private
  (do-insert
   (kind     (string-ascii 1))
   (contract principal)
   (id       uint)
   (token0   principal)
   (token1   principal))
  (let ((es0 (do-lookup token0))
        (es1 (do-lookup token1))
        (e0  (mkedge kind contract id token0 token1 true))
        (e1  (mkedge kind contract id token1 token0 false)))
    (map-set EDGES token0 (cons e0 es0))
    (map-set EDGES token1 (cons e1 es1))
    (ok true) ))

(define-read-only
  (do-lookup (from principal))
  (default-to (list) (map-get? EDGES from)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ownership
(define-data-var owner principal tx-sender)
(define-read-only (get-owner) (var-get owner))
(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller (get-owner)) (err u403))))
(define-public (set-owner (new-owner principal))
  (begin
   (try! (check-owner))
   (ok (var-set owner new-owner))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; api
(define-public
  (insert
   (kind     (string-ascii 1))
   (contract principal)
   (id       uint)
   (token0   principal)
   (token1   principal))
  (begin
   (unwrap-panic (check-owner))
   (asserts! (is-kind kind) (err u0))
   (do-insert kind contract id token0 token1)))

(define-public
 (import
  (kind (string-ascii 1))
  (id   uint))
 (begin
  (unwrap-panic (check-owner))
  (if (is-eq kind UNIV2)   (do-import-core id)
  (if (is-eq kind UNIV2V2) (do-import-univ2-v1_0_0 id)
  (if (is-eq kind CURVE)   (do-import-curve-v1_1_0 id)
  (err u0) ))) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; import
(define-constant IDS
  (list
   u1 u2 u3 u4 u5 u6 u7 u8 u9
   u10 u11 u12 u13 u14 u15 u16 u17 u18 u19
   u20 u21 u22 u23 u24 u25 u26 u27 u28 u29
   u30 u31 u32 u33 u34 u35 u26 u37 u38 u39
   u40 u41 u42 u43 u44 u45 u46 u47 u48 u49
   u50 u51 u52 u53 u54 u55 u56 u57 u58 u59
   u60 u61 u62 u63 u64 u65 u66 u67 u68 u69
   u70 u71 u72 u73 u74 u75 u76 u77 u78 u79
   u80 u81 u82 u83 u84 u85 u86 u87 u88 u89
   u90 u91 u92 u93 u94 u95 u96 u97 u98 u99
   ))

;; v1/legacy pools
(define-private (import-core) (map do-import-core IDS))

(define-private
  (do-import-core (id uint))
  (let ((p (contract-call? .univ2-core get-pool id)))
    (match p
     pool (do-insert UNIV2 .univ2-core id (get token0 pool) (get token1 pool))
     (ok true)) ))

;; usdh
(define-private (import-curve-v1_1_0) (map do-import-curve-v1_1_0 IDS))

(define-private
  (do-import-curve-v1_1_0 (id uint))
  (let ((p (contract-call? .curve-registry_v1_1_0 get-pool id)))
    (match p
     pool (do-insert CURVE (get contract pool) id (get token0 pool) (get token1 pool))
     (ok true)) ))

;; univ2v2 initial deploy/new tokens
(define-private (import-univ2-v1_0_0) (map do-import-univ2-v1_0_0 IDS))

(define-private
 (do-import-univ2-v1_0_0 (id uint))
 (let ((p (contract-call? .univ2-registry_v1_0_0 get-pool id)))
   (match p
    pool (do-insert UNIV2 (get contract pool) id (get token0 pool) (get token1 pool))
    (ok true)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-private
 (doit)
 (begin
  (import-core)
  (import-curve-v1_1_0)
  (import-univ2-v1_0_0)
  ))

(doit)

;;; eof

```
