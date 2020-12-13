//
//  COListBindableSectionController.swift
//  Comier
//
//  Created by Bách on 12/12/2020.
//

import Foundation
import IGListKit
import AsyncDisplayKit

public protocol COListSectionControllerDatasource: class {
    func viewModels(for object: Any) -> [ListDiffable]
    func nodeBlockForViewModel(at viewModel: ListDiffable) -> ASCellNode
}

public protocol COListSectionControllerDelegate: class {
    func didSelected(at viewModel: ListDiffable)
}

extension COListSectionControllerDelegate {
    func didSelected(at viewModel: ListDiffable) {}
}


open class COListSectionController: COSectionController {
    private var _innerViewModels: [ListDiffable] = []
    
    public weak var dataSource: COListSectionControllerDatasource? = nil
    public weak var delegate: COListSectionControllerDelegate? = nil
    
    public override func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let block: ASCellNodeBlock = { [weak self] in
            guard let self = self else {return COCellNode<ListDiffable>()}
            let cell = self.dataSource?.nodeBlockForViewModel(at: self._innerViewModels[index])
            if let cell = cell as? ListBindable {
                cell.bindViewModel(self._innerViewModels[index])
            }
            
            if let cell = cell as? COCellNode<ListDiffable> {
                cell.collectionContext = self.collectionContext
            }
            return cell ?? COCellNode<ListDiffable>()
        }
        return block
    }
    
    public override func numberOfItems() -> Int {
        return _innerViewModels.count
    }
    
    public override func didUpdate(to object: Any) {
        self._innerViewModels = dataSource?.viewModels(for: object) ?? []
    }
    public override func didSelectItem(at index: Int) {
        delegate?.didSelected(at: _innerViewModels[index])
    }
    
    public override func sizeForItem(at index: Int) -> CGSize {
        let size = ASIGListSectionControllerMethods.sizeForItem(at: index)
        print(size)
        return size
    }
    
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        return ASIGListSectionControllerMethods.cellForItem(at: index, sectionController: self)
    }
}

open class COCellNode<M: ListDiffable>: ASCellNode, ListBindable {
    
    public weak var collectionContext: ListCollectionContext? = nil
    
    public func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? M else {return}
        binding(vm)
    }
    
    public override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
    }
    
    open func binding(_ viewModel: M) {}
}
