---
title: 'Audit "Gig Marketplace"'
author: "Friedger"
GeekdocBreadcrumb: false
GeekdocNav: false
---

# Overview

## Introduction
I was asked to audit the smart contract "Marketplace" in Clarity programming language.

The purpose of the smart contract is to manage a list of offers and requests for services (gigs) by trusted people. The marketplace acts as escrow for the service fees in STX. After a service has been provide, the client provides feedback on the result. Four levels of satisfaction are defined. The service provider has to react to the feedback in order to receive the service fee. If one party is not happy, an administrator is able to resolve disputes. The adminstrator receives a share of 2.5% of the service fees.

This audit was executed and written by Friedger (OpenIntents). The final report was published on August 21th, 2023.

## Code

A git repo was provided that contains the smart contract and tests for the smart contract. The source code is hosted at [https://github.com/zeroauthority-dao/marketplace-smart-contract](https://github.com/zeroauthority-dao/marketplace-smart-contract). For the review, the git commit [a884ebe](https://github.com/zeroauthority-dao/marketplace-smart-contract/commit/a884ebe76b4b832e642f71e22868f64f4fda3720) was used.

## Scope and Approach

The audit focussed on the following topics:

* correctness
* misuse of funds
* error handling
* centralization
* runtime errors

For the audit, I used
* manual code inspection
* manual tests with clarity console
* reproducable tests

# Findings 

## Description

The contract code is well structured and good to read. Tests cover nearly 100% of the code. The code is commented.

The escrow features are fully functional.

The disput handling is under the full control of the contract deployer. There is no way to change the contract deployer.

The service fee of 2.5% is fixed and can't be changed.

I have implemented some of the recommendations [https://github.com/friedger/trustless-rewards/commit/134de04c4ccdd8a40a963fcee6aa413aa1754588](https://github.com/friedger/trustless-rewards/commit/134de04c4ccdd8a40a963fcee6aa413aa1754588).

## Summary

### High Risk
None

### Medium Risk
* Trust: Fixed contract owner

### Low Risk
* Error Handling/Performance: Inconsistent read of map gig
* Performance: Unnecessary unwrap of function call and wrap as result
* Performance: If claused for logic expressions
* Code Readability: Satisfaction levels as numbers
* Code Readability: Inconsistent comments
* Usability: Parameter as result
* Usability: Extra transaction required
  
# Details

## Medium Risk

### Trust: Fixed contract owner

Functions `send-to-dispute-passed-time-acceptance` and `dao-vote-satisfaction` are guarded by the contract owner variable. This variable is initialized with the contract deployer. There is no public function to change this value.

Recommendations: Add setter function.

## Low Risk

### Error Handling/Performance: Inconsistent read of map gig

In function `accept-gig`, `decline-gig`, `redeem-back`, `send-to-dispute`, `send-to-dispute-passed-time-acceptance`, `satisfaction-vote-gig-as-client`, `satisfaction-vote-gig-as-artist`, the map of gigs is queried. The handling of the map entry is inconsistent. Sometimes the `map-get?` result is unwrapped immediately, using `unwrap-panic!`. Sometimes, the result is checked for some and thereafter unwrapped. 

Recommendation: Always assign variable `gig-info` with `(gig-info (unwrap-panic (map-get? gig gig-id)))`.

### Performance: Unnecessary unwrap of function call and wrap as result

In read-only functions `can-redeem`, the result is wrapped into an `ok` response, the function is used once and always unwraps the result.

Recommendations: Use function result directly as result.

### Performance: If claused for logic expressions

Function `check-is-expired`, `is-satifaction-valid` contain nested if clauses.

Recommendations: Use `and` and `or` directly.

### Code Readability: Satisfaction levels as numbers

The different levels of satisfaction are encoded as string. However, the constant names use numbers instead of the declared english words.

Recommendations: Use english words in constant names `vote-*`

### Code Readability: Inconsistent comments

The contracts contains comments at the top and at the bottom that describe functionality of the contract.

Recommendations: Place all comments regarding the general functionality at the top of the contract. Review the descriptions of the functions. Review the upper/lower case of comments.

### Usability: Parameter as result

The functions `accept-gig` and `decline-gig` return the function parameter as the result value.

Recommendations: Use `(ok true)` or return a helpful value like block-height as result.

### Usability: Extra transaction required

The function `send-to-dispute-passed-time-acceptance` has to be called before `dao-vote-satisfaction` when the time expired and the client and artist did not send the case to dispute.

Recommendations: Allow to call function `dao-vote-satisfaction` when the time has expired and the state is still in `accepted`.
