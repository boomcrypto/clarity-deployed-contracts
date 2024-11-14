---
title: "Trait path-find_v1_1_0"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; max 2047 edge tuples
(define-constant MAX-EDGES    u250) ;;effectively max nr of pools (stx -> *)
(define-constant MAX-PATH-LEN u4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; db
(define-read-only
  (roots (node principal))
  (map mkpath (contract-call? .path-db_v1_1_0 do-lookup node))) ;;XXX: version

(define-read-only
  (descendants
   (path (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
  (let ((d0 (contract-call? .path-db_v1_1_0 do-lookup (to (last path))))) ;;XXX: version
    (get acc (fold descendants1 d0 {last: (last path), acc: (list)})) ))

(define-read-only
 (descendants1
  (elt              {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
  (state
   {last:           {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool},
    acc : (list 250 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}),
   }) )
 (if (and (is-eq (token0 elt) (token0 (get last state)))
          (is-eq (token1 elt) (token1 (get last state))))
     state
     (merge state {acc: (cons elt (get acc state))})) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; edges
(define-read-only
  (kind (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (get a edge))
(define-read-only
  (contract (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (get b edge))
(define-read-only
  (id (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (get c edge))
(define-read-only
  (from (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (get d edge))
(define-read-only
  (to (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (get e edge))
(define-read-only
  (from-is-token0 (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (get f edge))

(define-read-only
 (token0 (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
 (if (get f edge)
     (get d edge)
   (get e edge)))
(define-read-only
 (token1 (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
 (if (get f edge)
     (get e edge)
   (get d edge)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; paths

;; edge -> path
(define-read-only
  (mkpath (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (unwrap-panic (as-max-len? (list edge) u4)))

;; path -> edge
(define-read-only
  (last (path (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
  (unwrap-panic (element-at? path (- (len path) u1))))

;; edge + edges
(define-read-only
 (cons
  (x            {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
  (xs (list 250 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
 (unwrap-panic (as-max-len? (concat (list x) xs) u250)) )

;; path + edge
(define-read-only
  (snoc
   (xs (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (x          {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (unwrap-panic (as-max-len? (append xs x) u4)))

;; paths + path
(define-read-only
  (cat
   (xss (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
   (xs            (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
  (unwrap-panic (as-max-len? (append xss xs) u250)))

;; paths + paths
(define-read-only
  (conc
   (xss (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
   (yss (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))))
  (unwrap-panic
   (as-max-len?
    (concat xss yss)
    u250)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pruning
(define-read-only
  (partition
   (paths (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
   (to_   principal))
  (fold partition1 paths {open: (list), closed: (list), to: to_}))

(define-read-only
 (partition1
  (path               (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (state
   {open  : (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})),
    closed: (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})),
    to    : principal
   }))
 (if (is-eq (to (last path)) (get to state))
     (merge state {closed: (cat (get closed state) path)})
     (merge state {open  : (cat (get open   state) path)})))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cycles
(define-read-only
 (is-cycle
  (path (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (elt          {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
 (get res (fold is-cycle1 path {res: false, elt: elt})))

(define-read-only
 (is-cycle1
  (elt   {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
  (state
   {res: bool,
    elt: {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}
   }))
 ;; XXX: needs changes if we have duplicate pools (eg v1/v2)
 (merge
  state
  {res: (if (and (is-eq (token0 elt) (token0 (get elt state)))
                 (is-eq (token1 elt) (token1 (get elt state))))
            true
            (get res state))}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only
  (find
   (from_ principal)
   (to_   principal))
  (let ((p1 (find0 from_ to_))
        (p2 (find1 (get open p1) to_))
        (p3 (find1 (get open p2) to_))
        (p4 (find1 (get open p3) to_)))
    (conc
     (conc
      (conc
       (get closed p1)
       (get closed p2))
      (get closed p3))
     (get closed p4))
    ))

(define-read-only
  (find0 (from_ principal) (to_ principal))
  (partition (roots from_) to_))

(define-read-only
  (find1
   (paths (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})))
   (to_   principal))
  (partition (fold find2 paths (list)) to_))

(define-read-only
  (find2
   (path          (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (acc (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))))
  (let ((d (descendants path)))
    (if (is-eq (len d) u0)
        acc ;;remove path
        (conc acc (get acc (fold find3 d {acc: (list), path: path}))) )))

(define-read-only
  (find3
   (elt                      {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (state
    {acc : (list 250 (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})),
     path:           (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}),
    }))
  (merge
   state
   {acc : (if (is-cycle (get path state) elt)
              (get acc state)
              (cat (get acc state) (snoc (get path state) elt)))}))

;;; eof

```
