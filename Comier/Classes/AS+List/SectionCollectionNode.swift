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
    func viewModels(by section: any Differentiable) -> [any Differentiable]
    func nodeBlockForItem(for model: any Differentiable) -> ASCellNodeBlock
    func nodeItemDidUpdate(new: any Differentiable)
}

public protocol SectionDelegate: AnyObject {
    func didSelectItem(at indexPath: IndexPath)
}


open class ATSectionController<T: Differentiable>: AXSectionController {
    public var model: T?
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
    
    public override func performUpdates() {
        guard let dataSource, let model else  {
            return super.performUpdates()
        }
        let old = dataSource.viewModels.map({ AnyDifferentiable($0) })
        let new = dataSource.viewModels(by: model)
        let newMapping = new.map({AnyDifferentiable($0)})
        let stage = StagedChangeset(source: newMapping, target: old, section: section)
        collectionNode?.reload(using: stage, updateCellBlock: { [weak self] index, cell in
            self?.didUpdateCell(indexPath: index, cell: cell)
        },setData: { c in
            dataSource.viewModels = new
        })
    }
    
    private func didUpdateCell(indexPath: IndexPath, cell: ASCellNode?) {
        guard let cell = cell as? AXCellBindable else {
            return
        }
        if let model = self.dataSource?.viewModels[indexPath.item] {
            cell.didUpdate(model)
        } else {
            collectionNode?.reloadItems(at: [indexPath])
        }
    }
}

open class AXSectionController: NSObject {
    public weak var delegate: SectionDelegate?
    public weak var dataSource: SectionDataSource?
    public weak var collectionNode: ASCollectionNode?
    public var section: Int = 0
    
    public override init() {
        super.init()
    }
    
    public func didUpdate(section: any Differentiable) {}
    
    open func supplementaryElementKinds() -> [String] {
        return []
    }
    
    
    open func numberOfItem() -> Int {
        if let dataSource {
            return dataSource.viewModels.count
        }
        
        return 0
    }
    
    open func nodeBlockForSupplementaryElement(kind: String) -> ASCellNodeBlock {
        return {ASCellNode()}
    }
    
    open func nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        if let dataSource {
            let model = dataSource.viewModels[index]
            return dataSource.nodeBlockForItem(for: model)
        } else {
            return {ASCellNode()}
        }
    }
    
    public func refCellNode(by index: Int) -> ASCellNode? {
        return collectionNode?.nodeForItem(at: .init(item: index, section: section))
    }
    
    public func performUpdates() {
        collectionNode?.reloadSections(.init([section]))
    }
}

public protocol ASSectionControllerDataSource: AnyObject {
    func sectionController(by model: Any) -> AXSectionController
}

public final class ASSectionCollectionNode: ASDisplayNode, ASCollectionDataSource, ASCollectionDelegate {
    private let collectionNode: ASCollectionNode
    private var sectionControllers: [AXSectionController] = []
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
                        let section = self.dataSource?.sectionController(by: model) ?? AXSectionController()
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

public protocol AXCellBindable: AnyObject {
    func didUpdate(_ model: any Differentiable)
}

open class AXCellNode<T: Differentiable>: ASMCellNode, AXCellBindable {
    public func didUpdate(_ newValue: any Differentiable) {
        guard let castItem = newValue as? T else {return}
        didUpdate(castItem)
    }
    
    open func didUpdate(_ model: T) {}
}
