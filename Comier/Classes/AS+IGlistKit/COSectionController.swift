//
//  COSectionController.swift
//  Comier
//
//  Created by Bách on 12/12/2020.
//

import Foundation
import IGListKit
import AsyncDisplayKit

open class COSectionController: ListSectionController, ASSectionController {
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
}
