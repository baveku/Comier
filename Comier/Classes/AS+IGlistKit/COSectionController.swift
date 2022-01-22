//
//  COSectionController.swift
//  Comier
//
//  Created by Bách on 12/12/2020.
//

import Foundation
import IGListDiffKit
import IGListKit
import AsyncDisplayKit
import RxSwift

public protocol SectionBindable: SectionViewModelable {
    associatedtype ViewModelType: ViewModel
}

/**
 Binding ViewModel from ViewController to Section Controller
 */
public protocol SectionViewModelable: AnyObject {
    func bindRootViewModel()
	func sectionWillDisplay(_ section: ListSectionController)
	func sectionDidEndDisplaying(_ section: ListSectionController)
	
	func cellNodeWillDisplay(_ section: ListSectionController, cell: ASCellNode, at index: Int)
	func cellNodeDidEndDisplaying(_ section: ListSectionController, cell: ASCellNode, at index: Int)
}

public extension SectionViewModelable {
	func sectionWillDisplay(_ section: ListSectionController) {}
	func sectiondidEndDisplaying(_ section: ListSectionController) {}
	
	func cellNodeWillDisplay(_ section: ListSectionController, cell: ASCellNode, at index: Int) {}
	func cellNodedidEndDisplaying(_ section: ListSectionController, cell: ASCellNode, at index: Int) {}
}


public extension SectionBindable where Self: COSectionController {
    
    /**
     Get ViewModel from ASViewModelViewController
     */
    var rootViewModel: ViewModelType? {
        return (viewController as? ASViewModelController<ViewModelType>)?.viewModel
    }
}

open class COSectionController: ListSectionController, ASSectionController, ListSupplementaryViewSource, ASSupplementaryNodeSource, ListDisplayDelegate {
	var isBinded = false
    public override init() {
        super.init()
		displayDelegate = self
    }
    
    public var context: ListCollectionContext! {
        return self.collectionContext
    }
    
    open func supportedElementKinds() -> [String] {
        return []
    }
    
    public func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        return ASIGListSupplementaryViewSourceMethods.viewForSupplementaryElement(ofKind: elementKind, at: index, sectionController: self)
    }
    
    public func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return ASIGListSupplementaryViewSourceMethods.sizeForSupplementaryView(ofKind: elementKind, at: index)
    }
    
    open func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        return {() in return ASCellNode()}
    }
    
    open func nodeForItem(at index: Int) -> ASCellNode {
        return ASCellNode()
    }
    
    open override func numberOfItems() -> Int {
        return 1
    }
    
    open override func didUpdate(to object: Any) {}
    open override func didSelectItem(at index: Int) {}
    
    //ASDK Replacement
    public override func sizeForItem(at index: Int) -> CGSize {
        return ASIGListSectionControllerMethods.sizeForItem(at: index)
    }
    
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }
    
    open func nodeBlockForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASCellNodeBlock {
        return { ASCellNode()}
    }
    
    open func sizeRangeForSupplementaryElement(ofKind elementKind: String, at index: Int) -> ASSizeRange {
        return ASSizeRangeUnconstrained
    }
    
    public func visibleCellNodes() -> [ASCellNode] {
        return context.visibleCellNodes(for: self) ?? []
    }
    
    public func visibleCellNodes<T: ASCellNode>() -> [T] {
        let nodes = context.visibleCellNodes(for: self)
        return nodes.compactMap({$0 as? T})
    }
    
    public func nodeForItem<T: ASMCellNode>(from index: Int) -> T? {
        return context.nodeForItem(at: index, section: self) as? T
    }
    
    public private(set) var isVisible: Bool = false
	
	public func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
		isVisible = true
		if let self = self as? SectionViewModelable {
			if !isBinded {
				isBinded = true
				self.bindRootViewModel()
			}
			self.sectionWillDisplay(sectionController)
		}
	}
	
	public func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
		isVisible = false
		if let self = self as? SectionViewModelable {
			self.sectionDidEndDisplaying(sectionController)
		}
	}
	
	public func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
		if let self = self as? SectionViewModelable {
			self.cellNodeWillDisplay(sectionController, cell: (cell as! _ASCollectionViewCell).node!, at: index)
		}
	}
	
	public func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
		if let self = self as? SectionViewModelable {
			self.cellNodeDidEndDisplaying(sectionController, cell: (cell as! _ASCollectionViewCell).node!, at: index)
		}
	}
}

public extension ListCollectionContext {
    public func visibleCellNodes(for section: ListSectionController) -> [ASCellNode] {
        let cells = self.visibleCells(for: section)
        let nodes = cells.compactMap({ c in return (c as? _ASCollectionViewCell)?.node})
        return nodes ?? []
    }
    
    public func nodeForItem(at index: Int, section: ListSectionController) -> ASCellNode? {
        return (self.cellForItem(at: index, sectionController: section) as? _ASCollectionViewCell)?.node
    }
}
