//
//  File.swift
//  
//
//  Created by Bách VQ on 13/01/2023.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit


public final class ASSectionCollectionNode: ASCollectionNode, ASCollectionDataSource, ASCollectionDelegate {
    private var sectionControllers: [BaseSectionController] = []
    private var _models: [AnyDifferentiable] = []
    
    public func configureCollectionNode(_ block: (ASCollectionNode) -> Void) {
        block(self)
    }
    
    public weak var sectionDataSource: ASSectionControllerDataSource? = nil
    public weak var batchDelegate: ASSectionBatchUpdatable? = nil
    
    public func setRefreshControl(_ control: UIRefreshControl) {
        view.refreshControl = control
    }
    
    public init(layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: layout, layoutFacilitator: nil)
        
        automaticallyRelayoutOnSafeAreaChanges = true
        delegate = self
        dataSource = self
    }
    
    public func performUpdates(_ models: [any Differentiable], completion: (() -> Void)? = nil) {
        let mapAny = models.map {AnyDifferentiable($0)}
        
        if self._models.isEmpty {
            self._models = mapAny
            self.reloadData(completion: completion)
            return
        }
        
        let stage: StagedChangeset = StagedChangeset(source: _models, target: mapAny, section: 0)
        
        let totalChangeCount = stage.map({$0.changeCount}).reduce(0, +)
        guard totalChangeCount > 0 else {
            completion?()
            return
        }
        
        let group = DispatchGroup()
        if totalChangeCount > 200 {
            self._models = mapAny
            self.reloadData(completion: completion)
            return
        }
        
        for changeset in stage {
            group.enter()
            performBatchUpdates { [weak self] in
                guard let self else {return}
                guard changeset.hasChanges else {return}
                self._models = changeset.data
                if !changeset.elementUpdated.isEmpty {
                    for item in changeset.elementUpdated {
                        let controller = self.sectionControllers[item.element]
                        controller.didUpdate(section: self._models[item.element].base as! (any Differentiable))
                    }
                }
                var deleteIndexSet: IndexSet = .init()
                var insertIndexSet: IndexSet = .init()
                if !changeset.elementDeleted.isEmpty {
                    deleteIndexSet = IndexSet(changeset.elementDeleted.map({$0.element}))
                    for index in deleteIndexSet {
                        self.sectionControllers.remove(at: index)
                    }
                }
                
                if !changeset.elementInserted.isEmpty {
                    for item in changeset.elementInserted {
                        let model = self._models[item.element].base as! (any Differentiable)
                        let section = self.sectionDataSource?.sectionController(by: model) ?? AXSectionController()
                        section.collectionNode = self
                        section.section = item.element
                        self.sectionControllers.insert(section, at: item.element)
                    }
                    insertIndexSet = IndexSet(changeset.elementInserted.map({$0.element}))
                }
                
                self.deleteSections(deleteIndexSet)
                self.insertSections(insertIndexSet)
                if !changeset.elementMoved.isEmpty {
                    for item in changeset.elementMoved {
                        self.sectionControllers.swapAt(item.source.element, item.target.element)
                        // update index
                        self.sectionControllers.enumerated().forEach { ind, sec in
                            sec.section = ind
                        }
                        self.moveSection(item.source.element, toSection: item.target.element)
                    }
                }
                
            } completion: { _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion?()
        }
    }
    
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return sectionControllers.count
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        let controller = sectionControllers[section]
        return controller.numberOfItem()
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let section = sectionControllers[indexPath.section]
        return section._nodeBlockForItemAt(at: indexPath.item)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, supplementaryElementKindsInSection section: Int) -> [String] {
        let controller = sectionControllers[section]
        return controller.supplementaryElementKinds()
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        return sectionControllers[indexPath.section]._nodeBlockForSupplementaryElement(kind: kind)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        return sectionControllers[indexPath.section]._sizeForItem(at: indexPath.item)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        sectionControllers[indexPath.section]._didSelected(at: indexPath.item)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        sectionControllers[indexPath.section]._didDeselected(at: indexPath.item)
    }
    
    public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        batchDelegate?.shouldBatchFetch(for: collectionNode) ?? false
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        batchDelegate?.willBeginBatchFetch(collectionNode, context: context)
    }
    
    public override func reloadData(completion: (() -> Void)? = nil) {
        self.sectionControllers = _models.enumerated().map({ ind, m in
            let model = m.base
            let section = sectionDataSource?.sectionController(by: model) ?? .init()
            section.section = ind
            section.collectionNode = self
            section.didUpdate(section: model as! (any Differentiable))
            return section
        })
        super.reloadData(completion: completion)
    }
}

protocol CellBindable {
    
}

protocol BaseCellBindable: AnyObject {
    func didUpdate(newValue: any Differentiable)
}

open class BaseAXCellNode: ASMCellNode, BaseCellBindable {
    func didUpdate(newValue: any Differentiable) {}
}

open class AXCellNode: BaseAXCellNode {
    override func didUpdate(newValue: any Differentiable) {}
}

open class ATCellNode<T: Differentiable>: BaseAXCellNode {
    var model: T!
    public convenience init(model: T) {
        self.init()
        self.model = model
        didUpdate(model)
    }
    
    override func didUpdate(newValue: any Differentiable) {
        guard let castItem = newValue as? T else {return}
        self.model = castItem
        didUpdate(castItem)
    }
    
    open func didUpdate(_ model: T) {}
}

public protocol ASSectionBatchUpdatable: AnyObject {
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool
    func willBeginBatchFetch(_ collectionNode: ASCollectionNode, context: ASBatchContext)
}
