//
//  File.swift
//  
//
//  Created by Bách VQ on 13/01/2023.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit

public protocol ATListBindableDataSource: AnyObject {
    var viewModels: [any Differentiable] {get set}
    func viewModels(by section: any Differentiable) -> [any Differentiable]
    func nodeForItem(for model: any Differentiable) -> ASCellNode
}

public protocol ATListBindableDelegate: AnyObject {
    func didSelectItem(at indexPath: IndexPath)
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
            cell.didUpdate(newValue: model)
        } else {
            collectionNode?.reloadItems(at: [indexPath])
        }
    }
    
    open override func nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        if let dataSource {
            let model = dataSource.viewModels[index]
            return {
                let node = dataSource.nodeForItem(for: model)
                if let node = node as? AXCellBindable {
                    node.didUpdate(newValue: model)
                }
                return node
            }
        } else {
            return super.nodeBlockForItemAt(at: index)
        }
    }
    
    open override func numberOfItem() -> Int {
        return dataSource?.viewModels.count ?? super.numberOfItem()
    }
}

open class AXSectionController: NSObject {
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
        return 0
    }
    
    open func nodeBlockForSupplementaryElement(kind: String) -> ASCellNodeBlock {
        return {ASCellNode()}
    }
    
    open func nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        return {ASCellNode()}
    }
    
    public func refCellNode(by index: Int) -> ASCellNode? {
        return collectionNode?.nodeForItem(at: .init(item: index, section: section))
    }
    
    public func performUpdates() {
        collectionNode?.reloadSections(.init([section]))
    }
    
    public func sizeForItem(at: Int) -> ASSizeRange {
        guard let collectionNode else {return .init(min: .zero, max: .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))}
        let isHorizontal = collectionNode.scrollDirection.contains(.right)
        return .init(min: .zero, max: .init(width: isHorizontal ? CGFloat.greatestFiniteMagnitude : collectionNode.frame.width, height: isHorizontal ? collectionNode.frame.height : .greatestFiniteMagnitude))
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
        return section.nodeBlockForItemAt(at: indexPath.item)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, supplementaryElementKindsInSection section: Int) -> [String] {
        let controller = sectionControllers[section]
        return controller.supplementaryElementKinds()
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        return sectionControllers[indexPath.section].nodeBlockForSupplementaryElement(kind: kind)
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        return sectionControllers[indexPath.section].sizeForItem(at: indexPath.item)
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
