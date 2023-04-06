//
//  COListBindableSectionController.swift
//  Comier
//
//  Created by Bách on 12/12/2020.
//

import Foundation
import IGListKit
import IGListDiffKit
import AsyncDisplayKit
import DifferenceKit

public typealias ListModelable = NSObject & ListDiffable

public protocol ASListBindingDataSource: AnyObject {
    func viewModels(for object: Any) -> [ListDiffable]
    func nodeBlockForViewModel(at viewModel: ListDiffable) -> ASCellNode
}

public protocol ASListBindingDelegate: AnyObject {
    func didSelected(at index: Int)
    func didDeselected(at index: Int)
}

public extension ASListBindingDelegate {
    func didSelected(at index: Int) {}
    func didDeselected(at index: Int) {}
}

enum SectionState {
    case idle
    case queued
    case applied
}

open class ASListBindingSectionController<Element: ListDiffable>: COSectionController {
    public typealias SectionModel = Element
    
    public var viewModels: [ListDiffable] = []
    public var object: SectionModel? = nil
    var state: SectionState = .idle
    
    var lastWaitForUpdate: (animated: Bool, shouldUpdateCell: Bool, completion: ((Bool) -> Void)?)? = nil
    
    public weak var dataSource: ASListBindingDataSource? = nil
    public weak var delegate: ASListBindingDelegate? = nil
    
    public override func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let cellModel = self.viewModels[index]
        let block: ASCellNodeBlock = { [weak self] in
            guard let self = self else {return COCellNode<ListDiffable>()}
            let cell = self.dataSource?.nodeBlockForViewModel(at: cellModel)
            cell?.neverShowPlaceholders = true
            if let cell = cell as? ListBindable {
                cell.bindViewModel(cellModel)
            }
            return cell ?? ASCellNode()
        }
        return block
    }
    
    public override init() {
        super.init()
    }
    
    private var datasourceProxy: ASListBindingDataSourceProxy? = nil
    public func setDataSourceV2(_ datasource: ASSwiftListBindingDataSource) {
        datasourceProxy = ASListBindingDataSourceProxy(dataSource: datasource)
        self.dataSource = datasourceProxy
    }
    
    public override func numberOfItems() -> Int {
        return viewModels.count
    }
    
    open var willUpdateWithAnimation = true
    
    open override func didUpdate(to object: Any) {
        let firstUpdate = self.object == nil
        self.object = object as? Element
        
        if firstUpdate {
            let viewModels = self.dataSource?.viewModels(for: object)
            self.viewModels = objectsWithDuplicateIdentifiersRemoved(viewModels) ?? []
        } else {
            self.updateAnimated(animated: willUpdateWithAnimation)
        }
    }
    
    public override func didSelectItem(at index: Int) {
        delegate?.didSelected(at: index)
    }
    
    public override func didDeselectItem(at index: Int) {
        delegate?.didDeselected(at: index)
    }
    
    open override func sizeForItem(at index: Int) -> CGSize {
        let size = ASIGListSectionControllerMethods.sizeForItem(at: index)
        return size
    }
    
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }
    
    public func updateAnimated(animated: Bool, shouldUpdateCell: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard self.object != nil else {return}
        if self.state != .idle {
            self.lastWaitForUpdate = (animated, shouldUpdateCell, completion)
            return
        }
        DispatchQueue.global().async { [weak self] in
            guard let self else {return}
            let object = self.object
            let newViewModels = self.dataSource?.viewModels(for: object as Any)
            let filterVM = objectsWithDuplicateIdentifiersRemoved(newViewModels) ?? []
            let boxs = filterVM.map({DiffBox(value: $0)})
            let oldViewModels = viewModels.map({DiffBox(value: $0)})
            let stageChanged = StagedChangeset(source: oldViewModels, target: boxs, section: 0)
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                performUpdate(stageChanged: stageChanged, animated: animated, shouldUpdateCell: shouldUpdateCell, completion: completion)
            }
        }
    }
    
    private func performUpdate(stageChanged: StagedChangeset<[DiffBox<ListDiffable>]>, animated: Bool, shouldUpdateCell: Bool, completion: ((Bool) -> Void)? = nil) {
        for stage in stageChanged {
            self.collectionContext?.performBatch(animated: animated, updates: { [weak self] (batchContext) in
                guard let self = self else {return}
                
                guard !stageChanged.isEmpty else {return}
                
                let changeData = stage.data.map({$0.value})
                self.viewModels = changeData
                
                if let ex = self.collectionContext?.experiments, !stage.elementUpdated.isEmpty, ListExperimentEnabled(mask: ex, option: IGListExperiment.invalidateLayoutForUpdates) {
                    batchContext.invalidateLayout(in: self, at: IndexSet(stage.elementUpdated.map({$0.element})))
                }
                
                if !stage.elementUpdated.isEmpty {
                    var indexReloads: [Int] = []
                    for indexPath in stage.elementUpdated {
                        let index = indexPath.element
                        if shouldUpdateCell {
                            let value = changeData[indexPath.element]
                            if let cell = self.context.nodeForItem(at: index, section: self) {
                                let node = cell as? ListBindable
                                node?.bindViewModel(value)
                            } else {
                                indexReloads.append(indexPath.element)
                            }
                        } else {
                            indexReloads.append(indexPath.element)
                        }
                    }
                    if !indexReloads.isEmpty {
                        batchContext.reload(in: self, at: IndexSet(indexReloads))
                    }
                }
                
                if !stage.elementDeleted.isEmpty {
                    batchContext.delete(in: self, at: IndexSet(stage.elementDeleted.map({$0.element})))
                }

                if !stage.elementInserted.isEmpty {
                    batchContext.insert(in: self, at: IndexSet(stage.elementInserted.map({$0.element})))
                }
                
                if !stage.elementMoved.isEmpty {
                    for move in stage.elementMoved {
                        batchContext.move(in: self, from: move.source.element, to: move.target.element)
                    }
                }
//                self.state = .applied
            }, completion: { [weak self] (finished) in
                completion?(finished)
//                self?.state = .idle
//                if let wait = self?.lastWaitForUpdate {
//                    self?.lastWaitForUpdate = nil
//                    self?.updateAnimated(animated: wait.animated, shouldUpdateCell: wait.shouldUpdateCell, completion: wait.completion)
//                }
            })
        }
    }
    
    deinit {
        datasourceProxy = nil
    }
}

open class COCellNode<M: ListDiffable>: ASCellNode, ListBindable {
    public var viewModel: M!
    
    open func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? M else {return}
        self.viewModel = vm
        binding(vm)
    }
    
    public override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        neverShowPlaceholders = true
    }
    
    open func binding(_ viewModel: M) {}
}

open class SCellNode<M: ListSwiftable>: ASCellNode, ListBindable {
    public var viewModel: M!
    
    public func bindViewModel(_ viewModel: Any) {
        var vm: M!
        if let castVM = viewModel as? M {
            vm = castVM
        } else if let box = viewModel as? ListDiffableBox {
            vm = box.value as! M
        }
        self.viewModel = vm
        binding(vm)
    }
    
    public override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        neverShowPlaceholders = true
    }
    
    open func binding(_ viewModel: M) {}
}

func objectsWithDuplicateIdentifiersRemoved(_ objects: [ListDiffable]?) -> [ListDiffable]? {
    guard let objects = objects else {return nil}
    var mapObjects: [NSObject: ListDiffable] = [:]
    var uniqueObjects: [ListDiffable] = []
    for object in objects {
        let diffIdentifier = object.diffIdentifier() as? NSObject
        
        var previousObject: ListDiffable?
        if let id = diffIdentifier {
            previousObject = mapObjects[id]
        }
        
        if diffIdentifier != nil
            && previousObject == nil {
            mapObjects[diffIdentifier!] = object
            uniqueObjects.append(object)
        } else {
            print("Duplicate identifier %@ for object %@ with object %@", diffIdentifier, object, previousObject);
        }
    }
    return uniqueObjects;
}


struct DiffBox<T: ListDiffable>: Differentiable {
    let value: T
    
    init(value: T) {
        self.value = value
    }
    
    typealias DifferenceIdentifier = String
    var differenceIdentifier: String {
        return "\(value.diffIdentifier())"
    }
    
    func isContentEqual(to source: DiffBox<T>) -> Bool {
        return source.value.isEqual(toDiffableObject: value)
    }
}
