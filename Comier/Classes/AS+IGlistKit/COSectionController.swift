//
//  COSectionController.swift
//  Comier
//
//  Created by Bách on 12/12/2020.
//

import Foundation
import IGListKit
import AsyncDisplayKit

open class COSectionController: ListSectionController, ASSectionController, ListSupplementaryViewSource, ASSupplementaryNodeSource {
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
}
