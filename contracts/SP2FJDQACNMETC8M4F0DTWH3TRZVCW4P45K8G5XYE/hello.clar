(define-public (hello (foo (string-utf8 100)) (bar (optional (string-utf8 100))) )
    (ok (print (concat (concat u"hello" foo) (if (is-some bar) (unwrap-panic bar) u""))))
)