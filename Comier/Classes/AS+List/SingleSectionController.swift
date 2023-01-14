//
//  File.swift
//  
//
//  Created by Bách VQ on 14/01/2023.
//

import Foundation
import DifferenceKit
import AsyncDisplayKit

open class SingleNodeSectionController: BaseSectionController {
    let cellBlock: ASCellNodeBlock
    public init(cellBlock: @escaping ASCellNodeBlock) {
        self.cellBlock = cellBlock
        super.init()
    }
    
    public init(viewBlock: @escaping ASDisplayNodeViewBlock) {
        self.cellBlock = {
            return ASCellNode(viewBlock: viewBlock)
        }
        super.init()
    }
    
    override func numberOfItem() -> Int {
        return 1
    }
    
    override func _nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        return cellBlock
    }
    
    override func _sizeForItem(at index: Int) -> ASSizeRange {
        return sizeForItem(at: index) ?? _defaultSize(at: index)
    }
    
    open func sizeForItem(at index: Int) -> ASSizeRange? {
        return nil
    }
    
    override func _didSelected(at index: Int) {
        didSelected()
    }
    
    override func _didDeselected(at index: Int) {
        didDeselected()
    }
    
    open func didSelected() {}
    open func didDeselected() {}
}
