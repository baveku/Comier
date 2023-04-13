//
//  File.swift
//  
//
//  Created by Bách VQ on 14/01/2023.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit

public typealias AnySectionController = BaseSectionController
public protocol ASSectionControllerDataSource: AnyObject {
    func sectionController(by model: Any) -> AnySectionController
}

open class BaseSectionController: NSObject {
    public weak var collectionNode: ASCollectionNode!
    public var section: Int = 0
    
    public override init() {
        super.init()
    }
    
    public func didUpdate(section: any Differentiable) {}
    
    func supplementaryElementKinds() -> [String] {
        return []
    }
    
    
    func numberOfItem() -> Int {
        return 0
    }
    
    func _nodeBlockForSupplementaryElement(kind: String) -> ASCellNodeBlock {
        return {ASCellNode()}
    }
    
    func _nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        return {ASCellNode()}
    }
    
    func cellNode(by index: Int) -> ASCellNode? {
        return collectionNode?.nodeForItem(at: .init(item: index, section: section))
    }
    
    public func _performUpdates() {
        collectionNode?.reloadSections(.init([section]))
    }
    
    func _sizeForItem(at index: Int) -> ASSizeRange {
        return _defaultSize(at: index)
    }
    
    func _defaultSize(at index: Int) -> ASSizeRange {
        guard let collectionNode else {return .init(min: .zero, max: .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))}
        let isHorizontal = collectionNode.scrollDirection.contains(.right)
        return .init(min: .zero, max: .init(width: isHorizontal ? CGFloat.greatestFiniteMagnitude : collectionNode.frame.width, height: isHorizontal ? collectionNode.frame.height : .greatestFiniteMagnitude))
    }
    
    public func reload() {
        collectionNode.reloadSections(IndexSet([section]))
    }
    
    public func reloadItems(_ items: [Int]) {
        collectionNode.reloadItems(at: items.map({.init(item: $0, section: section)}))
    }
    
    internal func _didSelected(at index: Int) {}
    internal func _didDeselected(at index: Int) {}
}

open class AXSectionController: BaseSectionController {
    
    override func _sizeForItem(at index: Int) -> ASSizeRange {
        return sizeForItem(at: index) ?? _defaultSize(at: index)
    }
    
    open func sizeForItem(at index: Int) -> ASSizeRange? {
        return nil
    }
    
    override func _didSelected(at index: Int) {
        didSelected(at: index)
    }
    
    override func _didDeselected(at index: Int) {
        didDeselected(at: index)
    }
    
    open func didSelected(at index: Int) {}
    open func didDeselected(at index: Int) {}
}
