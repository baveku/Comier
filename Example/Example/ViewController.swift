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
        return .init()
    }
    var section: [MainSection] = [.main("Hellau")]
    let node = ASDisplayNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let collectionNode = ASSectionCollectionNode(layout: UICollectionViewFlowLayout())
        collectionNode.frame = view.bounds
        view.addSubview(collectionNode.view)
        collectionNode.dataSource = self
    }
}

class NoteSectionController: ATSectionController<MainSection> {
    
    override func didUpdate(value: MainSection) {
        if case .main(let string) = value {
            let cell = refCellNode(by: 0) as? DemoCellNode
            
        }
    }
    
    override func numberOfItem() -> Int {
        return 1
    }
    
    override func nodeBlockForItemAt(at index: Int) -> ASCellNodeBlock {
        return {
            DemoCellNode()
        }
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

class DemoCellNode: ASMCellNode {
    let textNode = ASTextNode()
}
