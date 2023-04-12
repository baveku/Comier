//
//  File.swift
//  
//
//  Created by Bách VQ on 14/01/2023.
//

import Foundation
import DifferenceKit
import AsyncDisplayKit

public protocol ATListBindableDataSource: AnyObject {
    var viewModels: [any Differentiable] {get set}
    func viewModels(by section: any Differentiable) -> [any Differentiable]
    func nodeForItem(for model: any Differentiable) -> ASCellNode
}

public protocol ATListBindableDelegate: AnyObject {
    func didSelectItem(at index: Int)
    func didDeselectedItem(at index: Int)
}

open class ATListBindableSectionController<T: Differentiable>: AXSectionController {
    public typealias SectionModel = T
    public var model: T?
    public weak var delegate: ATListBindableDelegate?
    public weak var dataSource: (any ATListBindableDataSource)?
    public override func didUpdate(section: any Differentiable) {
        guard let value = section as? T else {return}
        didUpdate(value: value)
    }
    
    open func didUpdate(value: T) {
        let canUpdate = model != nil
        self.model = value
        if canUpdate {
            performUpdates()
        } else if let dataSource {
            dataSource.viewModels = dataSource.viewModels(by: value)
        }
    }
    
    public func performUpdates() {
        guard let dataSource, let model else  {
            return super._performUpdates()
        }
        
        let old = dataSource.viewModels.map({ AnyDifferentiable($0) })
        let new = dataSource.viewModels(by: model)
        let newMapping = new.map({AnyDifferentiable($0)})
        let stage = StagedChangeset(source: old, target: newMapping, section: section)
        collectionNode?.reload(using: stage, updateCellBlock: { [weak self] index, cell in
            self?.didUpdateCell(indexPath: index, cell: cell)
        },setData: { c in
            dataSource.viewModels = new
        })
    }
    
    private func didUpdateCell(indexPath: IndexPath, cell: ASCellNode?) {
        guard let cell = cell as? BaseCellBindable else {
            return
        }
        if let model = self.dataSource?.viewModels[indexPath.item] {
            cell.didUpdate(newValue: model)
        } else {
            collectionNode?.reloadItems(at: [indexPath])
        }
    }
    
    override func _nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        if let dataSource {
            let model = dataSource.viewModels[index]
            return {
                let node = dataSource.nodeForItem(for: model)
                if let node = node as? BaseCellBindable {
                    node.didUpdate(newValue: model)
                }
                return node
            }
        } else {
            return super._nodeBlockForItemAt(at: index)
        }
    }
    
    open override func numberOfItem() -> Int {
        return dataSource?.viewModels.count ?? super.numberOfItem()
    }
    
    override func _sizeForItem(at index: Int) -> ASSizeRange {
        if let dataSource {
            let model = dataSource.viewModels[index]
            return sizeForCell(model, at: index) ?? _defaultSize(at: index)
        }
        return super._sizeForItem(at: index)
    }
    
    open func sizeForCell(_ model: any Differentiable, at index: Int) -> ASSizeRange? {
        return nil
    }
    
    override func _didSelected(at index: Int) {
        delegate?.didSelectItem(at: index)
    }
    
    override func _didDeselected(at index: Int) {
        delegate?.didDeselectedItem(at: index)
    }
}


