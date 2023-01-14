//
//  File.swift
//  
//
//  Created by Bách VQ on 13/01/2023.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit


public final class ASSectionCollectionNode: ASDisplayNode, ASCollectionDataSource, ASCollectionDelegate {
    private let collectionNode: ASCollectionNode
    private var sectionControllers: [BaseSectionController] = []
    private var _models: [AnyDifferentiable] = []
    
    public weak var dataSource: ASSectionControllerDataSource? = nil
    
    public func setRefreshControl(_ control: UIRefreshControl) {
        collectionNode.view.refreshControl = control
    }
    
    public init(layout: UICollectionViewLayout) {
        collectionNode = .init(collectionViewLayout: layout)
        super.init()
        automaticallyManagesSubnodes = true
        automaticallyRelayoutOnSafeAreaChanges = true
        collectionNode.automaticallyRelayoutOnSafeAreaChanges = true
        collectionNode.delegate = self
        collectionNode.dataSource = self
    }
    
    public override var backgroundColor: UIColor? {
        get {
            return collectionNode.backgroundColor
        }
        set {
            collectionNode.backgroundColor = newValue
        }
    }
    
    public func performUpdates(_ models: [any Differentiable], completion: (() -> Void)? = nil) {
        let mapAny = models.map {AnyDifferentiable($0)}
        
        if self._models.isEmpty {
            self._models = mapAny
            self.sectionControllers = mapAny.enumerated().map({ ind, m in
                let model = m.base
                let section = dataSource?.sectionController(by: model) ?? .init()
                section.section = ind
                section.collectionNode = collectionNode
                section.didUpdate(section: model as! (any Differentiable))
                return section
            })
            self.collectionNode.reloadData {
                completion?()
            }
            return
        }
        
        let stage: StagedChangeset = StagedChangeset(source: _models, target: mapAny, section: 0)
        collectionNode.waitUntilAllUpdatesAreProcessed()
        collectionNode.performBatchUpdates { [weak self] in
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
                        let section = self.dataSource?.sectionController(by: model) ?? AXSectionController()
                        section.collectionNode = self.collectionNode
                        section.section = item.element
                        self.sectionControllers.insert(section, at: item.element)
                    }
                    self.collectionNode.insertSections(IndexSet(changeset.elementInserted.map({$0.element})))
                }
                
                if !changeset.elementMoved.isEmpty {
                    for item in changeset.elementMoved {
                        self.sectionControllers.swapAt(item.source.element, item.target.element)
                        // update index
                        self.sectionControllers.enumerated().forEach { ind, sec in
                            sec.section = ind
                        }
                        self.collectionNode.moveSection(item.source.element, toSection: item.target.element)
                    }
                }
                
                if !changeset.elementDeleted.isEmpty {
                    let indexSet = IndexSet(changeset.elementDeleted.map({$0.element}))
                    for index in indexSet {
                        self.sectionControllers.remove(at: index)
                    }
                    self.collectionNode.deleteSections(indexSet)
                }
            }
        } completion: { _ in
            completion?()
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            collectionNode.flexGrow(1)
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
        return sectionControllers[indexPath.section]._didSelected(at: indexPath.item)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        return sectionControllers[indexPath.section]._didDeselected(at: indexPath.item)
    }
}

public protocol AXCellBindable: AnyObject {
    func didUpdate(newValue: any Differentiable)
}

open class AXCellNode: ASMCellNode, AXCellBindable {
    public func didUpdate(newValue: any Differentiable) {}
}

open class ATCellNode<T: Differentiable>: AXCellNode {
    public override func didUpdate(newValue: any Differentiable) {
        guard let castItem = newValue as? T else {return}
        didUpdate(castItem)
    }
    
    open func didUpdate(_ model: T) {}
}
