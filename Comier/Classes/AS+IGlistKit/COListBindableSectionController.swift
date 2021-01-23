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

public protocol ASListBindingDataSource: class {
    func viewModels(for object: Any) -> [ListDiffable]
    func nodeBlockForViewModel(at viewModel: ListDiffable) -> ASCellNode
}

public protocol ASListBindingDelegate: class {
    func didSelected(at viewModel: ListDiffable)
}

extension ASListBindingDelegate {
    func didSelected(at viewModel: ListDiffable) {}
}

enum SectionState {
    case idle
    case queued
    case applied
}

open class ASListBindingSectionController<Element: ListDiffable>: COSectionController {
    private var viewModels: [ListDiffable] = []
    var object: Element? = nil
    var state: SectionState = .idle
    
    public weak var dataSource: ASListBindingDataSource? = nil
    public weak var delegate: ASListBindingDelegate? = nil
    
    public override func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let block: ASCellNodeBlock = { [weak self] in
            guard let self = self else {return COCellNode<ListDiffable>()}
            let cell = self.dataSource?.nodeBlockForViewModel(at: self.viewModels[index])
            if let cell = cell as? ListBindable {
                cell.bindViewModel(self.viewModels[index])
            }
            
            if let cell = cell as? COCellNode<ListDiffable> {
                cell.collectionContext = self.collectionContext
            }
            return cell ?? COCellNode<ListDiffable>()
        }
        return block
    }
    
    public override func numberOfItems() -> Int {
        return viewModels.count
    }
    
    public override func didUpdate(to object: Any) {
        let oldObject = self.object
        self.object = object as? Element
        
        if oldObject == nil {
            let viewModels = self.dataSource?.viewModels(for: object)
            self.viewModels = objectsWithDuplicateIdentifiersRemoved(viewModels) ?? []
        } else {
            self.updateAnimated(animated: true)
        }
    }
    
    public override func didSelectItem(at index: Int) {
        delegate?.didSelected(at: viewModels[index])
    }
    
    public override func sizeForItem(at index: Int) -> CGSize {
        let size = ASIGListSectionControllerMethods.sizeForItem(at: index)
        return size
    }
    
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }
    
    func updateAnimated(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if self.state != .idle {
            completion?(false)
            return
        }
        self.state = .queued
        
        var result: ListIndexSetResult? = nil
        var oldViewModels: [ListDiffable] = []
        
        let collectionContext = self.collectionContext;
        self.collectionContext?.performBatch(animated: animated, updates: { [weak self] (batchContext) in
            guard let self = self, self.state == .queued else {return}
            oldViewModels = self.viewModels
            let object = self.object
            assert(object != nil, "Expected IGListBindingSectionController object to be non-nil before updating.")
            let newViewModels = self.dataSource?.viewModels(for: object)
            let filterVM = objectsWithDuplicateIdentifiersRemoved(newViewModels) ?? []
            self.viewModels = filterVM
            result = ListDiff(oldArray: oldViewModels, newArray: filterVM, option: .equality)
            
            if let updates = result?.updates {
                for item in updates.enumerated() {
                    print(item)
                    let (offset, index) = item
                    let id = oldViewModels[index].diffIdentifier()
                    let indexAfterUpdate = result?.newIndex(forIdentifier: id)
                    if let indexAfterUpdate = indexAfterUpdate {
                        let cell = collectionContext?.cellForItem(at: index, sectionController: self) as? _ASCollectionViewCell
                        let node = cell?.node as? ListBindable
                        node?.bindViewModel(self.viewModels[indexAfterUpdate])
                    }
                }
            }
            
            if let ex = self.collectionContext?.experiments, let updates = result?.updates, ListExperimentEnabled(mask: ex, option: IGListExperiment.invalidateLayoutForUpdates) {
                batchContext.invalidateLayout(in: self, at: updates)
            }
            if let deletes = result?.deletes {
                batchContext.delete(in: self, at: deletes)
            }
            
            if let inserts = result?.inserts {
                batchContext.insert(in: self, at: inserts)
            }
            if let moves = result?.moves {
                for move in moves {
                    batchContext.move(in: self, from: move.from, to: move.to)
                }
            }
            
            self.state = .applied
        }, completion: { (finished) in
            self.state = .idle
            completion?(true)
        })
    }
}

open class COCellNode<M: ListDiffable>: ASCellNode, ListBindable {
    
    public weak var collectionContext: ListCollectionContext? = nil
    
    public var viewModel: M!
    
    public func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? M else {return}
        self.viewModel = vm
        binding(vm)
    }
    
    public override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
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
