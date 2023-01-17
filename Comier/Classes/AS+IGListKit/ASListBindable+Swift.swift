//
//  ASListBindable+Swift.swift
//  Comier
//
//  Created by Bách VQ on 29/11/2022.
//
import Foundation
import IGListKit

public protocol ASSwiftListBindingDataSource: AnyObject {
    func viewModels(for object: Any) -> [ListSwiftable]
    func nodeBlockForViewModel(at viewModel: ListSwiftable) -> ASCellNode
}

class ASListBindingDataSourceProxy: ASListBindingDataSource {
    func viewModels(for object: Any) -> [ListDiffable] {
        let sources = swiftDataSource?.viewModels(for: object) ?? []
        return sources.map({ListDiffableBox(value: $0)})
    }
    
    func nodeBlockForViewModel(at viewModel: ListDiffable) -> ASCellNode {
        switch viewModel {
        case is ListDiffableBox:
            let value = (viewModel as! ListDiffableBox).value
            return swiftDataSource?.nodeBlockForViewModel(at: value) ?? ASCellNode()
        default: return ASCellNode()
        }
    }
    
    weak var swiftDataSource: ASSwiftListBindingDataSource?
    
    init(dataSource: ASSwiftListBindingDataSource) {
        self.swiftDataSource = dataSource
    }
}
