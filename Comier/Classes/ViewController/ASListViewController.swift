//
//  ASListViewController.swift
//  Comier
//
//  Created by Bách on 11/12/2020.
//

import Foundation
import UIKit
import AsyncDisplayKit
import RxSwift

open class ListViewController<LVM: ListViewModel<ListDiffable>>: COViewController<LVM>, ListAdapterDataSource {
    open func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel.elements.value
    }
    
    open func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ListSectionController()
    }
    
    open func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    open var collectionNode: ASCollectionNode = {
        let node = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        node.style.flexGrow = 1
        return node
    }()
    
    open lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        adapter.setASDKCollectionNode(collectionNode)
        adapter.dataSource = self
        return adapter
    }()
    
    open override func bindToViewModel() {
        super.bindToViewModel()
        self.viewModel.bindToAdapter(adapter: adapter).disposed(by: disposeBag)
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout {
                collectionNode.flexGrow(1)
            }.useSafeAreaInset()
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    open override func transitionLayout(animated: Bool = true, shouldMeasureAsync: Bool = false, completion: (() -> Void)? = nil) {
        self.node.transitionLayout(withAnimation: animated, shouldMeasureAsync: shouldMeasureAsync, measurementCompletion: completion)
    }
    open override func animateLayoutTransition(_ context: ASContextTransitioning) {}
    open override func didCompleteLayoutTransition(_ context: ASContextTransitioning) {}
    
    public override var nodeHeight: CGFloat {
        return self.node.calculatedSize.height
    }
    
    open override func nodeDidLayout() {}
}
