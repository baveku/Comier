//
//  ViewController.swift
//  Comier
//
//  Created by baveku on 12/11/2020.
//  Copyright (c) 2020 baveku. All rights reserved.
//

import UIKit
import Comier
import IGListKit
import AsyncDisplayKit

extension UIScreen {
    static let bounds = main.bounds
    static let width = bounds.size.width
    static let height = bounds.size.height
}

class Lii: ListViewModel<ListDiffable> {}

class ViewController: COListViewController<Lii> {

    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        collectionNode.view.collectionViewLayout = flowLayout
        // Do any additional setup after loading the view, typically from a nib.
        self.viewModel.elements.accept([NumberSectionModel(value: 0)])
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ListNumberSection()
    }
    
    lazy var button: ASButtonNode = {
       let button = ASButtonNode()
        button.setTitle("Reload", with: nil, with: .blue, for: .normal)
        button.addTarget(self, action: #selector(reload), forControlEvents: .touchUpInside)
        return button
    }()
    
    @objc func reload() {
        adapter.reloadData(completion: nil)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.style.flexGrow = 1
        button.style.height = ASDimensionMake(60)
        button.style.width = ASDimensionMake("100%")
        stack.children = [collectionNode, button]
        return stack
    }
}

class ListNumberSection: COListSectionController {
    override init() {
        super.init()
        self.dataSource = self
    }
}

extension ListNumberSection: COListSectionControllerDatasource {
    func viewModels(for object: Any) -> [ListDiffable] {
        return [NumberSectionModel(value: 0), NumberSectionModel(value: 1), NumberSectionModel(value: 2)]
    }
    
    func nodeBlockForViewModel(at viewModel: ListDiffable) -> ASCellNode {
        return NumberCellNode()
    }
}

class NumberSectionModel: ListDiffable {
    let value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return value as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NumberSectionModel else{return false}
        return value == object.value
    }
}

class NumberCellNode: COCellNode<NumberSectionModel> {
    let valueNode = ASTextNode()
    
    override func binding(_ viewModel: NumberSectionModel) {
        valueNode.attributedText = NSAttributedString(string: "\(viewModel.value)")
    }
    
    override func didLoad() {
        super.didLoad()
        self.backgroundColor = .blue
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.children = [valueNode]
        stack.justifyContent = .center
        stack.alignItems = .center
        stack.style.height = ASDimensionMake(80)
        stack.style.width = ASDimensionMake(UIScreen.width)
        return stack
    }
}
