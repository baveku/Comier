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

class RootViewController: ListViewController<Lii> {
    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        collectionNode.view.collectionViewLayout = flowLayout
        // Do any additional setup after loading the view, typically from a nib.
		self.viewModel.elements.accept([NumberSectionModel(value: 0, string: "Demo")])
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
		self.viewModel.elements.accept([NumberSectionModel(value: 0, string: "Demo")])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout {
                collectionNode.flexGrow(1)
            }.useSafeAreaInset()
        }
    }
}

class ListNumberSection: ASListBindingSectionController<NumberSectionModel> {
    override init() {
        super.init()
        self.dataSource = self
    }
}

extension ListNumberSection: ASListBindingDataSource {
	func viewModels(for object: Any) -> [ListDiffable] {
		guard let object = object as? NumberSectionModel else {return []}
		let item = [NumberSectionModel(value: 0, string: object.string), NumberSectionModel(value: 1, string: object.string), NumberSectionModel(value: 2, string: object.string)]
		return item.shuffled()
	}
    
    func nodeBlockForViewModel(at viewModel: ListDiffable) -> ASCellNode {
        return NumberCellNode()
    }
}

class NumberSectionModel: ListDiffable {
    let value: Int
	let string: String
    
	init(value: Int, string: String) {
        self.value = value
		self.string = string
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return value as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NumberSectionModel else{return false}
		return value == object.value && string == object.string
    }
}

class NumberCellNode: COCellNode<NumberSectionModel> {
    let valueNode = ASTextNode()
    
    override func binding(_ viewModel: NumberSectionModel) {
        valueNode.attributedText = NSMutableAttributedString(string: "1232133").alignment(.center).color(.black).font(UIFont.systemFont(ofSize: 14)).lineBreak(.byCharWrapping).lineSpacing(1).lineHeight(multiple: 1.3)
    }
    
    override func didLoad() {
        super.didLoad()
        self.backgroundColor = .blue
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            HStackLayout(justifyContent: .center, alignItems: .center) {
                valueNode
            }.height(80).width(UIScreen.width)
        }
    }
}
