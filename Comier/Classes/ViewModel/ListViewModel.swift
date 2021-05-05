//
//  ListViewModel.swift
//  Seeler
//
//  Created by Bách on 7/15/20.
//  Copyright © 2020 BachVQ. All rights reserved.
//

import Foundation
import IGListKit
import RxSwift
import RxCocoa

public typealias ListViewModel<Element: ListDiffable> = BaseListViewModel<Element>

open class BaseListViewModel<Element: ListDiffable>: ViewModel {
	
    public let elements = BehaviorRelay<[Element]>(value: [])
    public var performUpdatesAnimated: Bool = false

    public func bindToAdapter(adapter: ListAdapter, completion: ((Bool) -> Void)? = nil) -> Disposable {
        return elements.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            adapter.performUpdates(animated: self.performUpdatesAnimated, completion: completion)
        })
    }
	
    open func mapDataToElement() -> [Element] {
		return []
	}
	
    public func performUpdates() {
        self.elements.accept(mapDataToElement())
	}
}
