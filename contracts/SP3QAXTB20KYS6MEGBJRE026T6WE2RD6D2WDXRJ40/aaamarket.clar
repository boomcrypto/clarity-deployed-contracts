(define-constant ERR_NO_AUTHORITY 8001)
(define-constant ERR_FEE_INVALID 8002)
(define-constant ERR_TRANSFER_STX 8003)
(define-constant ERR_PRICE_INVALID 8004)
(define-constant ERR_PRICE_NOT_SAME 8005)
(define-constant ERR_BALANCE_UNENOUGH 8006)
(define-constant ERR_BNS_RESOLVE_FAIL 8307)
(define-constant ERR_PRINCIPAL_ALREADY_ASSOCIATED 8008)
;;
(define-constant ERR_BID_EXPIRED 8201)
(define-constant ERR_BID_TOO_MANY 8202)
(define-constant ERR_BID_NOT_FOUND 8203)
(define-constant ERR_BID_POS_NOT_SAME 8204)
(define-constant ERR_BID_PRICE_TOO_LOW 8205)
(define-constant ERR_BID_PERIOD_INVALID 8206)
(define-constant ERR_BID_DEPOSIT_UNENOUGH 8207)
;;
(define-constant ERR_AD_NOT_HOST 8301)
(define-constant ERR_AD_BUY_SELF 8302)
(define-constant ERR_AD_POS_INVALID 8303)
(define-constant ERR_AD_ALREADY_LIST 8304)
(define-constant ERR_AD_POS_OCCUPIED 8305)
(define-constant ERR_AD_NAME_NOT_SAME 8306)
(define-constant ERR_AD_PERIOD_INVALID 8307)
(define-constant ERR_AD_NAME_NEED_RENEW 8308)
(define-constant ERR_AD_NOT_ALLOW_CANCEL_SET_PRICE 8309)

;;
(define-constant OWNER tx-sender)
(define-constant LIST_STATISTICS (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
(define-constant STATISTIC_LEN (len LIST_STATISTICS))
(define-constant LIST_NAME_BIDS (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12))  ;; correspond with loop_n4
(define-constant LIST_PLAYER_BIDS (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25))
(define-constant LIST_AD_PAGE (list
  (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25)
  (list u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50)
  (list u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75)
  (list u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100)
  (list u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125)
  (list u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150)
  (list u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175)
  (list u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200)
  (list u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225)
  (list u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250)
  (list u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275)
  (list u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299 u300)
  (list u301 u302 u303 u304 u305 u306 u307 u308 u309 u310 u311 u312 u313 u314 u315 u316 u317 u318 u319 u320 u321 u322 u323 u324 u325)
  (list u326 u327 u328 u329 u330 u331 u332 u333 u334 u335 u336 u337 u338 u339 u340 u341 u342 u343 u344 u345 u346 u347 u348 u349 u350)
  (list u351 u352 u353 u354 u355 u356 u357 u358 u359 u360 u361 u362 u363 u364 u365 u366 u367 u368 u369 u370 u371 u372 u373 u374 u375)
  (list u376 u377 u378 u379 u380 u381 u382 u383 u384 u385 u386 u387 u388 u389 u390 u391 u392 u393 u394 u395 u396 u397 u398 u399 u400)
  (list u401 u402 u403 u404 u405 u406 u407 u408 u409 u410 u411 u412 u413 u414 u415 u416 u417 u418 u419 u420 u421 u422 u423 u424 u425)
  (list u426 u427 u428 u429 u430 u431 u432 u433 u434 u435 u436 u437 u438 u439 u440 u441 u442 u443 u444 u445 u446 u447 u448 u449 u450)
  (list u451 u452 u453 u454 u455 u456 u457 u458 u459 u460 u461 u462 u463 u464 u465 u466 u467 u468 u469 u470 u471 u472 u473 u474 u475)
  (list u476 u477 u478 u479 u480 u481 u482 u483 u484 u485 u486 u487 u488 u489 u490 u491 u492 u493 u494 u495 u496 u497 u498 u499 u500)
))
(define-constant AD_COUNT (* (len LIST_AD_PAGE) (len (unwrap-panic (element-at LIST_AD_PAGE u0)))))
(define-constant LIST_AD_UPDATE (list 
  (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50)
  (list u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100)
  (list u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150)
  (list u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199 u200)
  (list u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250)
  (list u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299 u300)
  (list u301 u302 u303 u304 u305 u306 u307 u308 u309 u310 u311 u312 u313 u314 u315 u316 u317 u318 u319 u320 u321 u322 u323 u324 u325 u326 u327 u328 u329 u330 u331 u332 u333 u334 u335 u336 u337 u338 u339 u340 u341 u342 u343 u344 u345 u346 u347 u348 u349 u350)
  (list u351 u352 u353 u354 u355 u356 u357 u358 u359 u360 u361 u362 u363 u364 u365 u366 u367 u368 u369 u370 u371 u372 u373 u374 u375 u376 u377 u378 u379 u380 u381 u382 u383 u384 u385 u386 u387 u388 u389 u390 u391 u392 u393 u394 u395 u396 u397 u398 u399 u400)
  (list u401 u402 u403 u404 u405 u406 u407 u408 u409 u410 u411 u412 u413 u414 u415 u416 u417 u418 u419 u420 u421 u422 u423 u424 u425 u426 u427 u428 u429 u430 u431 u432 u433 u434 u435 u436 u437 u438 u439 u440 u441 u442 u443 u444 u445 u446 u447 u448 u449 u450)
  (list u451 u452 u453 u454 u455 u456 u457 u458 u459 u460 u461 u462 u463 u464 u465 u466 u467 u468 u469 u470 u471 u472 u473 u474 u475 u476 u477 u478 u479 u480 u481 u482 u483 u484 u485 u486 u487 u488 u489 u490 u491 u492 u493 u494 u495 u496 u497 u498 u499 u500)
))
(define-constant LIST_AD_UPDATE_LEN (len LIST_AD_UPDATE))
(define-constant LIST_HOST_ACCOUNTS (list
  .aaa1 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2
  .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2 .aaa2    
))
(define-constant AD_HOST_GRACE_BLOCKS u1440)          ;; 10 days
(define-constant AD_DISCARD_HOST_NAME_BLOCKS u1440)   ;; 10 days
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Data maps and vars ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-data-var m_fee uint u20)
(define-data-var m_min_price uint u2000000)
(define-data-var m_max_price uint u2000000000000000)
(define-data-var m_min_bid_days uint u1)
(define-data-var m_max_bid_days uint u100)
(define-data-var m_ad_min_days uint u1)
(define-data-var m_ad_max_days uint u30)
(define-data-var m_ad_price_list (list 20 uint) (list u100000 u100000 u100000 u100000 u100000 u90000 u90000 u90000 u90000 u90000 u80000 u80000 u80000 u80000 u80000 u70000 u70000 u70000 u70000 u70000))
(define-data-var m_ad_host_deposit uint u5000000)
(define-data-var m_ad_update_index uint u0)
;; statistics
(define-data-var m_stat_trade_index uint u0)
(define-data-var m_stat_list_index uint u0)
(define-data-var m_stat_bid_index uint u0)
;;
(define-data-var m_tmp_n uint u0)
(define-data-var m_tmp_p uint u0)
(define-data-var m_tmp_player (optional principal) none)

;; name => wanna sell at price (noly for reference if name not hosted by ad, others can only bid and wait owner's accept)
(define-map map_name_list
  { namespace: (buff 20), name: (buff 48) }
  uint
)

(define-map map_name_bid
  { namespace: (buff 20), name: (buff 48), index: uint }
  {
    player: principal,
    price: uint,
    at: uint,
    expiration: uint,
  }
)

(define-map map_player_bid
  { player: principal, index: uint }
  {
    namespace: (buff 20),
    name: (buff 48),
    price: uint,
    at: uint,
    expiration: uint,
  }
)

;; Normally bidder's deposit equals to the highest bid price it ever made. When accept a bid, won't success if bidder's deposit not enough.
(define-map map_bidder_deposit
  principal
  uint
)

(define-map map_ad
  uint
  {
    namespace: (buff 20),
    name: (buff 48),
    price: uint,
    at: uint,
    expiration: uint,
    expired_flag: bool,
    host_deposit: uint,
    origin_owner: (optional principal), ;; if is-some, means the name is hosted by contract (so others can buy directly)
  }
)

(define-map map_name2adpos
  { namespace: (buff 20), name: (buff 48) }
  uint
)

;; not real-time
(define-map map_player2adpos
  principal
  uint
)

(define-map map_new_trade
  uint
  {
    namespace: (buff 20),
    name: (buff 48),
    price: uint,
    seller: principal,
    buyer: principal,
  }
)

(define-map map_new_list
  uint
  {
    namespace: (buff 20),
    name: (buff 48),
    price: uint,
  }
)

(define-map map_new_bid
  uint
  {
    namespace: (buff 20),
    name: (buff 48),
    price: uint,
  }
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; seller begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (set_name_price (namespace (buff 20)) (name (buff 48)) (price uint))
  (let
    (
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
      (ad_pos (default-to u0 (map-get? map_name2adpos { namespace: namespace, name: name })))
      (ad_opt (map-get? map_ad ad_pos))
      (stat_index (+ (mod (var-get m_stat_list_index) STATISTIC_LEN) u1))
    )
    (asserts!
      (or
        (is-eq (get owner resolve_rsp) tx-sender)
        (and (is-some ad_opt) (is-some (get origin_owner (unwrap-panic ad_opt))) (is-eq (unwrap-panic (get origin_owner (unwrap-panic ad_opt))) tx-sender))
      )
      (err ERR_NO_AUTHORITY)
    )
    (asserts! (and (>= price (var-get m_min_price)) (<= price (var-get m_max_price))) (err ERR_PRICE_INVALID))
    ;;
    (map-set map_name_list { namespace: namespace, name: name } price)
    (and
      (> ad_pos u0)
      (map-set map_ad
        ad_pos
        (merge (unwrap-panic ad_opt) {
          price: price
        })
      )
    )
    (map-set map_new_list
      stat_index
      {
        namespace: namespace,
        name: name,
        price: price,
      }
    )
    (var-set m_stat_list_index stat_index)
    (update_ads)
    (ok true)
  )
)

(define-public (cancel_set_name_price (namespace (buff 20)) (name (buff 48)))
  (let
    (
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
      (ad_pos (default-to u0 (map-get? map_name2adpos { namespace: namespace, name: name })))
    )
    (asserts! (is-eq ad_pos u0) (err ERR_AD_NOT_ALLOW_CANCEL_SET_PRICE))
    (asserts! (is-eq (get owner resolve_rsp) tx-sender) (err ERR_NO_AUTHORITY))
    (map-delete map_name_list { namespace: namespace, name: name })
    (update_ads)
    (ok true)
  )
)

(define-public (accept_bid (namespace (buff 20)) (name (buff 48)) (bidder principal))
  (let
    (
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
      (pos_n (get pos (fold loop_n2 LIST_NAME_BIDS { p: bidder, ns: namespace, n: name, pos: u0 })))
      (pos_p (get pos (fold loop_p1 LIST_PLAYER_BIDS { p: bidder, ns: namespace, n: name, pos: u0 })))
      (name_bid_info (unwrap! (map-get? map_name_bid { namespace: namespace, name: name, index: pos_n }) (err ERR_BID_NOT_FOUND)))
      (player_bid_info (unwrap! (map-get? map_player_bid { player: bidder, index: pos_p }) (err ERR_BID_NOT_FOUND)))
      (price (get price name_bid_info))
      (ad_pos (default-to u0 (map-get? map_name2adpos { namespace: namespace, name: name })))
      (ad_opt (map-get? map_ad ad_pos))
      (b_host (and (is-some ad_opt) (is-some (get origin_owner (unwrap-panic ad_opt)))))
      (seller_paid (/ (* price (- u1000 (var-get m_fee))) u1000))
      (deposit (default-to u0 (map-get? map_bidder_deposit bidder)))
      (caller tx-sender)
      (stat_index (+ (mod (var-get m_stat_trade_index) STATISTIC_LEN) u1))
      (bh block-height)
    )
    (asserts! (is-err (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal bidder)) (err ERR_PRINCIPAL_ALREADY_ASSOCIATED))
    (asserts! (or (is-eq (get owner resolve_rsp) caller) (and b_host (is-eq (unwrap-panic (get origin_owner (unwrap-panic ad_opt))) caller))) (err ERR_NO_AUTHORITY))
    (asserts! (and (<= bh (get expiration name_bid_info)) (<= bh (get expiration player_bid_info))) (err ERR_BID_EXPIRED))
    (asserts! (is-eq price (get price player_bid_info)) (err ERR_PRICE_NOT_SAME))
    (asserts! (>= deposit price) (err ERR_BID_DEPOSIT_UNENOUGH))
    ;; (asserts! (>= (stx-get-balance (as-contract tx-sender)) price) (err ERR_BALANCE_UNENOUGH))
    (unwrap! (as-contract (stx-transfer? seller_paid tx-sender caller)) (err ERR_TRANSFER_STX))
    (unwrap! (as-contract (stx-transfer? (- price seller_paid) tx-sender OWNER)) (err ERR_TRANSFER_STX))
    (if b_host
      (try! (contract-call? .aaabridge transfer ad_pos namespace name bidder none))
      (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name bidder none))
    )
    (if (is-eq deposit price)
      (map-delete map_bidder_deposit bidder)
      (map-set map_bidder_deposit bidder (- deposit price))
    )
    (map-delete map_name_list { namespace: namespace, name: name })
    (map-delete map_name_bid { namespace: namespace, name: name, index: pos_n })
    (map-delete map_player_bid { player: bidder, index: pos_p })
    (if (> ad_pos u0)
      (begin
        (refund_host_fee ad_pos) 
        (map-delete map_ad ad_pos) 
        (map-delete map_player2adpos caller)
        (map-delete map_name2adpos { namespace: namespace, name: name })
      )
      false
    )
    (map-set map_new_trade
      stat_index
      {
        namespace: namespace,
        name: name,
        price: price,
        seller: caller,
        buyer: bidder,
      }
    )
    (var-set m_stat_trade_index stat_index)
    (update_ads)
    (ok true)
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; seller end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; buy begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (buy (namespace (buff 20)) (name (buff 48)) (ad_pos uint))
  (let
    (
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
      (ad_info (unwrap! (map-get? map_ad ad_pos) (err ERR_AD_POS_INVALID)))
      (origin_owner (unwrap! (get origin_owner ad_info) (err ERR_AD_NOT_HOST)))
      (price (get price ad_info))
      (name_price_opt (map-get? map_name_list { namespace: namespace, name: name }))
      (seller_paid (/ (* (get price ad_info) (- u1000 (var-get m_fee))) u1000))
      (pos_n (get pos (fold loop_n2 LIST_NAME_BIDS { p: tx-sender, ns: namespace, n: name, pos: u0 })))
      (pos_p (get pos (fold loop_p1 LIST_PLAYER_BIDS { p: tx-sender, ns: namespace, n: name, pos: u0 })))
      (stat_index (+ (mod (var-get m_stat_trade_index) STATISTIC_LEN) u1))
      (deposit (default-to u0 (map-get? map_bidder_deposit tx-sender)))
      (caller tx-sender)
    )
    (asserts! (is-err (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender)) (err ERR_PRINCIPAL_ALREADY_ASSOCIATED))
    (asserts! (and (is-eq namespace (get namespace ad_info)) (is-eq name (get name ad_info))) (err ERR_AD_NAME_NOT_SAME))
    (asserts! (and (is-some name_price_opt) (is-eq price (unwrap-panic name_price_opt))) (err ERR_PRICE_NOT_SAME))
    (asserts! (not (is-eq origin_owner tx-sender)) (err ERR_AD_BUY_SELF))
    ;;
    (if (is-eq deposit u0)
      (begin
        (asserts! (>= (stx-get-balance tx-sender) price) (err ERR_BALANCE_UNENOUGH))
        (unwrap! (stx-transfer? seller_paid tx-sender origin_owner) (err ERR_TRANSFER_STX))
        (unwrap! (stx-transfer? (- price seller_paid) tx-sender OWNER) (err ERR_TRANSFER_STX))
      )
      (begin
        (map-delete map_bidder_deposit tx-sender)
        (if (< deposit price)
          (and (asserts! (>= (stx-get-balance tx-sender) (- price deposit)) (err ERR_BALANCE_UNENOUGH))
               (unwrap! (stx-transfer? (- price deposit) tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX)))
          (and (> deposit price) (unwrap! (as-contract (stx-transfer? (- deposit price) tx-sender caller)) (err ERR_TRANSFER_STX)))
        )
        (unwrap! (as-contract (stx-transfer? seller_paid tx-sender origin_owner)) (err ERR_TRANSFER_STX))
        (unwrap! (as-contract (stx-transfer? (- price seller_paid) tx-sender OWNER)) (err ERR_TRANSFER_STX))
      )
    )
    (try! (contract-call? .aaabridge transfer ad_pos namespace name tx-sender none))
    (map-delete map_name_list { namespace: namespace, name: name })
    (and (> pos_n u0) (map-delete map_name_bid { namespace: namespace, name: name, index: pos_n }))
    (and (> pos_p u0) (map-delete map_player_bid { player: tx-sender, index: pos_p }))
    (refund_host_fee ad_pos)
    (map-delete map_ad ad_pos)
    (map-delete map_player2adpos origin_owner)
    (map-delete map_name2adpos { namespace: namespace, name: name })
    (map-set map_new_trade
      stat_index
      {
        namespace: namespace,
        name: name,
        price: price,
        seller: origin_owner,
        buyer: tx-sender,
      }
    )
    (var-set m_stat_trade_index stat_index)
    (update_ads)
    (ok true)
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; buy end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; bidder begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; bid replace rule:
;; if has-bid-this-name then { replace info }
;; elseif has-idle-pos then { set info at it }
;; elseif has-expired-pos then { set info at it }
;; elseif has-unenough-pos then { set info at it }
;; elseif bidder-at-pos-already-has-name then { sef info at it }
;; elseif price > min-bid then { set info at min-bid-pos }
;; else { error, bid price too low }
(define-public (bid (namespace (buff 20)) (name (buff 48)) (price uint) (days uint))
  (let
    (
      (deposit (default-to u0 (map-get? map_bidder_deposit tx-sender)))
      (bh block-height)
      (expiration (+ bh (* days u144)))
      (result_n (fold loop_n1 LIST_NAME_BIDS { p: tx-sender, ns: namespace, n: name, pos: u0, ip: u0, ep: u0, up: u0, ap: u0, mbp: u0, mb: u0 }))
      (result_p (fold loop_p2 LIST_PLAYER_BIDS { p: tx-sender, ns: namespace, n: name, pos: u0, ip: u0, ep: u0 }))
      (bid_pos_n (get pos result_n))
      (bid_pos_p (get pos result_p))
      (stat_index (+ (mod (var-get m_stat_bid_index) STATISTIC_LEN) u1))
    )
    (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name))
    (asserts! (is-err (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender)) (err ERR_PRINCIPAL_ALREADY_ASSOCIATED))
    (asserts! (and (>= price (var-get m_min_price)) (<= price (var-get m_max_price))) (err ERR_PRICE_INVALID))
    (asserts! (and (>= days (var-get m_min_bid_days)) (<= days (var-get m_max_bid_days))) (err ERR_BID_PERIOD_INVALID))
    (asserts! (or (and (is-eq bid_pos_p u0) (is-eq bid_pos_n u0)) (and (> bid_pos_p u0) (> bid_pos_n u0))) (err ERR_BID_POS_NOT_SAME))
    ;;
    (and
      (> price deposit)
      (asserts! (>= (stx-get-balance tx-sender) (- price deposit)) (err ERR_BALANCE_UNENOUGH))
      (unwrap! (stx-transfer? (- price deposit) tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX))
      (map-set map_bidder_deposit tx-sender price)
    )
    (var-set m_tmp_n u0)
    (var-set m_tmp_p u0)
    (var-set m_tmp_player none)
    (if (> bid_pos_n u0)
      ;; already bid (namespace, name)
      (begin
        (var-set m_tmp_n bid_pos_n)
        (var-set m_tmp_p bid_pos_p)
      )
      ;; hasn't bid (namespace, name)
      (begin
        ;; calc pos to insert into map_name_bid
        (if (> (get ip result_n) u0)
          (var-set m_tmp_n (get ip result_n))
          (and
            (if (> (get ep result_n) u0) (var-set m_tmp_n (get ep result_n))
              (if (> (get up result_n) u0) (var-set m_tmp_n (get up result_n))
                (if (> (get ap result_n) u0) (var-set m_tmp_n (get ap result_n))
                  (if (> price (get mb result_n)) (var-set m_tmp_n (get mbp result_n)) (asserts! false (err ERR_BID_PRICE_TOO_LOW))))))
            (var-set m_tmp_player (get player (map-get? map_name_bid { namespace: namespace, name: name, index: (var-get m_tmp_n) })))
          )
        )
        ;; calc pos to insert into map_player_bid
        (if (> (get ip result_p) u0)
          (var-set m_tmp_p (get ip result_p))
          (if (> (get ep result_p) u0)
            (var-set m_tmp_p (get ep result_p))
            (asserts! false (err ERR_BID_TOO_MANY))
          )
        )
      )
    )
    ;;
    (map-set map_name_bid
      { namespace: namespace, name: name, index: (var-get m_tmp_n) }
      {
        player: tx-sender,
        price: price,
        at: bh,
        expiration: expiration,
      }
    )
    (map-set map_player_bid 
      { player: tx-sender, index: (var-get m_tmp_p) }
      {
        namespace: namespace,
        name: name,
        price: price,
        at: bh,
        expiration: expiration,
      }
    )
    ;; remove origin bid in replace situation
    (match (var-get m_tmp_player) player
      (map-delete map_player_bid { player: player, index: (get pos (fold loop_p1 LIST_PLAYER_BIDS { p: player, ns: namespace, n: name, pos: u0 })) })
      false
    )
    (map-set map_new_bid
      stat_index
      {
        namespace: namespace,
        name: name,
        price: price,
      }
    )
    (var-set m_stat_bid_index stat_index)
    (update_ads)
    (ok true)
  )
)

(define-public (cancel_bid (namespace (buff 20)) (name (buff 48)))
  (let
    (
      (pos_n (get pos (fold loop_n2 LIST_NAME_BIDS { p: tx-sender, ns: namespace, n: name, pos: u0 })))
      (pos_p (get pos (fold loop_p1 LIST_PLAYER_BIDS { p: tx-sender, ns: namespace, n: name, pos: u0 })))
    )
    (asserts! (and (> pos_p u0) (> pos_n u0)) (err ERR_BID_NOT_FOUND))
    ;;
    (map-delete map_name_bid { namespace: namespace, name: name, index: pos_n })
    (map-delete map_player_bid { player: tx-sender, index: pos_p })
    (update_ads)
    (ok true)
  )
)

(define-public (withdraw)
  (let
    (
      (deposit (default-to u0 (map-get? map_bidder_deposit tx-sender)))
      (caller tx-sender)
    )
    (filter loop_p3 LIST_PLAYER_BIDS)
    (map-delete map_bidder_deposit tx-sender)
    (ok (and (> deposit u0) (unwrap! (as-contract (stx-transfer? deposit tx-sender caller)) (err ERR_TRANSFER_STX))))
  )
)

;; if player has bid (namespace, name), pos is the bid position
(define-private (loop_p1 (i uint) (ud { p: principal, ns: (buff 20), n: (buff 48), pos: uint }))
  (if (> (get pos ud) u0) ud (match (map-get? map_player_bid { player: (get p ud), index: i }) bi (if (and (is-eq (get namespace bi) (get ns ud)) (is-eq (get name bi) (get n ud))) (merge ud {pos: i}) ud) ud)))

;; if player has bid (namespace, name), pos is the bid position; otherwise, try to find an idle-pos(ip)/expired-pos(ep) in order
(define-private (loop_p2 (i uint) (ud { p: principal, ns: (buff 20), n: (buff 48), pos: uint, ip: uint, ep: uint }))
  (if (> (get pos ud) u0) ud (match (map-get? map_player_bid { player: (get p ud), index: i }) bi (if (and (is-eq (get namespace bi) (get ns ud)) (is-eq (get name bi) (get n ud))) (merge ud { pos: i }) (if (and (is-eq (get ep ud) u0) (> block-height (get expiration bi))) (merge ud { ep: i }) ud)) (if (is-eq (get ip ud) u0) (merge ud { ip: i }) ud))))

;; if player has bid (namespace, name), pos is the position; otherwise, try to find an idle_pos(ip)/expired_pos(ep)/unenough_pos(up)/associated_pos(ap)/min_bid_pos(mp) in order
(define-private (loop_n1 (i uint) (ud { p: principal, ns: (buff 20), n: (buff 48), pos: uint, ip: uint, ep: uint, up: uint, ap: uint, mbp: uint, mb: uint }))
  (if (> (get pos ud) u0) ud (match (map-get? map_name_bid { namespace: (get ns ud), name: (get n ud), index: i }) bi (if (is-eq (get player bi) (get p ud)) (merge ud { pos: i }) (if (> (get ep ud) u0) ud (if (> block-height (get expiration bi)) (merge ud { ep: i }) (if (> (get up ud) u0) ud (if (< (default-to u0 (map-get? map_bidder_deposit (get player bi))) (get price bi)) (merge ud { up: i }) (if (> (get ap ud) u0) ud (if (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (get player bi))) (merge ud { ap: i }) (if (or (is-eq (get mbp ud) u0) (< (get price bi) (get mb ud))) (merge ud { mbp: i, mb: (get price bi) }) ud)))))))) (if (> (get ip ud) u0) ud (merge ud { ip: i })))))

;; if player has bid (namespace, name), pos is the position
(define-private (loop_n2 (i uint) (ud { p: principal, ns: (buff 20), n: (buff 48), pos: uint }))
  (if (> (get pos ud) u0) ud (match (map-get? map_name_bid { namespace: (get ns ud), name: (get n ud), index: i }) bi (if (is-eq (get player bi) (get p ud)) (merge ud { pos: i }) ud) ud)))

;; if player has bid at pos i, remove it, also remove corresponding info in map_name_bid
(define-private (loop_p3 (i uint))
  (match (map-get? map_player_bid { player: tx-sender, index: i }) bi (begin (map-delete map_player_bid { player: tx-sender, index: i }) (fold loop_n3 LIST_NAME_BIDS { ns: (get namespace bi), n: (get name bi), f: false }) false) false))

;; if player has bid (namespace, name), remove it from map_name_bid, set f(flag) to true
(define-private (loop_n3 (i uint) (ud { ns: (buff 20), n: (buff 48), f: bool }))
  (if (get f ud) ud (let ((ns (get ns ud)) (n (get n ud)) (bio (map-get? map_name_bid { namespace: ns, name: n, index: i }))) (if (and (is-some bio) (is-eq (unwrap-panic (get player bio)) tx-sender)) (begin (map-delete map_name_bid { namespace: ns, name: n, index: i }) (merge ud { f: true })) ud))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; bidder end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ad begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (add_ad (namespace (buff 20)) (name (buff 48)) (pos uint) (price uint) (days uint) (is_host bool) (extra_address (optional principal)))
  (let
    (
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
      (lease_end_at (default-to u0 (get lease-ending-at resolve_rsp)))
      (ad_opt (map-get? map_ad pos))
      (found_pos (default-to u0 (map-get? map_name2adpos { namespace: namespace, name: name })))
      (ad_price (* days (unwrap-panic (element-at (var-get m_ad_price_list) (/ (- pos u1) u25)))))
      (host_deposit (if is_host (var-get m_ad_host_deposit) u0))
      (stat_index (+ (mod (var-get m_stat_list_index) STATISTIC_LEN) u1))
      (bh block-height)
    )
    (asserts! (is-none ad_opt) (err ERR_AD_POS_OCCUPIED))
    (asserts! (is-eq found_pos u0) (err ERR_AD_ALREADY_LIST))
    ;; (asserts! (and (>= pos u1) (<= pos AD_COUNT)) (err ERR_AD_POS_INVALID))
    (asserts! (is-eq (get owner resolve_rsp) tx-sender) (err ERR_NO_AUTHORITY))
    (asserts! (and (>= price (var-get m_min_price)) (<= price (var-get m_max_price))) (err ERR_PRICE_INVALID))
    (asserts! (and (>= days (var-get m_ad_min_days)) (<= days (var-get m_ad_max_days))) (err ERR_AD_PERIOD_INVALID))
    (asserts! (or (not is_host) (is-eq lease_end_at u0) (< (+ bh (* days u144) AD_HOST_GRACE_BLOCKS AD_DISCARD_HOST_NAME_BLOCKS) lease_end_at)) (err ERR_AD_NAME_NEED_RENEW))
    (asserts! (>= (stx-get-balance tx-sender) (+ ad_price host_deposit)) (err ERR_BALANCE_UNENOUGH))
    ;;
    (or (is-eq tx-sender OWNER) (unwrap! (stx-transfer? ad_price tx-sender OWNER) (err ERR_TRANSFER_STX)))
    (and (> host_deposit u0) (unwrap! (stx-transfer? host_deposit tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX)))
    (and is_host
      (let
        (
          (host_account (unwrap! (element-at LIST_HOST_ACCOUNTS (- pos u1)) (err ERR_AD_POS_INVALID)))
        )
        (match extra_address addr
          (match (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal host_account)
            resolve_host_info (try! (contract-call? .aaabridge transfer pos (get namespace resolve_host_info) (get name resolve_host_info) addr none))
            err_value false
          )
          false
        )
        (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name host_account (some (get zonefile-hash resolve_rsp))))
      )
    )
    (map-set map_name_list { namespace: namespace, name: name } price)
    (map-set map_ad
      pos
      {
        namespace: namespace,
        name: name,
        price: price,
        host_deposit: host_deposit,
        at: bh,
        expiration: (+ bh (* days u144)),
        expired_flag: false,
        origin_owner: (if is_host (some tx-sender) none),
      }
    )
    (map-set map_player2adpos tx-sender pos)
    (map-set map_name2adpos { namespace: namespace, name: name } pos)
    (map-set map_new_list
      stat_index
      {
        namespace: namespace,
        name: name,
        price: price,
      }
    )
    (var-set m_stat_list_index stat_index)
    (update_ads)
    (ok true)
  )
)

(define-public (cancel_host (namespace (buff 20)) (name (buff 48)) (pos uint) (extra_address (optional principal)))
  (let
    (
      (resolve_rsp (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)))
      (ad_info (unwrap! (map-get? map_ad pos) (err ERR_AD_POS_INVALID)))
      (origin_owner (unwrap! (get origin_owner ad_info) (err ERR_AD_NOT_HOST)))
    )
    (asserts! (is-eq origin_owner tx-sender) (err ERR_NO_AUTHORITY))
    (try! (contract-call? .aaabridge transfer pos namespace name (default-to origin_owner extra_address) (some (get zonefile-hash resolve_rsp))))
    (refund_host_fee pos)
    (map-set map_ad pos (merge ad_info {
      host_deposit: u0,
      origin_owner: none,
    }))
    (update_ad pos)
    (ok true)
  )
)

(define-public (manual_update_ads (key_list (list 100 uint)))
  (ok (filter update_ad key_list))
)

(define-private (update_ads)
  (let
    (
      (arr_index (mod (var-get m_ad_update_index) LIST_AD_UPDATE_LEN))
    )
    (filter update_ad (unwrap-panic (element-at LIST_AD_UPDATE arr_index)))
    (var-set m_ad_update_index (+ arr_index u1))
  )
)

;; i(index), ai(ad_info), ns(namespace), r(resolve_rsp), z(zone-file-hash), k(ok_value), e(err_value)
(define-private (update_ad (i uint))
  (match (map-get? map_ad i) ai (if (> block-height (get expiration ai)) (match (get origin_owner ai) o (let ((ns (get namespace ai)) (name (get name ai)) (r (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve ns name)) (z (if (is-ok r) (some (get zonefile-hash (unwrap-panic r))) none))) (if (or (not (get expired_flag ai)) (<= block-height (+ (get expiration ai) AD_HOST_GRACE_BLOCKS)))
  (match (contract-call? .aaabridge transfer i ns name o z) k (begin (refund_host_fee i) (map-delete map_ad i) (map-delete map_player2adpos o) (map-delete map_name2adpos { namespace: ns, name: name })) e (map-set map_ad i (merge ai { expired_flag: true }))) (begin (is-ok (contract-call? .aaabridge transfer i ns name o z)) (map-delete map_ad i) (map-delete map_player2adpos o) 
  (map-delete map_name2adpos { namespace: ns, name: name }) (print { t: "exceed grace", i: i }) (is-ok (as-contract (stx-transfer? (get host_deposit ai) tx-sender OWNER))))) false) (begin (map-delete map_ad i) (map-delete map_name2adpos { namespace: (get namespace ai), name: (get name ai) }) false)) false) false))

(define-private (refund_host_fee (pos uint))
  (match (map-get? map_ad pos) ad_info
    (match (get origin_owner ad_info) origin_owner
      (let
        (
          (expiration (get expiration ad_info))
          (deposit (get host_deposit ad_info))
          (fee (if (and (get expired_flag ad_info) (> block-height expiration)) (/ (* deposit (- block-height expiration)) AD_HOST_GRACE_BLOCKS) u0))
          (rfee (if (> fee deposit) deposit fee))
        )
        (and (> rfee u0) (unwrap-panic (as-contract (stx-transfer? rfee tx-sender OWNER))))
        (and (< rfee deposit) (unwrap-panic (as-contract (stx-transfer? (- deposit rfee) tx-sender origin_owner))))
      )
      false
    )
    false
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ad end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; misc begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; When host & origin_owner has DOMAIN(so domain hosted in .aaabridge contract can't be sent it back) & exceed grace period, domain will left in .aaabridge contract. Anyone can transfer it to specified address in such situation.
(define-public (discard_domains (pair_list (list 50 { pos: uint, address: principal })))
  (ok (filter loop_d pair_list))
)

(define-public (discard_domain (info { pos: uint, address: principal }))
  (let
    (
      (ad_pos (get pos info))
      (ad_opt (map-get? map_ad ad_pos))
      (host_account (unwrap! (element-at LIST_HOST_ACCOUNTS (- ad_pos u1)) (err ERR_AD_POS_INVALID)))
      (resolve_info (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal host_account) (err ERR_BNS_RESOLVE_FAIL)))
    )
    (asserts! (or (is-none ad_opt) (is-none (get origin_owner (unwrap-panic ad_opt)))) (err ERR_NO_AUTHORITY))
    (try! (contract-call? .aaabridge transfer ad_pos (get namespace resolve_info) (get name resolve_info) (get address info) none))
    (ok true)
  )
)

(define-private (loop_d (info { pos: uint, address: principal }))
  (is-ok (discard_domain info))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; misc end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; web begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only (get_config)
  {
    fee: (var-get m_fee),
    min_price: (var-get m_min_price),
    max_price: (var-get m_max_price),
    min_bid_days: (var-get m_min_bid_days),
    max_bid_days: (var-get m_max_bid_days),
    ad_min_days: (var-get m_ad_min_days),
    ad_max_days: (var-get m_ad_max_days),
    ad_price_list: (var-get m_ad_price_list),
    ad_host_deposit: (var-get m_ad_host_deposit),
  }
)

(define-read-only (get_summary (player_opt (optional principal)))
  (match player_opt player
    (let
      (
        (ad_pos (default-to u0 (map-get? map_player2adpos player)))
      )
      {
        bh: block-height,
        balance: (stx-get-balance player),
        config: (get_config),
        deposit: (default-to u0 (map-get? map_bidder_deposit player)),
        ad_pos: ad_pos,
        ad_info: (map-get? map_ad ad_pos),
        ;; bns: (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal player), ;; exceed read_length
      }
    )
    {
      bh: block-height,
      balance: u0,
      config: (get_config),
      deposit: u0,
      ad_pos: u0,
      ad_info: none,
      ;; bns: (err {code: 0, name: none}),
    }
  )
)

(define-read-only (get_bidder_deposit (player principal))
  (default-to u0 (map-get? map_bidder_deposit player))
)

(define-read-only (get_player_bid_data (player principal))
  {
    deposit: (default-to u0 (map-get? map_bidder_deposit player)),
    bids: (fold loop_p4 LIST_PLAYER_BIDS { p: player, r: (list) })
  }
)

(define-read-only (get_name_list_price (namespace (buff 20)) (name (buff 48)))
  (map-get? map_name_list { namespace: namespace, name: name })
)

(define-read-only (get_name_summary (namespace (buff 20)) (name (buff 48)))
  (let
    (
      (ad_pos (default-to u0 (map-get? map_name2adpos { namespace: namespace, name: name })))
    )
    {
      ;; resolve_rsp: (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name),  ;; exceed read_length
      ad_pos: ad_pos,
      price: (default-to u0 (map-get? map_name_list { namespace: namespace, name: name })),
      ad: (if (is-eq ad_pos u0) none (map-get? map_ad ad_pos)),
      bid_list: (get r (fold loop_n4 LIST_NAME_BIDS { ns: namespace, n: name, r: (list) })),
    }
  )
)

(define-read-only (get_ads_at_page (page uint))
  (map get_ad (unwrap-panic (element-at LIST_AD_PAGE (- page u1))))
)

(define-read-only (get_ads (key_list (list 25 uint)))
  (map get_ad key_list)
)

(define-read-only (get_ad_update_index)
  (var-get m_ad_update_index)
)

(define-read-only (get_new_list_list)
  {
    index: (var-get m_stat_list_index),
    arr: (map get_new_list LIST_STATISTICS),
  }
)

(define-read-only (get_new_trade_list)
  {
    index: (var-get m_stat_trade_index),
    arr: (map get_new_trade LIST_STATISTICS),
  }
)

(define-read-only (get_new_bid_list)
  {
    index: (var-get m_stat_bid_index),
    arr: (map get_new_bid LIST_STATISTICS),
  }
)

(define-read-only (get_ad_check_info (pos uint) (player principal))
  {
    balance: (stx-get-balance player),
    resolve_rsp: (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (unwrap-panic (element-at LIST_HOST_ACCOUNTS (- pos u1)))),
    ;; ad_price: (unwrap-panic (element-at (var-get m_ad_price_list) (/ (- pos u1) u25))),
    ;; ad_host_deposit: (var-get m_ad_host_deposit),
  }
)

(define-private (get_ad (index uint))
  (map-get? map_ad index)
)

(define-private (get_new_list (index uint))
  (map-get? map_new_list index)
)

(define-private (get_new_trade (index uint))
  (map-get? map_new_trade index)
)

(define-private (get_new_bid (index uint))
  (map-get? map_new_bid index)
)

(define-private (loop_n4 (i uint) (ud { ns: (buff 20), n: (buff 48), r: (list 12 { player: principal, price: uint, at: uint, expiration: uint }) }))
  (match (map-get? map_name_bid { namespace: (get ns ud), name: (get n ud), index: i }) bi (merge ud { r: (unwrap-panic (as-max-len? (append (get r ud) bi) u12)) }) ud))

(define-read-only (loop_p4 (i uint) (ud { p: principal, r: (list 25 { namespace: (buff 20), name: (buff 48), price: uint, at: uint, expiration: uint }) }))
  (match (map-get? map_player_bid { player: (get p ud), index: i }) bi (merge ud { r: (unwrap-panic (as-max-len? (append (get r ud) bi) u25)) }) ud))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; web end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; misc begin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public (update_price (min_price uint) (max_price uint) (fee uint) (ad_host_deposit uint))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (asserts! (<= fee u25) (err ERR_FEE_INVALID))
    (var-set m_min_price min_price)
    (var-set m_max_price max_price)
    (var-set m_fee fee)
    (var-set m_ad_host_deposit ad_host_deposit)
    (ok true)
  )
)

(define-public (update_ad_price (price_list (list 20 uint)))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (var-set m_ad_price_list price_list)
    (ok true)
  )
)

(define-public (update_limitations (min_bid_days uint) (max_bid_days uint) (ad_min_days uint) (ad_max_days uint))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (var-set m_min_bid_days min_bid_days)
    (var-set m_max_bid_days max_bid_days)
    (var-set m_ad_min_days ad_min_days)
    (var-set m_ad_max_days ad_max_days)
    (ok true)
  )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; misc end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;