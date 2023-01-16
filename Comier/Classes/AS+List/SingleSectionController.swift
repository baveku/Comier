//
//  File.swift
//  
//
//  Created by Bách VQ on 14/01/2023.
//

import Foundation
import DifferenceKit
import AsyncDisplayKit

open class SingleNodeSectionController<T: Differentiable>: BaseSectionController {
    public typealias SectionModel = T
    var base: SectionModel!
    let cellBlock: (_ section: any Differentiable) -> ASCellNode
    public init(cellBlock: @escaping (_ section: any Differentiable) -> ASCellNode) {
        self.cellBlock = cellBlock
        super.init()
    }
    
    public override func didUpdate(section: any Differentiable) {
        let willUpdate = base != nil
        self.base = section as? SectionModel
        if willUpdate {
            reload()
        }
    }
    
    public init(viewBlock: @escaping (_ section: any Differentiable) -> UIView) {
        self.cellBlock = { section in
            return ASCellNode {
                return viewBlock(section)
            }
        }
        super.init()
    }
    
    override func numberOfItem() -> Int {
        return 1
    }
    
    override func _nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        let cellBlock = cellBlock
        if let section = base {
            return {
                cellBlock(section)
            }
        } else {
            return {ASCellNode()}
        }
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
