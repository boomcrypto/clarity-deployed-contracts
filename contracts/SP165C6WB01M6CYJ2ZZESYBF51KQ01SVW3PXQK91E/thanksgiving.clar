;; THANKSGIVING TRAIT

(define-trait thanksgiving
  ((slice? (int)
     (response (optional (string-ascii 80)) uint))
   (spice? (int)
     (response (optional (string-ascii 80)) uint))
   (dice? (int)
     (response (optional (string-ascii 80)) uint))
   (mice? (int)
     (response (optional (string-ascii 80)) uint))))
