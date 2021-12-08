//
//  Promises+FncBuilder.swift
//  VoiceCall
//
//  Created by Bách on 29/10/2021.
//  Copyright © 2021 Bitu. All rights reserved.
//

import Foundation
import Promises
import RxSwift
import RxRelay

precedencegroup PipeRight {
    associativity: left
    higherThan: CatchPrecedence
}

infix operator |> : PipeRight
@discardableResult
public func |><T, U>(_ promise: Promise<T>, nextAction: @escaping (T) -> U) -> Promise<U> {
    return promise.then(nextAction)
}

@discardableResult
public func |><T>(_ promise: Promise<T>, nextAction: @escaping (T) -> Void) -> Promise<Void> {
    return promise.then(nextAction)
}

public func |><T>(_ observable: Observable<T>, onNext: @escaping (T) -> Void) -> Disposable {
	return observable.subscribe(onNext: onNext)
}

public func |><T>(_ observable: BehaviorRelay<T>, onNext: @escaping (T) -> Void) -> Disposable {
	return observable.subscribe(onNext: onNext)
}

precedencegroup CatchPrecedence {
    associativity: left
    higherThan: AlwaysPrecedence
    lowerThan: BitwiseShiftPrecedence
}

infix operator ?> : CatchPrecedence

@discardableResult
public func ?><T>(_ promise: Promise<T>, catchAction: @escaping (Error) -> Void) -> Promise<T> {
    return promise.catch(catchAction)
}

precedencegroup AlwaysPrecedence {
    associativity: left
    higherThan: DefaultPrecedence
}

infix operator +> : AlwaysPrecedence

@discardableResult
public func +><T>(_ promise: Promise<T>, nextAction: @escaping () -> Void) -> Promise<T> {
    return promise.always(nextAction)
}
