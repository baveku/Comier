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
import IGListKit

open class ListViewController<LVM: ListViewModel<ListDiffable>>: ASViewModelController<LVM>, ListAdapterDataSource {
    open func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel.elements.value
    }
    
    open func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ListSectionController()
    }
    
    open func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    open var workingRangeSize: Int {
        return 1
    }
    
    open var collectionNode: ASCollectionNode = {
        let node = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        node.style.flexGrow = 1
        return node
    }()
    
    open lazy var adapter: ListAdapter = {
        var updater = ListAdapterUpdater()
        let adapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: workingRangeSize)
        adapter.setASDKCollectionNode(collectionNode)
        
        refCollectionNode = collectionNode
        adapter.dataSource = self
        return adapter
    }()
    
    open override func bindToViewModel() {
        super.bindToViewModel()
        self.viewModel.bindToAdapter(adapter: adapter) { [weak self] finished in
            self?.adapterDidPerformUpdate(finished)
        }.disposed(by: disposeBag)
    }

    @objc open override func updateUI() {
        super.updateUI()
        self.adapter.performUpdates(animated: false) { [weak self] finished in
            self?.adapterDidPerformUpdate(finished)
        }
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout {
                collectionNode.flexGrow(1)
            }.useSafeAreaInset()
        }
        
    }
    
    open func adapterDidPerformUpdate(_ finished: Bool) {}
    
    open override func transitionLayout(animated: Bool = true, shouldMeasureAsync: Bool = false, completion: (() -> Void)? = nil) {
        self.node.transitionLayout(withAnimation: animated, shouldMeasureAsync: shouldMeasureAsync, measurementCompletion: completion)
    }
    open override func animateLayoutTransition(_ context: ASContextTransitioning) {}
    open override func didCompleteLayoutTransition(_ context: ASContextTransitioning) {}
    
    public override var nodeHeight: CGFloat {
        return self.node.calculatedSize.height
    }
    
    open override func nodeLayout() {}
}
