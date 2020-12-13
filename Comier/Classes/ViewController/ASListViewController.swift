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

public typealias COListViewController<LVM: ListViewModel<ListDiffable>> = ListViewController<LVM>

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
        let stack = ASStackLayoutSpec.vertical()
        stack.style.flexGrow = 1
        stack.children = [collectionNode]
        return ASInsetLayoutSpec(insets: self.safeAreaInset, child: stack)
    }
}
