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
    
    public private(set) var adapter: ListAdapter? = nil
    
    private var _queueUpdatesCompletion: [((Bool) -> Void)?] = []
    private var _perfomUpdatePublishSubject = PublishSubject<Void>()
    private var _isAnimated: Bool = false
    private var adapterCompletionHandler: ((Bool) -> Void)? = nil
    
    /**
     Debounce when updates: default is 300 miniseconds
     */
    open var debounceUpdateTime: Int {
        return 300
    }
    
    open override func viewModelDidLoad() {
        super.viewModelDidLoad()
        _perfomUpdatePublishSubject.debounce(.milliseconds(debounceUpdateTime), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            performViewUpdates()
        }) => disposeBag
    }

    public func bindToAdapter(adapter: ListAdapter, completion: ((Bool) -> Void)? = nil) -> Disposable {
        self.adapter = adapter
        self.adapterCompletionHandler = completion
        performViewUpdates()
        return Disposables.create()
    }
	
    open func mapDataToElement() -> [Element] {
		return []
	}
	
    open func performUpdates(_ animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        self._isAnimated = animated
        if !performUpdatesAnimated {
            self._isAnimated = false
        }
        _queueUpdatesCompletion.append(completion)
        _perfomUpdatePublishSubject.onNext(())
	}
    
    open func didFinishedPefromUpdates() {}
    
    open func performViewUpdates() {
        elements.accept(mapDataToElement())
        let completions = _queueUpdatesCompletion
        if adapter?.collectionView != nil, adapter?.dataSource != nil, adapter?.delegate != nil {
            adapter?.performUpdates(animated: self._isAnimated) { [weak self] finished in
                guard let self else {return}
                for completion in completions {
                    completion?(finished)
                }
                if finished {
                    _queueUpdatesCompletion = []
                    didFinishedPefromUpdates()
                }
                adapterCompletionHandler?(finished)
            }
        }
    }
}
