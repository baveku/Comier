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
    func nodeBlockForViewModel(at viewModel: ListDiffable) -> ASCellNodeBlock
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
        return dataSource?.nodeBlockForViewModel(at: _innerViewModels[index]) ?? { COCellNode<ListDiffable>()}
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
}

open class COCellNode<M: ListDiffable>: ASCellNode, ListBindable {
    public func bindViewModel(_ viewModel: Any) {
        guard let vm = viewModel as? M else {return}
        binding(vm)
    }
    
    open func binding(_ viewModel: M) {}
}
