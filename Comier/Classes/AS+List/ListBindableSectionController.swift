//
//  File.swift
//  
//
//  Created by Bách VQ on 14/01/2023.
//

import Foundation
import DifferenceKit
import AsyncDisplayKit

typealias SectionUpdateBlock = ((ASCollectionNode) -> Void)

protocol SectionBatchUpdatable: AnyObject {
    var batchUpdates: SectionUpdateBlock? {get set}
}

public protocol ATListBindableDataSource: AnyObject {
    var viewModels: [any Differentiable] {get set}
    func viewModels(by section: any Differentiable) -> [any Differentiable]
    func nodeForItem(for model: any Differentiable) -> ASCellNode
}

public protocol ATListBindableDelegate: AnyObject {
    func didSelectItem(at index: Int)
    func didDeselectedItem(at index: Int)
}

open class ATListBindableSectionController<T: Differentiable>: AXSectionController, SectionBatchUpdatable {
    public typealias SectionModel = T
    public var model: T?
    public weak var delegate: ATListBindableDelegate?
    public weak var dataSource: (any ATListBindableDataSource)?
    
    internal var batchUpdates: SectionUpdateBlock? = nil
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
            let section = section
            batchUpdates = { batch in
                batch.reloadSections(IndexSet([section]))
            }
            return
        }
        
        let old = dataSource.viewModels
        let new = dataSource.viewModels(by: model)
        let source = old.map({ AnyDifferentiable($0)})
        let target = new.map({AnyDifferentiable($0)})
        let section = section
        let stage = StagedChangeset(source: source, target: target, section: section)
        batchUpdates = { [weak self] batch in
            guard let self = self else {return}
            let totalChangeCount = stage.map({$0.changeCount}).reduce(0, +)
            guard totalChangeCount > 0 else {return}
            if totalChangeCount > 30 {
                batch.reloadSections(IndexSet([section]))
                return
            }
            
            for changeSet in stage {
                guard changeSet.hasChanges else {continue}
                self.dataSource?.viewModels = changeSet.data.map({$0.base as! any Differentiable})
                
                if !changeSet.elementUpdated.isEmpty {
                    changeSet.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) }.forEach { indexPath in
                        let cell = batch.nodeForItem(at: indexPath)
                        self.didUpdateCell(indexPath: indexPath, cell: cell)
                    }
                }
                
                if !changeSet.elementInserted.isEmpty {
                    batch.insertItems(at: changeSet.elementInserted.map({.init(item: $0.element, section: $0.section)}))
                }
                
                if !changeSet.elementDeleted.isEmpty {
                    batch.deleteItems(at: changeSet.elementInserted.map({.init(item: $0.element, section: $0.section)}))
                }
                
                if !changeSet.elementMoved.isEmpty {
                    for (source, target) in changeSet.elementMoved {
                        batch.moveItem(at: IndexPath(item: source.element, section: source.section), to: IndexPath(item: target.element, section: target.section))
                    }
                }
            }
        }
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


