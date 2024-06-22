;; title: xcall
;; description: Test contract for https://xcall.top

;; Trim of sip-010-trait
(define-trait brief-trait
  (
    (get-name () (response (string-ascii 32) uint))
  )
)


(define-constant CONSTANT_1 u1)
(define-constant CONSTANT_2 "Hello World!")


;;;;;;;;;; Variables ;;;;;;;;;;
;; atom
(define-data-var m_int int 2009)
(define-data-var m_uint uint u2024)
(define-data-var m_bool bool true)
(define-data-var m_principal principal tx-sender)
(define-data-var m_buff (buff 128) 0x5468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73)
(define-data-var m_ascii (string-ascii 128) "``... to be a completely separate network and separate block chain, yet share CPU power with Bitcoin`` - Satoshi Nakamoto")
(define-data-var m_utf8 (string-utf8 128) u"A smiley face emoji \u{1F600} as a utf8 string")
;; list
(define-data-var m_list_int (list 10 int) (list 1 2 3 4 5 6 7 8 9 10))
(define-data-var m_list_uint (list 10 uint) (list u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
(define-data-var m_list_bool (list 10 bool) (list true false true false true false true false true false))
(define-data-var m_list_principal (list 10 principal) (list tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender))
(define-data-var m_list_buff (list 10 (buff 32)) (list 0x61 0x62 0x6363 0x61 0x62 0x6363 0x61 0x62 0x6363 0x6566))
(define-data-var m_list_ascii (list 10 (string-ascii 32)) (list "a" "b" "hi" "tmp" "test" "hello" "world"))
(define-data-var m_list_utf8 (list 10 (string-utf8 32)) (list u"a" u"b" u"face emoji \u{1F600}" u"hi"))
(define-data-var m_list_list_uint (list 10 (list 10 uint)) (list (list u1) (list u1 u2) (list u3 u4 u5)))
(define-data-var m_list_list_buff (list 10 (list 10 (buff 10))) (list (list 0x65) (list 0x66 0x67) (list 0x6868 0x697071 0x72737475)))
(define-data-var m_list_list_ascii (list 10 (list 10 (string-ascii 10))) (list (list "a") (list "b" "cd") (list "hi" "bar" "foo") (list "just" "a" "test")))
(define-data-var m_list_optional (list 10 (optional uint)) (list (some u1) none (some u2) none (some u3)))
;; tuple
(define-data-var m_tuple_int { count: int } { count: 10 })
(define-data-var m_tuple_uint { count: uint } { count: u20 })
(define-data-var m_tuple_bool { allow: bool } { allow: true })
(define-data-var m_tuple_principal { user: principal } { user: tx-sender })
(define-data-var m_tuple_buff { msg: (buff 20) } { msg: 0x5361746f736869 })
(define-data-var m_tuple_ascii { msg: (string-ascii 20) } { msg: "Bitcoin" })
(define-data-var m_tuple_utf8 { msg: (string-utf8 20) } { msg: u"Nakamoto\u{1F600}" })
(define-data-var m_tuple_list_uint { lu: (list 10 uint) } { lu: (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) })
(define-data-var m_tuple_list_buff { lb: (list 10 (buff 10)) } { lb: (list 0x61 0x6262 0x636465) })
(define-data-var m_tuple_list_ascii { la: (list 10 (string-ascii 10)) } { la: (list "a" "bb" "cde") })
(define-data-var m_tuple_misc { name: (string-ascii 32), age: uint, desc: (buff 128), mints: (list 10 uint) } { name: "Satoshi", age: u15, desc: 0x616e6f6e796d6f7573, mints: (list u50 u50 u50) })
;; optional
(define-data-var m_optional_none_1 (optional int) none)
(define-data-var m_optional_none_2 (optional principal) none)
(define-data-var m_optional_none_3 (optional (list 10 uint)) none)
(define-data-var m_optional_int (optional int) (some 2009))
(define-data-var m_optional_uint (optional uint) (some u2024))
(define-data-var m_optional_bool (optional bool) (some true))
(define-data-var m_optional_principal (optional principal) (some tx-sender))
(define-data-var m_optional_buff (optional (buff 128)) (some 0x546865205469))
(define-data-var m_optional_ascii (optional (string-ascii 128)) (some "Satoshi Nakamoto"))
(define-data-var m_optional_utf8 (optional (string-utf8 128)) (some u"Face emoji \u{1F600} as a utf8 string"))
(define-data-var m_optional_list (optional (list 10 uint)) (some (list u1 u2 u3)))

;; (response ok-type err-type)
(define-data-var m_response_bool_uint_ok (response bool uint) (ok true))
(define-data-var m_response_bool_uint_fail (response bool uint) (err u1001))
(define-data-var m_response_bool_int_ok (response bool int) (ok true))
(define-data-var m_response_bool_int_fail (response bool int) (err 2001))
(define-data-var m_response_list10uint_principal_ok (response (list 10 uint) principal) (ok (list u1 u2 u3)))
(define-data-var m_response_list10uint_list10ascii10_err (response (list 10 uint) (list 10 (string-ascii 10))) (err (list "err1" "err2" "err3")))


;;;;;;;;;; Read-only functions ;;;;;;;;;;
(define-read-only (get_constant) CONSTANT_1)
;; atom
(define-read-only (get_int (value int)) (+ value 1))
(define-read-only (get_uint (value uint)) (+ value u1))
(define-read-only (get_bool (value bool)) (not value))
(define-read-only (get_principal (value principal)) value)
(define-read-only (get_buff (value (buff 32))) (unwrap-panic (as-max-len? (concat value 0x61) u33)))
(define-read-only (get_ascii (value (string-ascii 32))) (unwrap-panic (as-max-len? (concat value "?") u33)))
(define-read-only (get_utf8 (value (string-utf8 32))) (unwrap-panic (as-max-len? (concat value u"!") u33)))
;; list
(define-read-only (get_list_int (value (list 10 int))) (unwrap-panic (as-max-len? (concat value (list 999)) u11)))
(define-read-only (get_list_uint (value (list 10 uint))) (unwrap-panic (as-max-len? (concat value (list u1000)) u11)))
(define-read-only (get_list_bool (value (list 10 bool))) (unwrap-panic (as-max-len? (concat value (list true)) u11)))
(define-read-only (get_list_principal (value (list 10 principal))) (unwrap-panic (as-max-len? (concat value (list tx-sender)) u11)))
(define-read-only (get_list_buff (value (list 10 (buff 32)))) (unwrap-panic (as-max-len? (concat value (list 0x6161)) u11)))
(define-read-only (get_list_ascii (value (list 10 (string-ascii 32)))) (unwrap-panic (as-max-len? (concat value (list "abc")) u11)))
(define-read-only (get_list_utf8 (value (list 10 (string-utf8 32)))) (unwrap-panic (as-max-len? (concat value (list u"def")) u11)))
(define-read-only (get_list_optional (value (list 10 (optional uint)))) (unwrap-panic (as-max-len? (concat value (list (some u1001) none (some u1002))) u13)))
;; tuple
(define-read-only (get_tuple_int (value { count: int })) (merge value { count: (+ (get count value) 1) }))
(define-read-only (get_tuple_uint (value { count: uint })) (merge value { count: (+ (get count value) u1) }))
(define-read-only (get_tuple_bool (value { allow: bool })) (merge value { allow: (not (get allow value)) }))
(define-read-only (get_tuple_principal (value { user: principal })) (merge value { user: tx-sender }))
(define-read-only (get_tuple_buff (value { msg: (buff 20) })) (merge value { msg: (unwrap-panic (as-max-len? (concat (get msg value) 0x61) u21)) }))
(define-read-only (get_tuple_ascii (value { msg: (string-ascii 20) })) (merge value { msg: (unwrap-panic (as-max-len? (concat (get msg value) "?") u21)) }))
(define-read-only (get_tuple_utf8 (value { msg: (string-utf8 20) })) (merge value { msg: (unwrap-panic (as-max-len? (concat (get msg value) u"!") u21)) }))
(define-read-only (get_tuple_list_uint (value { ll: (list 20 uint) })) (merge value { ll: (unwrap-panic (as-max-len? (concat (get ll value) (list u1000)) u21)) }))
(define-read-only (get_tuple_list_buff (value { ll: (list 20 (buff 32)) })) (merge value { ll: (unwrap-panic (as-max-len? (concat (get ll value) (list 0x61)) u21)) }))
(define-read-only (get_tuple_list_ascii (value { ll: (list 20 (string-ascii 32)) })) (merge value { ll: (unwrap-panic (as-max-len? (concat (get ll value) (list "?")) u21)) }))
(define-read-only (get_tuple_misc (value { name: (string-ascii 32), age: uint, desc: (buff 128), mints: (list 10 uint) })) (merge value { age: (+ (get age value) u1) }))
;; optional
(define-read-only (get_optional_none) none)
(define-read-only (get_optional_int (value (optional int))) (if (is-some value) (some (+ (unwrap-panic value) 1)) none))
(define-read-only (get_optional_uint (value (optional uint))) (if (is-some value) (some (+ (unwrap-panic value) u1)) none))
(define-read-only (get_optional_bool (value (optional bool))) (if (is-some value) (some (not (unwrap-panic value))) none))
(define-read-only (get_optional_principal (value (optional principal))) (if (is-some value) (some (unwrap-panic value)) none))
(define-read-only (get_optional_buff (value (optional (buff 32)))) (if (is-some value) (some (unwrap-panic (as-max-len? (concat (unwrap-panic value) 0x61) u33))) none))
(define-read-only (get_optional_ascii (value (optional (string-ascii 32)))) (if (is-some value) (some (unwrap-panic (as-max-len? (concat (unwrap-panic value) "?") u33))) none))
(define-read-only (get_optional_utf8 (value (optional (string-utf8 32)))) (if (is-some value) (some (unwrap-panic (as-max-len? (concat (unwrap-panic value) u"!") u33))) none))
(define-read-only (get_optional_list (value (optional (list 10 uint)))) (if (is-some value) (some (unwrap-panic (as-max-len? (concat (unwrap-panic value) (list u1000)) u11))) none))
;; trait
(define-read-only (get_trait_direct (value <brief-trait>)) (ok value))
(define-read-only (get_trait_list (value (list 10 <brief-trait>))) (ok value))
(define-read-only (get_trait_optional (value (optional <brief-trait>))) (ok value))


;;;;;;;;;; Public functions ;;;;;;;;;;
(define-public (set_empty) (begin (print "set_empty") (ok true)))
;; atom
(define-public (set_int (value int)) (begin (print { value: value }) (ok true)))
(define-public (set_uint (value uint)) (begin (print { value: value }) (ok true)))
(define-public (set_bool (value bool)) (begin (print { value: value }) (ok true)))
(define-public (set_principal (value principal)) (begin (print { value: value }) (ok true)))
(define-public (set_buff (value (buff 32))) (begin (print { value: value }) (ok true)))
(define-public (set_ascii (value (string-ascii 32))) (begin (print { value: value }) (ok true)))
(define-public (set_utf8 (value (string-utf8 32))) (begin (print { value: value }) (ok true)))
;; list
(define-public (set_list_int (value (list 10 int))) (begin (print { value: value }) (ok true)))
(define-public (set_list_uint (value (list 10 uint))) (begin (print { value: value }) (ok true)))
(define-public (set_list_bool (value (list 10 bool))) (begin (print { value: value }) (ok true)))
(define-public (set_list_principal (value (list 10 principal))) (begin (print { value: value }) (ok true)))
(define-public (set_list_buff (value (list 10 (buff 32)))) (begin (print { value: value }) (ok true)))
(define-public (set_list_ascii (value (list 10 (string-ascii 32)))) (begin (print { value: value }) (ok true)))
(define-public (set_list_utf8 (value (list 10 (string-utf8 32)))) (begin (print { value: value }) (ok true)))
(define-public (set_list_optional (value (list 10 (optional uint)))) (begin (print { value: value }) (ok true)))
;; tuple
(define-public (set_tuple_int (value { count: int })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_uint (value { count: uint })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_bool (value { allow: bool })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_principal (value { user: principal })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_buff (value { msg: (buff 20) })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_ascii (value { msg: (string-ascii 20) })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_utf8 (value { msg: (string-utf8 20) })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_list_uint (value { ll: (list 20 uint) })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_list_buff (value { ll: (list 20 (buff 32)) })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_list_ascii (value { ll: (list 20 (string-ascii 32)) })) (begin (print { value: value }) (ok true)))
(define-public (set_tuple_misc (value { name: (string-ascii 32), age: uint, desc: (buff 128), mints: (list 10 uint) })) (begin (print { value: value }) (ok true)))
;; optional
(define-public (set_optional_int (value (optional int))) (begin (print { value: value }) (ok true)))
(define-public (set_optional_uint (value (optional uint))) (begin (print { value: value }) (ok true)))
(define-public (set_optional_bool (value (optional bool))) (begin (print { value: value }) (ok true)))
(define-public (set_optional_principal (value (optional principal))) (begin (print { value: value }) (ok true)))
(define-public (set_optional_buff (value (optional (buff 32)))) (begin (print { value: value }) (ok true)))
(define-public (set_optional_ascii (value (optional (string-ascii 32)))) (begin (print { value: value }) (ok true)))
(define-public (set_optional_utf8 (value (optional (string-utf8 32)))) (begin (print { value: value }) (ok true)))
(define-public (set_optional_list (value (optional (list 10 uint)))) (begin (print { value: value }) (ok true)))
;; trait
(define-public (set_trait_direct (value <brief-trait>)) (begin (print { value: value }) (ok true)))
(define-public (set_trait_list (value (list 10 <brief-trait>))) (begin (print { value: value }) (ok true)))
(define-public (set_trait_optional (value (optional <brief-trait>)) (intValue uint)) (begin (print { value: value }) (ok true)))


;;;;;;;;;; Maps ;;;;;;;;;;
;; map
(define-map map_int_bool int bool)
(define-map map_uint_bool uint bool)
(define-map map_uint_uint uint uint)
(define-map map_principal_bool principal bool)
(define-map map_principal_uint principal uint)
(define-map map_uint_tuple
    uint
    {
        user: principal,
        value: uint,
    }
)
(define-map map_tuple1_tuple
    { id: uint }
    {
        user: principal,
        value: uint,
    }
)
(define-map map_tuple_misc_2_tuple_misc
    { intValue: int, uintValue: uint, user: principal }
    {
        intValue: int,
        uintValue: uint,
        boolValue: bool,
        principalValue: principal,
        buffValue: (buff 32),
        asciiValue: (string-ascii 32),
        utf8Value: (string-utf8 32),
        listValue: (list 10 uint),
        optionalValue: (optional uint),
        tupleValue: { tupleInt: uint, tupleList: (list 10 uint) }
    }
)

;; init maps
(map-set map_int_bool 1 true)
(map-set map_uint_bool u1 true)
(map-set map_uint_uint u1 u100)
(map-set map_principal_bool tx-sender true)
(map-set map_principal_uint tx-sender u1)
(map-set map_uint_tuple u1 { user: tx-sender, value: u100 })
(map-set map_tuple1_tuple { id: u2 } { user: tx-sender, value: u100 })
(map-set map_tuple_misc_2_tuple_misc
  { intValue: 1, uintValue: u2, user: tx-sender }
    {
        intValue: 3,
        uintValue: u4,
        boolValue: true,
        principalValue: tx-sender,
        buffValue: 0x616263,
        asciiValue: "satoshi",
        utf8Value: u"nakamoto",
        listValue: (list u100 u200 u300),
        optionalValue: (some u10),
        tupleValue: { tupleInt: u1000, tupleList: (list u1001 u1002 u1003) }
    }
)

;; get value by key
(define-read-only (get_map_int_bool (key int)) (map-get? map_int_bool key))
(define-read-only (get_map_uint_bool (key uint)) (map-get? map_uint_bool key))
(define-read-only (get_map_uint_uint (key uint)) (map-get? map_uint_uint key))
(define-read-only (get_map_principal_bool (key principal)) (map-get? map_principal_bool key))
(define-read-only (get_map_principal_uint (key principal)) (map-get? map_principal_uint key))
(define-read-only (get_map_uint_tuple (key uint)) (map-get? map_uint_tuple key))
(define-read-only (get_map_tuple1_tuple (key { id: uint })) (map-get? map_tuple1_tuple key))
(define-read-only (get_map_tuple_misc_2_tuple_misc (key { intValue: int, uintValue: uint, user: principal })) (map-get? map_tuple_misc_2_tuple_misc key))
