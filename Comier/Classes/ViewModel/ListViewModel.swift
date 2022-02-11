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
    
    private var _adapter: ListAdapter? = nil
    
    /**
     Debounce when updates: default is 300 miniseconds
     */
    open var debounceUpdateTime: Int {
        return 300
    }

    public func bindToAdapter(adapter: ListAdapter, completion: ((Bool) -> Void)? = nil) -> Disposable {
        _adapter = adapter
        performUpdates()
        return Disposables.create()
    }
	
    open func mapDataToElement() -> [Element] {
		return []
	}
	
    open func performUpdates(_ animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        self.elements.accept(mapDataToElement())
        var isAnimated = animated
        if !performUpdatesAnimated {
            isAnimated = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(debounceUpdateTime)/1000) { [weak self] in
            self?._adapter?.performUpdates(animated: isAnimated, completion: completion)
        }
	}
}
