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
    public var viewModels: [ListDiffable] = []
    public var object: Element? = nil
    var state: SectionState = .idle
    
    var lastWaitForUpdate: (animated: Bool, shouldUpdateCell: Bool, completion: ((Bool) -> Void)?)? = nil
    
    public weak var dataSource: ASListBindingDataSource? = nil
    public weak var delegate: ASListBindingDelegate? = nil
    
    public override func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let block: ASCellNodeBlock = { [weak self] in
            guard let self = self else {return COCellNode<ListDiffable>()}
            let cell = self.dataSource?.nodeBlockForViewModel(at: self.viewModels[index])
            cell?.neverShowPlaceholders = true
            if let cell = cell as? ListBindable {
                cell.bindViewModel(self.viewModels[index])
            }
            return cell ?? COCellNode<ListDiffable>()
        }
        return block
    }
    
    public override init() {
        super.init()
    }
    
    public override func numberOfItems() -> Int {
        return viewModels.count
    }
    
    open var willUpdateWithAnimation = true
    
    open override func didUpdate(to object: Any) {
        let oldObject = self.object
        self.object = object as? Element
        
        if oldObject == nil {
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
        self.state = .queued
        let copyViewModels = viewModels
        let object = self.object
        var result: ListIndexSetResult? = nil

        self.collectionContext?.performBatch(animated: animated, updates: { [weak self] (batchContext) in
            guard let self = self, self.state == .queued else {return}
            let oldViewModels = copyViewModels
            let newViewModels = self.dataSource?.viewModels(for: object)
            let filterVM = objectsWithDuplicateIdentifiersRemoved(newViewModels) ?? []
            result = ListDiff(oldArray: oldViewModels, newArray: filterVM, option: .equality)
            self.viewModels = filterVM
            if let updates = result?.updates {
                var indexReloads: [Int] = []
                for oldIndex in updates {
                    if shouldUpdateCell {
                        let id = oldViewModels[oldIndex].diffIdentifier()
                        let indexAfterUpdate = result?.newIndex(forIdentifier: id)
                        if let indexAfterUpdate = indexAfterUpdate {
                            if let cell = self.context.nodeForItem(at: oldIndex, section: self) {
                                let node = cell as? ListBindable
                                node?.bindViewModel(filterVM[indexAfterUpdate])
                            } else {
                                indexReloads.append(oldIndex)
                            }
                        }
                    } else {
                        indexReloads.append(oldIndex)
                    }
                }
                batchContext.reload(in: self, at: IndexSet(indexReloads))
            }
            
            if let ex = self.collectionContext?.experiments, let updates = result?.updates, ListExperimentEnabled(mask: ex, option: IGListExperiment.invalidateLayoutForUpdates) {
                batchContext.invalidateLayout(in: self, at: updates)
            }
            
            if let inserts = result?.inserts {
                batchContext.insert(in: self, at: inserts)
            }
            
            if let deletes = result?.deletes {
                batchContext.delete(in: self, at: deletes)
            }
            
            if let moves = result?.moves {
                for move in moves {
                    batchContext.move(in: self, from: move.from, to: move.to)
                }
            }
            
            self.state = .applied
        }, completion: { [weak self] (finished) in
            self?.state = .idle
            completion?(finished)
            if finished, let self = self {
                if let wait = self.lastWaitForUpdate {
                    self.lastWaitForUpdate = nil
                    self.updateAnimated(animated: wait.animated, shouldUpdateCell: wait.shouldUpdateCell, completion: wait.completion)
                }
            }
        })
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


// OLD DIFF
//public func updateAnimated(animated: Bool, shouldUpdateCell: Bool = true, completion: ((Bool) -> Void)? = nil) {
//    guard self.object != nil else {return}
//    if self.state != .idle {
//        completion?(false)
//        return
//    }
//    self.state = .queued
//
//    var result: ListIndexSetResult? = nil
//    let collectionContext = collectionContext
//    self.collectionContext?.performBatch(animated: animated, updates: { [weak self] (batchContext) in
//        guard let self = self, self.state == .queued else {return}
//        let object = self.object
//        let oldViewModels = self.viewModels
//        let newViewModels = self.dataSource?.viewModels(for: object)
//        let filterVM = objectsWithDuplicateIdentifiersRemoved(newViewModels) ?? []
//        result = ListDiff(oldArray: oldViewModels, newArray: filterVM, option: .equality)
//        self.viewModels = filterVM
//        if let updates = result?.updates {
//            var indexReloads: [Int] = []
//            for oldIndex in updates {
//                if shouldUpdateCell {
//                    let id = oldViewModels[oldIndex].diffIdentifier()
//                    let indexAfterUpdate = result?.newIndex(forIdentifier: id)
//                    if let indexAfterUpdate = indexAfterUpdate {
//                        if let cell = collectionContext?.nodeForItem(at: oldIndex, section: self) {
//                            let node = cell as? ListBindable
//                            node?.bindViewModel(filterVM[indexAfterUpdate])
//                        } else {
//                            indexReloads.append(oldIndex)
//                        }
//                    }
//                } else {
//                    indexReloads.append(oldIndex)
//                }
//            }
//            batchContext.reload(in: self, at: IndexSet(indexReloads))
//        }
//
//        if let ex = self.collectionContext?.experiments, let updates = result?.updates, ListExperimentEnabled(mask: ex, option: IGListExperiment.invalidateLayoutForUpdates) {
//            batchContext.invalidateLayout(in: self, at: updates)
//        }
//
//        if let inserts = result?.inserts {
//            batchContext.insert(in: self, at: inserts)
//        }
//
//        if let deletes = result?.deletes {
//            batchContext.delete(in: self, at: deletes)
//        }
//
//        if let moves = result?.moves {
//            for move in moves {
//                batchContext.move(in: self, from: move.from, to: move.to)
//            }
//        }
//
//
//        self.state = .applied
//    }, completion: { (finished) in
//        self.state = .idle
//        completion?(finished)
//    })
//}
