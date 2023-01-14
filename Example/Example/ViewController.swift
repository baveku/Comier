//
//  ViewController.swift
//  Texturegroup
//
//  Created by Bách VQ on 12/01/2023.
//

import UIKit
import Comier
import DifferenceKit

class ViewController: UIViewController, ASSectionControllerDataSource {
    func sectionController(by model: Any) -> AXSectionController {
        return NoteSectionController()
    }
    var section: [MainSection] = [.main("Hellau")]
    
    let collectionNode = ASSectionCollectionNode(layout: UICollectionViewFlowLayout())
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        collectionNode.frame = view.bounds
        view.addSubview(collectionNode.view)
        collectionNode.setRefreshControl(refreshControl)
        collectionNode.dataSource = self
        collectionNode.performUpdates([MainSection.main("Hello")])
    }
    
    @objc func refreshAction(_ control: UIRefreshControl) {
        let randomStr = ["sss", "abc", "xyz", "123456789"].randomElement() ?? "Hello"
        collectionNode.performUpdates([MainSection.main(randomStr)]) {
            control.endRefreshing()
        }
    }
}

class NoteSectionController: ATListBindableSectionController<MainSection>, ATListBindableDataSource {
    var viewModels: [any Differentiable] = []
    
    func nodeForItem(for model: any Differentiable) -> ASCellNode {
        switch model {
        case is CellModel:
            return DemoCellNode()
        default:
            return ASCellNode()
        }
    }
    
    override init() {
        super.init()
        dataSource = self
    }
    
    func viewModels(by section: any Differentiable) -> [any Differentiable] {
        guard case .main(let str) = section as? SectionModel else {return []}
        return [CellModel(value: str)]
    }
}


enum MainSection {
    case main(String)
}

extension MainSection: Differentiable {
    typealias DifferenceIdentifier = String
    func isContentEqual(to source: MainSection) -> Bool {
        switch (self, source) {
        case (.main(let lhs), .main(let rhs)):
            return lhs == rhs
        }
    }
    
    var differenceIdentifier: String {
        switch self {
        case .main:
            return "MAIN_SECTION"
        }
    }
}

struct CellModel: Differentiable {
    func isContentEqual(to source: CellModel) -> Bool {
        return value == source.value
    }
    
    let value: String
    typealias DifferenceIdentifier = String
    var differenceIdentifier: String {
        return "CELL_MODEL"
    }
}

class DemoCellNode: ATCellNode<CellModel> {
    let textNode = ASTextNode()
    
    override func didUpdate(_ model: CellModel) {
        super.didUpdate(model)
        textNode.attributedText = NSMutableAttributedString(string: model.value).color(.black)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout {
                textNode
            }.height(100).width(100)
        }
    }
}
