(define-constant pyth-oracle 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-oracle-v2)
(define-constant pyth-storage 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-store-v1)
(define-constant pyth-decoder 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-pnau-decoder-v1)
(define-constant wormhole-core 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.wormhole-core-v2)

(define-constant ERR-PYTH-UPDATE-FAILED (err u1200))
(define-constant ERR-PYTH-READ-FAILURE (err u1300))

(define-public (update-price (vaa-buffer (buff 8192)))
  (contract-call? 
      pyth-oracle ;; contract principal
      verify-and-update-price-feeds ;; function name
      vaa-buffer
      {
        pyth-storage-contract: pyth-storage,
        pyth-decoder-contract: pyth-decoder,
        wormhole-core-contract: wormhole-core
      }    
    )
)

(define-public (read-from-pyth (price-id (buff 32))) 
  (let 
    (
      (feed (contract-call? pyth-oracle read-price-feed price-id pyth-storage))
      (unwrapped-feed (unwrap! feed ERR-PYTH-READ-FAILURE))
      (price (get price unwrapped-feed))
    )
    (ok (to-uint price))
  )
)