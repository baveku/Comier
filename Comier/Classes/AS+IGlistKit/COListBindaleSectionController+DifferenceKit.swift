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
            completion?(false)
            return
        }
        self.state = .queued
		let object = self.object
		let oldViewModels = self.viewModels
		let newViewModels = self.dataSource?.viewModels(for: object)
		let filterVM = objectsWithDuplicateIdentifiersRemoved(newViewModels) ?? []
		
		let oldBoxs = oldViewModels.map({DiffBox(value: $0)})
		let newBoxs = filterVM.map({DiffBox(value: $0)})
		let stagedChangeset = StagedChangeset(source: oldBoxs, target: newBoxs, section: section)
        let collectionContext = collectionContext
        self.collectionContext?.performBatch(animated: animated, updates: { [weak self] (batchContext) in
            guard let self = self, self.state == .queued else {return}
			for changeset in stagedChangeset {
				self.viewModels = changeset.data.map({$0.value})
				
				if !changeset.elementDeleted.isEmpty {
					batchContext.delete(in: self, at: IndexSet(changeset.elementDeleted.map({$0.element})))
				}
				
				if !changeset.elementInserted.isEmpty {
					batchContext.insert(in: self, at: IndexSet(changeset.elementInserted.map({$0.element})))
				}
				
				if !changeset.elementUpdated.isEmpty {
					var indexReloads: [Int] = []
					for index in changeset.elementUpdated.map({$0.element}) {
						if shouldUpdateCell {
							if let cell = collectionContext?.nodeForItem(at: index, section: self) {
								let node = cell as? ListBindable
								node?.bindViewModel(self.viewModels[index])
							} else {
								indexReloads.append(index)
							}
						} else {
							indexReloads.append(index)
						}
					}
					batchContext.reload(in: self, at: IndexSet(indexReloads))
				}
				
				for (source, target) in changeset.elementMoved {
					batchContext.move(in: self, from: source.element, to: target.element)
				}
			}
            
            self.state = .applied
        }, completion: { (finished) in
            self.state = .idle
            completion?(finished)
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
