---
title: "Trait test-21"
draft: true
---
```
;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)

;;(define-data-var holders (string-ascii 256) "hi")


;;;;;;;;;;;;;;

(define-read-only (get-vault-by-id (vault-id uint))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vault-data-v1-1 get-vault-by-id vault-id)
)


(define-read-only (get-debt-for-vault (vault-id uint))
  (let ((vault (get-vault-by-id vault-id))) (ok (get debt vault)))
)

(print (get-vault-by-id u1901))
(print (get-vault-by-id u1902))
(print (get-vault-by-id u1903))
(print (get-vault-by-id u1904))
(print (get-vault-by-id u1905))
(print (get-vault-by-id u1906))
(print (get-vault-by-id u1907))
(print (get-vault-by-id u1908))
(print (get-vault-by-id u1909))
(print (get-vault-by-id u1910))
(print (get-vault-by-id u1911))
(print (get-vault-by-id u1912))
(print (get-vault-by-id u1913))
(print (get-vault-by-id u1914))
(print (get-vault-by-id u1915))
(print (get-vault-by-id u1916))
(print (get-vault-by-id u1917))
(print (get-vault-by-id u1918))
(print (get-vault-by-id u1919))
(print (get-vault-by-id u1920))
(print (get-vault-by-id u1921))
(print (get-vault-by-id u1922))
(print (get-vault-by-id u1923))
(print (get-vault-by-id u1924))
(print (get-vault-by-id u1925))
(print (get-vault-by-id u1926))
(print (get-vault-by-id u1927))
(print (get-vault-by-id u1928))
(print (get-vault-by-id u1929))
(print (get-vault-by-id u1930))
(print (get-vault-by-id u1931))
(print (get-vault-by-id u1932))
(print (get-vault-by-id u1933))
(print (get-vault-by-id u1934))
(print (get-vault-by-id u1935))
(print (get-vault-by-id u1936))
(print (get-vault-by-id u1937))
(print (get-vault-by-id u1938))
(print (get-vault-by-id u1939))
(print (get-vault-by-id u1940))
(print (get-vault-by-id u1941))
(print (get-vault-by-id u1942))
(print (get-vault-by-id u1943))
(print (get-vault-by-id u1944))
(print (get-vault-by-id u1945))
(print (get-vault-by-id u1946))
(print (get-vault-by-id u1947))
(print (get-vault-by-id u1948))
(print (get-vault-by-id u1949))
(print (get-vault-by-id u1950))
```