//
//  COSectionController.swift
//  Comier
//
//  Created by Bách on 12/12/2020.
//

import Foundation
import IGListDiffKit
import IGListKit
import AsyncDisplayKit

public protocol SInjectViewModelable: AnyObject, SectionViewmodelable {
    associatedtype ViewModelType: ViewModel
}

/**
 Binding ViewModel from ViewController to Section Controller
 */
public protocol SectionViewmodelable {
    func bindRootViewModel()
}

public extension SInjectViewModelable where Self: COSectionController {
    
    /**
     Get ViewModel from ASViewModelViewController
     */
    var rootViewModel: ViewModelType? {
        return (viewController as? ASViewModelController<ViewModelType>)?.viewModel
    }
}

open class COSectionController: ListSectionController, ASSectionController, ListSupplementaryViewSource, ASSupplementaryNodeSource {
    public override init() {
        super.init()
        if let self = self as? SectionViewmodelable {
            self.bindRootViewModel()
        }
    }
    
    public var context: ListCollectionContext! {
        return self.collectionContext
    }
    
    open func supportedElementKinds() -> [String] {
        return []
    }
    
    public func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        return ASIGListSupplementaryViewSourceMethods.viewForSupplementaryElement(ofKind: elementKind, at: index, sectionController: self)
    }
    
    public func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return ASIGListSupplementaryViewSourceMethods.sizeForSupplementaryView(ofKind: elementKind, at: index)
    }
    
    open func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        return {() in return ASCellNode()}
    }
    
    open func nodeForItem(at index: Int) -> ASCellNode {
        return ASCellNode()
    }
    
    open override func numberOfItems() -> Int {
        return 1
    }
    
    open override func didUpdate(to object: Any) {}
    open override func didSelectItem(at index: Int) {}
    
    //ASDK Replacement
    public override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods.sizeForItem(at: index)
    }
    
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }
    
    open func nodeBlockForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASCellNodeBlock {
        return { ASCellNode()}
    }
    
    open func sizeRangeForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASSizeRange {
        return ASSizeRangeUnconstrained
    }
    
    public func visibleCellNodes() -> [ASCellNode] {
        return context.visibleCellNodes(for: self) ?? []
    }
    
    public func visibleCellNodes<T: ASCellNode>() -> [T] {
        let nodes = context.visibleCellNodes(for: self)
        return nodes.compactMap({$0 as? T})
    }
    
    public func nodeForItem<T: ASMCellNode>(from index: Int) -> T? {
        return context.nodeForItem(at: index, section: self) as? T
    }
}

public extension ListCollectionContext {
    public func visibleCellNodes(for section: ListSectionController) -> [ASCellNode] {
        let cells = self.visibleCells(for: section)
        let nodes = cells.compactMap({ c in return (c as? _ASCollectionViewCell)?.node})
        return nodes ?? []
    }
    
    public func nodeForItem(at index: Int, section: ListSectionController) -> ASCellNode? {
        return (self.cellForItem(at: index, sectionController: section) as? _ASCollectionViewCell)?.node
    }
}
