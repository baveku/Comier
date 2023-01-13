//
//  File.swift
//  
//
//  Created by Bách VQ on 13/01/2023.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit

protocol SectionDataSource: AnyObject {
    var numberOfItem: Int {get}
    func nodeBlockForItem(for model: Differentiable)
    func nodeItemDidUpdate(old: Differentiable, new: Differentiable)
}

protocol SectionDelegate: AnyObject {
    func didSelectItem(at indexPath: IndexPath)
}

protocol SectionSupplementalySource: AnyObject {
    
}

class SectionController<T: Differentiable>: AnyObject {
    weak var delegate: SectionDelegate?
    weak var dataSource: SectionDataSource?
    weak var collectionNode: ASSectionCollectionNode?
    
    func didUpdate(section: T) {}
}

class ASSectionCollectionNode: ASDisplayNode {
    private let collectionNode: ASCollectionNode
    private var models: [DifferentiableSection]
    init(layout: UICollectionViewLayout) {
        collectionNode = .init(collectionViewLayout: layout)
        super.init()
        
    }
    
    func performUpdates(_ section: [DifferentiableSection]) {
        let stage = StagedChangeset(source: section.map({ArraySection(model: $0, elements: $0.elements)}), target: models.map({ArraySection(model: $0, elements: $0.elements)}))

    }

    func _onUpdateCell(cell: ASMCellNode, indexPath: IndexPath) {
        let section = collectionNode
    }
}

extension ASSectionCollectionNode: ASCollectionDataSource, ASCollectionDelegate {
    
}
