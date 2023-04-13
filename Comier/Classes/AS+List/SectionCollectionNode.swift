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
            self.sectionControllers = mapAny.enumerated().map({ ind, m in
                let model = m.base
                let section = sectionDataSource?.sectionController(by: model) ?? .init()
                section.section = ind
                section.collectionNode = self
                section.didUpdate(section: model as! (any Differentiable))
                return section
            })
            self.reloadData {
                completion?()
            }
            return
        }
        
        let stage: StagedChangeset = StagedChangeset(source: _models, target: mapAny, section: 0)
        waitUntilAllUpdatesAreProcessed()
        performBatchUpdates { [weak self] in
            guard let self else {return}
            for changeset in stage {
                guard changeset.hasChanges else {return}
                self._models = changeset.data
                if !changeset.elementUpdated.isEmpty {
                    for item in changeset.elementUpdated {
                        let controller = self.sectionControllers[item.element]
                        controller.didUpdate(section: self._models[item.element].base as! (any Differentiable))
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
                    self.insertSections(IndexSet(changeset.elementInserted.map({$0.element})))
                }
                
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
                
                if !changeset.elementDeleted.isEmpty {
                    let indexSet = IndexSet(changeset.elementDeleted.map({$0.element}))
                    for index in indexSet {
                        self.sectionControllers.remove(at: index)
                    }
                    self.deleteSections(indexSet)
                }
            }
        } completion: { _ in
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
    override func didUpdate(newValue: any Differentiable) {
        guard let castItem = newValue as? T else {return}
        didUpdate(castItem)
    }
    
    open func didUpdate(_ model: T) {}
}
