(define-non-fungible-token XXXtentation uint)

;; Public functions
(define-constant nft-not-owned-err (err u401)) ;; unauthorized
(define-constant nft-not-found-err (err u404)) ;; not found
(define-constant sender-equals-recipient-err (err u405)) ;; method not allowed

(define-private (nft-transfer-err (code uint))
  (if (is-eq u1 code)
    nft-not-owned-err
    (if (is-eq u2 code)
      sender-equals-recipient-err
      (if (is-eq u3 code)
        nft-not-found-err
        (err code)))))

;; Transfers tokens to a specified principal.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender (unwrap! (nft-get-owner? XXXtentation token-id) nft-not-found-err))
        (is-eq tx-sender sender)
        (not (is-eq recipient sender)))
       (match (nft-transfer?  XXXtentation token-id sender recipient)
        success (ok success)
        error (nft-transfer-err error))
      nft-not-owned-err))

;; Gets the owner of the specified token ID.
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner?  XXXtentation token-id)))

;; Gets the owner of the specified token ID.
(define-read-only (get-last-token-id)
  (ok u1))

(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://yh-prod-redeem.s3.dualstack.us-east-1.amazonaws.com/xxxtentaction_drop1/i%20spoke%20to%20the%20devil%20in%20miami.mp3?X-Amz-Security-Token=IQoJb3JpZ2luX2VjECEaCXVzLWVhc3QtMSJHMEUCIQCFpnlzVDBHjzqoL0TGHjlY61cGhpcyvyWmXNCEOE7yVQIgXcgude7boc36lPKL%2FRtsp5I140EypGPrL1DpeHda%2BPcqvQMIqf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARABGgwwMzQ2OTM3Mjc4NjAiDARsWamdl3EM5iH%2BZyqRAy9w4NAmk2RCI8XCtO7kAumsCtnV6h0fvSJPzfPTds6kul7Z2yXGvywt2oxByF1GZ3CmmkAHumdGWLbQ%2FAOHjIU7XYEeExlAUc00ZaVH6PCA%2BTQ5vT498D%2BDt%2FHZV0quvDRy0%2BbFjqzCCMM6bDavpjaQyRJoyJJducZPvuu6VAc%2Fro%2F0NOX%2FkZgVbpZ%2F86Epi%2F%2F%2Fd5vQBi6IpezaUDVcXh8JjPH4SHlnxkkHcsDKOdMhAWiZRggpH%2FgtKTTyiTQF08gEG6odV0vmWhyPgKbXPmMXAHzFprMU6Pj1ChfBEVxD4Kt05ea%2FZwq4Lu3XF4CwcCa%2F%2BWnGoP9eCOcGSrkmDQ1MZ52RYo%2B6%2FnM0fgHgPOKOsXZ3aHTWqRMTkhY6G5plz%2Fvqa78IRJQ7VYE%2BhsiDo7iL0vBLeGrDkMs3kxUmGBjFr5nxQi8yHMZnXfo3L2%2Feju9n6QS4LQg9ZwGPGQaomPWkwNNjxqlX8jxUjXV1r1nsMqZF9t5Evka2mqsM7rBdihoacnF5QqLKObyxW2Cvs82tMILX6oQGOusBbAS5HROXv24Zs1TDi%2BygPTaQnyif5YFCPtDbh2k805z41xn2I8vL0s3gczCrVdCyuvC63SRF%2BG1fob%2F7sv9UPqd3QpbzxCEUmGIhzEtm8%2BADwTprw2cHCET6Qk5QVnNB9CpygLUA1%2BfWe5WmPsytKa0vhE0WRD8IxZzzZ4eZIK9q6etyK972U9T31uYGxcRVu1k%2FEeW4rMBvtXEmh2HZb8ao7nRPqUvByTaRXHzgK%2Fl%2F8s5eH5xVrM1K5220mI4EOliVAg4nOsHbbJaWkHsn4Kpi7AWC4QnR7bDD%2F%2B8fDfq%2BMo70u9kDZHs6Ww%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20210511T170143Z&X-Amz-SignedHeaders=host&X-Amz-Expires=299&X-Amz-Credential=ASIAQQE7IIZ2GKN3EZ4D%2F20210511%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=9ce7d555e98047c4b1fc12d5b9a87037588c5e197074a1d5317eb9364ad61bfe")))

(define-read-only (get-errstr (code uint))
  (ok (if (is-eq u401 code)
    "nft-not-owned"
    (if (is-eq u404 code)
      "nft-not-found"
      (if (is-eq u405 code)
        "sender-equals-recipient"
        "unknown-error")))))

;; Initialize the contract
(try! (nft-mint? XXXtentation  u1 tx-sender))