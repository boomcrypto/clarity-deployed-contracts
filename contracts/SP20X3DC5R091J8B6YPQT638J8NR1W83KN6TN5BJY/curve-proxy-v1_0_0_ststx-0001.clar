;;; proxy staking protocol parameters
;;; can upgrade target contract addresses but units must not change

(impl-trait .curve-proxy-trait_ststx.curve-proxy-trait)

(define-public
 (get-ratio)
 (contract-call?
  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v1
  get-stx-per-ststx
  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1))

;;; eof
