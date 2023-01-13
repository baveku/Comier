//
//  File.swift
//  
//
//  Created by Bách VQ on 13/01/2023.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit

public protocol SectionDataSource: AnyObject {
    var viewModels: [any Differentiable] {get set}
    func nodeBlockForItem(for model: any Differentiable) -> ASCellNodeBlock
    func nodeItemDidUpdate(new: any Differentiable)
}

public protocol SectionDelegate: AnyObject {
    func didSelectItem(at indexPath: IndexPath)
}

public class SectionController: NSObject {
    public weak var delegate: SectionDelegate?
    public weak var dataSource: SectionDataSource?
    public weak var collectionNode: ASCollectionNode?
    
    public var section: Int = 0
    
    public override init() {
        super.init()
    }
    
    public func didUpdate(section: any Differentiable) {}
    
    public func supplementaryElementKinds() -> [String] {
        return []
    }
    
    
    public func numberOfItem() -> Int {
        if let dataSource {
            return dataSource.viewModels.count
        }
        
        return 1
    }
    
    public func nodeBlockForSupplementaryElement(kind: String) -> ASCellNodeBlock {
        return {ASCellNode()}
    }
    
    public func nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        if let dataSource {
            let model = dataSource.viewModels[index]
            return dataSource.nodeBlockForItem(for: model)
        } else {
            return {ASCellNode()}
        }
    }
}

public protocol ASSectionControllerDataSource: AnyObject {
    func sectionController(by model: Any) -> SectionController
}

public final class ASSectionCollectionNode: ASDisplayNode, ASCollectionDataSource, ASCollectionDelegate {
    private let collectionNode: ASCollectionNode
    private var sectionControllers: [SectionController] = []
    private var _models: [AnyDifferentiable] = []
    
    public weak var dataSource: ASSectionControllerDataSource? = nil
    
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
    
    public func performUpdates(_ models: [any Differentiable]) {
        let mapAny = models.map {AnyDifferentiable($0)}
        let stage: StagedChangeset = StagedChangeset(source: _models, target: mapAny, section: 0)
        collectionNode.waitUntilAllUpdatesAreProcessed()
        collectionNode.performBatchUpdates { [weak self] in
            guard let self else {return}
            for changeset in stage {
                guard changeset.hasChanges else {return}
                self._models = mapAny
                if !changeset.elementUpdated.isEmpty {
                    for item in changeset.elementUpdated {
                        let controller = self.sectionControllers[item.element]
                        controller.didUpdate(section: _models[item.element].base as! (any Differentiable))
                    }
                }
                
                if !changeset.elementInserted.isEmpty {
                    for item in changeset.elementInserted {
                        let model = self._models[item.element].base as! (any Differentiable)
                        let section = self.dataSource?.sectionController(by: model) ?? SectionController()
                        section.collectionNode = self.collectionNode
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
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            collectionNode.flexGrow(1)
        }
    }
    
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return _models.count
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        let controller = sectionControllers[section]
        return controller.numberOfItem()
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let section = sectionControllers[indexPath.section]
        return section.nodeBlockForItemAt(at: indexPath.item)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, supplementaryElementKindsInSection section: Int) -> [String] {
        let controller = sectionControllers[section]
        return controller.supplementaryElementKinds()
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        return sectionControllers[indexPath.section].nodeBlockForSupplementaryElement(kind: kind)
    }
}
