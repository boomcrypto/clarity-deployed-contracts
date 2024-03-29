(define-constant OWNER tx-sender)
(define-constant ERR_NO_AUTHORITY 8001)

(define-public (set_master_contract (contract_owner principal))
  (begin
    (asserts! (is-eq tx-sender OWNER) (err ERR_NO_AUTHORITY))
    (try! (contract-call? .bridge-v2 set_master_contract contract_owner))
    (try! (contract-call? .a251 set_master_contract .bridge-v2))
    (try! (contract-call? .a252 set_master_contract .bridge-v2))
    (try! (contract-call? .a253 set_master_contract .bridge-v2))
    (try! (contract-call? .a254 set_master_contract .bridge-v2))
    (try! (contract-call? .a255 set_master_contract .bridge-v2))
    (try! (contract-call? .a256 set_master_contract .bridge-v2))
    (try! (contract-call? .a257 set_master_contract .bridge-v2))
    (try! (contract-call? .a258 set_master_contract .bridge-v2))
    (try! (contract-call? .a259 set_master_contract .bridge-v2))
    (try! (contract-call? .a260 set_master_contract .bridge-v2))
    (try! (contract-call? .a261 set_master_contract .bridge-v2))
    (try! (contract-call? .a262 set_master_contract .bridge-v2))
    (try! (contract-call? .a263 set_master_contract .bridge-v2))
    (try! (contract-call? .a264 set_master_contract .bridge-v2))
    (try! (contract-call? .a265 set_master_contract .bridge-v2))
    (try! (contract-call? .a266 set_master_contract .bridge-v2))
    (try! (contract-call? .a267 set_master_contract .bridge-v2))
    (try! (contract-call? .a268 set_master_contract .bridge-v2))
    (try! (contract-call? .a269 set_master_contract .bridge-v2))
    (try! (contract-call? .a270 set_master_contract .bridge-v2))
    (try! (contract-call? .a271 set_master_contract .bridge-v2))
    (try! (contract-call? .a272 set_master_contract .bridge-v2))
    (try! (contract-call? .a273 set_master_contract .bridge-v2))
    (try! (contract-call? .a274 set_master_contract .bridge-v2))
    (try! (contract-call? .a275 set_master_contract .bridge-v2))
    (try! (contract-call? .a276 set_master_contract .bridge-v2))
    (try! (contract-call? .a277 set_master_contract .bridge-v2))
    (try! (contract-call? .a278 set_master_contract .bridge-v2))
    (try! (contract-call? .a279 set_master_contract .bridge-v2))
    (try! (contract-call? .a280 set_master_contract .bridge-v2))
    (try! (contract-call? .a281 set_master_contract .bridge-v2))
    (try! (contract-call? .a282 set_master_contract .bridge-v2))
    (try! (contract-call? .a283 set_master_contract .bridge-v2))
    (try! (contract-call? .a284 set_master_contract .bridge-v2))
    (try! (contract-call? .a285 set_master_contract .bridge-v2))
    (try! (contract-call? .a286 set_master_contract .bridge-v2))
    (try! (contract-call? .a287 set_master_contract .bridge-v2))
    (try! (contract-call? .a288 set_master_contract .bridge-v2))
    (try! (contract-call? .a289 set_master_contract .bridge-v2))
    (try! (contract-call? .a290 set_master_contract .bridge-v2))
    (try! (contract-call? .a291 set_master_contract .bridge-v2))
    (try! (contract-call? .a292 set_master_contract .bridge-v2))
    (try! (contract-call? .a293 set_master_contract .bridge-v2))
    (try! (contract-call? .a294 set_master_contract .bridge-v2))
    (try! (contract-call? .a295 set_master_contract .bridge-v2))
    (try! (contract-call? .a296 set_master_contract .bridge-v2))
    (try! (contract-call? .a297 set_master_contract .bridge-v2))
    (try! (contract-call? .a298 set_master_contract .bridge-v2))
    (try! (contract-call? .a299 set_master_contract .bridge-v2))
    (try! (contract-call? .a300 set_master_contract .bridge-v2))
    (try! (contract-call? .a301 set_master_contract .bridge-v2))
    (try! (contract-call? .a302 set_master_contract .bridge-v2))
    (try! (contract-call? .a303 set_master_contract .bridge-v2))
    (try! (contract-call? .a304 set_master_contract .bridge-v2))
    (try! (contract-call? .a305 set_master_contract .bridge-v2))
    (try! (contract-call? .a306 set_master_contract .bridge-v2))
    (try! (contract-call? .a307 set_master_contract .bridge-v2))
    (try! (contract-call? .a308 set_master_contract .bridge-v2))
    (try! (contract-call? .a309 set_master_contract .bridge-v2))
    (try! (contract-call? .a310 set_master_contract .bridge-v2))
    (try! (contract-call? .a311 set_master_contract .bridge-v2))
    (try! (contract-call? .a312 set_master_contract .bridge-v2))
    (try! (contract-call? .a313 set_master_contract .bridge-v2))
    (try! (contract-call? .a314 set_master_contract .bridge-v2))
    (try! (contract-call? .a315 set_master_contract .bridge-v2))
    (try! (contract-call? .a316 set_master_contract .bridge-v2))
    (try! (contract-call? .a317 set_master_contract .bridge-v2))
    (try! (contract-call? .a318 set_master_contract .bridge-v2))
    (try! (contract-call? .a319 set_master_contract .bridge-v2))
    (try! (contract-call? .a320 set_master_contract .bridge-v2))
    (try! (contract-call? .a321 set_master_contract .bridge-v2))
    (try! (contract-call? .a322 set_master_contract .bridge-v2))
    (try! (contract-call? .a323 set_master_contract .bridge-v2))
    (try! (contract-call? .a324 set_master_contract .bridge-v2))
    (try! (contract-call? .a325 set_master_contract .bridge-v2))
    (try! (contract-call? .a326 set_master_contract .bridge-v2))
    (try! (contract-call? .a327 set_master_contract .bridge-v2))
    (try! (contract-call? .a328 set_master_contract .bridge-v2))
    (try! (contract-call? .a329 set_master_contract .bridge-v2))
    (try! (contract-call? .a330 set_master_contract .bridge-v2))
    (try! (contract-call? .a331 set_master_contract .bridge-v2))
    (try! (contract-call? .a332 set_master_contract .bridge-v2))
    (try! (contract-call? .a333 set_master_contract .bridge-v2))
    (try! (contract-call? .a334 set_master_contract .bridge-v2))
    (try! (contract-call? .a335 set_master_contract .bridge-v2))
    (try! (contract-call? .a336 set_master_contract .bridge-v2))
    (try! (contract-call? .a337 set_master_contract .bridge-v2))
    (try! (contract-call? .a338 set_master_contract .bridge-v2))
    (try! (contract-call? .a339 set_master_contract .bridge-v2))
    (try! (contract-call? .a340 set_master_contract .bridge-v2))
    (try! (contract-call? .a341 set_master_contract .bridge-v2))
    (try! (contract-call? .a342 set_master_contract .bridge-v2))
    (try! (contract-call? .a343 set_master_contract .bridge-v2))
    (try! (contract-call? .a344 set_master_contract .bridge-v2))
    (try! (contract-call? .a345 set_master_contract .bridge-v2))
    (try! (contract-call? .a346 set_master_contract .bridge-v2))
    (try! (contract-call? .a347 set_master_contract .bridge-v2))
    (try! (contract-call? .a348 set_master_contract .bridge-v2))
    (try! (contract-call? .a349 set_master_contract .bridge-v2))
    (try! (contract-call? .a350 set_master_contract .bridge-v2))
    (try! (contract-call? .a351 set_master_contract .bridge-v2))
    (try! (contract-call? .a352 set_master_contract .bridge-v2))
    (try! (contract-call? .a353 set_master_contract .bridge-v2))
    (try! (contract-call? .a354 set_master_contract .bridge-v2))
    (try! (contract-call? .a355 set_master_contract .bridge-v2))
    (try! (contract-call? .a356 set_master_contract .bridge-v2))
    (try! (contract-call? .a357 set_master_contract .bridge-v2))
    (try! (contract-call? .a358 set_master_contract .bridge-v2))
    (try! (contract-call? .a359 set_master_contract .bridge-v2))
    (try! (contract-call? .a360 set_master_contract .bridge-v2))
    (try! (contract-call? .a361 set_master_contract .bridge-v2))
    (try! (contract-call? .a362 set_master_contract .bridge-v2))
    (try! (contract-call? .a363 set_master_contract .bridge-v2))
    (try! (contract-call? .a364 set_master_contract .bridge-v2))
    (try! (contract-call? .a365 set_master_contract .bridge-v2))
    (try! (contract-call? .a366 set_master_contract .bridge-v2))
    (try! (contract-call? .a367 set_master_contract .bridge-v2))
    (try! (contract-call? .a368 set_master_contract .bridge-v2))
    (try! (contract-call? .a369 set_master_contract .bridge-v2))
    (try! (contract-call? .a370 set_master_contract .bridge-v2))
    (try! (contract-call? .a371 set_master_contract .bridge-v2))
    (try! (contract-call? .a372 set_master_contract .bridge-v2))
    (try! (contract-call? .a373 set_master_contract .bridge-v2))
    (try! (contract-call? .a374 set_master_contract .bridge-v2))
    (try! (contract-call? .a375 set_master_contract .bridge-v2))
    (try! (contract-call? .a376 set_master_contract .bridge-v2))
    (try! (contract-call? .a377 set_master_contract .bridge-v2))
    (try! (contract-call? .a378 set_master_contract .bridge-v2))
    (try! (contract-call? .a379 set_master_contract .bridge-v2))
    (try! (contract-call? .a380 set_master_contract .bridge-v2))
    (try! (contract-call? .a381 set_master_contract .bridge-v2))
    (try! (contract-call? .a382 set_master_contract .bridge-v2))
    (try! (contract-call? .a383 set_master_contract .bridge-v2))
    (try! (contract-call? .a384 set_master_contract .bridge-v2))
    (try! (contract-call? .a385 set_master_contract .bridge-v2))
    (try! (contract-call? .a386 set_master_contract .bridge-v2))
    (try! (contract-call? .a387 set_master_contract .bridge-v2))
    (try! (contract-call? .a388 set_master_contract .bridge-v2))
    (try! (contract-call? .a389 set_master_contract .bridge-v2))
    (try! (contract-call? .a390 set_master_contract .bridge-v2))
    (try! (contract-call? .a391 set_master_contract .bridge-v2))
    (try! (contract-call? .a392 set_master_contract .bridge-v2))
    (try! (contract-call? .a393 set_master_contract .bridge-v2))
    (try! (contract-call? .a394 set_master_contract .bridge-v2))
    (try! (contract-call? .a395 set_master_contract .bridge-v2))
    (try! (contract-call? .a396 set_master_contract .bridge-v2))
    (try! (contract-call? .a397 set_master_contract .bridge-v2))
    (try! (contract-call? .a398 set_master_contract .bridge-v2))
    (try! (contract-call? .a399 set_master_contract .bridge-v2))
    (try! (contract-call? .a400 set_master_contract .bridge-v2))
    (try! (contract-call? .a401 set_master_contract .bridge-v2))
    (try! (contract-call? .a402 set_master_contract .bridge-v2))
    (try! (contract-call? .a403 set_master_contract .bridge-v2))
    (try! (contract-call? .a404 set_master_contract .bridge-v2))
    (try! (contract-call? .a405 set_master_contract .bridge-v2))
    (try! (contract-call? .a406 set_master_contract .bridge-v2))
    (try! (contract-call? .a407 set_master_contract .bridge-v2))
    (try! (contract-call? .a408 set_master_contract .bridge-v2))
    (try! (contract-call? .a409 set_master_contract .bridge-v2))
    (try! (contract-call? .a410 set_master_contract .bridge-v2))
    (try! (contract-call? .a411 set_master_contract .bridge-v2))
    (try! (contract-call? .a412 set_master_contract .bridge-v2))
    (try! (contract-call? .a413 set_master_contract .bridge-v2))
    (try! (contract-call? .a414 set_master_contract .bridge-v2))
    (try! (contract-call? .a415 set_master_contract .bridge-v2))
    (try! (contract-call? .a416 set_master_contract .bridge-v2))
    (try! (contract-call? .a417 set_master_contract .bridge-v2))
    (try! (contract-call? .a418 set_master_contract .bridge-v2))
    (try! (contract-call? .a419 set_master_contract .bridge-v2))
    (try! (contract-call? .a420 set_master_contract .bridge-v2))
    (try! (contract-call? .a421 set_master_contract .bridge-v2))
    (try! (contract-call? .a422 set_master_contract .bridge-v2))
    (try! (contract-call? .a423 set_master_contract .bridge-v2))
    (try! (contract-call? .a424 set_master_contract .bridge-v2))
    (try! (contract-call? .a425 set_master_contract .bridge-v2))
    (try! (contract-call? .a426 set_master_contract .bridge-v2))
    (try! (contract-call? .a427 set_master_contract .bridge-v2))
    (try! (contract-call? .a428 set_master_contract .bridge-v2))
    (try! (contract-call? .a429 set_master_contract .bridge-v2))
    (try! (contract-call? .a430 set_master_contract .bridge-v2))
    (try! (contract-call? .a431 set_master_contract .bridge-v2))
    (try! (contract-call? .a432 set_master_contract .bridge-v2))
    (try! (contract-call? .a433 set_master_contract .bridge-v2))
    (try! (contract-call? .a434 set_master_contract .bridge-v2))
    (try! (contract-call? .a435 set_master_contract .bridge-v2))
    (try! (contract-call? .a436 set_master_contract .bridge-v2))
    (try! (contract-call? .a437 set_master_contract .bridge-v2))
    (try! (contract-call? .a438 set_master_contract .bridge-v2))
    (try! (contract-call? .a439 set_master_contract .bridge-v2))
    (try! (contract-call? .a440 set_master_contract .bridge-v2))
    (try! (contract-call? .a441 set_master_contract .bridge-v2))
    (try! (contract-call? .a442 set_master_contract .bridge-v2))
    (try! (contract-call? .a443 set_master_contract .bridge-v2))
    (try! (contract-call? .a444 set_master_contract .bridge-v2))
    (try! (contract-call? .a445 set_master_contract .bridge-v2))
    (try! (contract-call? .a446 set_master_contract .bridge-v2))
    (try! (contract-call? .a447 set_master_contract .bridge-v2))
    (try! (contract-call? .a448 set_master_contract .bridge-v2))
    (try! (contract-call? .a449 set_master_contract .bridge-v2))
    (try! (contract-call? .a450 set_master_contract .bridge-v2))
    (try! (contract-call? .a451 set_master_contract .bridge-v2))
    (try! (contract-call? .a452 set_master_contract .bridge-v2))
    (try! (contract-call? .a453 set_master_contract .bridge-v2))
    (try! (contract-call? .a454 set_master_contract .bridge-v2))
    (try! (contract-call? .a455 set_master_contract .bridge-v2))
    (try! (contract-call? .a456 set_master_contract .bridge-v2))
    (try! (contract-call? .a457 set_master_contract .bridge-v2))
    (try! (contract-call? .a458 set_master_contract .bridge-v2))
    (try! (contract-call? .a459 set_master_contract .bridge-v2))
    (try! (contract-call? .a460 set_master_contract .bridge-v2))
    (try! (contract-call? .a461 set_master_contract .bridge-v2))
    (try! (contract-call? .a462 set_master_contract .bridge-v2))
    (try! (contract-call? .a463 set_master_contract .bridge-v2))
    (try! (contract-call? .a464 set_master_contract .bridge-v2))
    (try! (contract-call? .a465 set_master_contract .bridge-v2))
    (try! (contract-call? .a466 set_master_contract .bridge-v2))
    (try! (contract-call? .a467 set_master_contract .bridge-v2))
    (try! (contract-call? .a468 set_master_contract .bridge-v2))
    (try! (contract-call? .a469 set_master_contract .bridge-v2))
    (try! (contract-call? .a470 set_master_contract .bridge-v2))
    (try! (contract-call? .a471 set_master_contract .bridge-v2))
    (try! (contract-call? .a472 set_master_contract .bridge-v2))
    (try! (contract-call? .a473 set_master_contract .bridge-v2))
    (try! (contract-call? .a474 set_master_contract .bridge-v2))
    (try! (contract-call? .a475 set_master_contract .bridge-v2))
    (try! (contract-call? .a476 set_master_contract .bridge-v2))
    (try! (contract-call? .a477 set_master_contract .bridge-v2))
    (try! (contract-call? .a478 set_master_contract .bridge-v2))
    (try! (contract-call? .a479 set_master_contract .bridge-v2))
    (try! (contract-call? .a480 set_master_contract .bridge-v2))
    (try! (contract-call? .a481 set_master_contract .bridge-v2))
    (try! (contract-call? .a482 set_master_contract .bridge-v2))
    (try! (contract-call? .a483 set_master_contract .bridge-v2))
    (try! (contract-call? .a484 set_master_contract .bridge-v2))
    (try! (contract-call? .a485 set_master_contract .bridge-v2))
    (try! (contract-call? .a486 set_master_contract .bridge-v2))
    (try! (contract-call? .a487 set_master_contract .bridge-v2))
    (try! (contract-call? .a488 set_master_contract .bridge-v2))
    (try! (contract-call? .a489 set_master_contract .bridge-v2))
    (try! (contract-call? .a490 set_master_contract .bridge-v2))
    (try! (contract-call? .a491 set_master_contract .bridge-v2))
    (try! (contract-call? .a492 set_master_contract .bridge-v2))
    (try! (contract-call? .a493 set_master_contract .bridge-v2))
    (try! (contract-call? .a494 set_master_contract .bridge-v2))
    (try! (contract-call? .a495 set_master_contract .bridge-v2))
    (try! (contract-call? .a496 set_master_contract .bridge-v2))
    (try! (contract-call? .a497 set_master_contract .bridge-v2))
    (try! (contract-call? .a498 set_master_contract .bridge-v2))
    (try! (contract-call? .a499 set_master_contract .bridge-v2))
    (try! (contract-call? .a500 set_master_contract .bridge-v2))
    (ok true)
  )
)

(set_master_contract .market-v2)