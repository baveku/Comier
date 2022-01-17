//
//  ASTabbarController.swift
//  Alamofire
//
//  Created by khoa on 21/02/2021.
//

import Foundation
import AsyncDisplayKit

public protocol ASTabbarChildVCDelegate {
    func tabbar(_ tabVC: ASTabbarViewController, didSelect vc: UIViewController, canReload: Bool)
}

open class ASTabbarViewController: BaseASViewController, ASTabbarDelegate {
    public var tabItems: [ASTabItem] = []
    
    public var tabbarNode: ASTabbarNode
    public var viewControllers: [UIViewController]
    let tabbarControllerNode: ASDisplayNode
    public let tabbarController: ASTabBarController
    
    public init(items: [ASTabItem], viewControllers: [UIViewController]) {
        self.tabbarNode = ASTabbarNode(items: items)
        self.viewControllers = viewControllers
        let tabbarController: ASTabBarController = .init()
        self.tabbarController = tabbarController
        self.tabbarController.setViewControllers(viewControllers, animated: false)
        self.tabbarController.tabBar.isHidden = true
        self.tabbarControllerNode = .init(viewBlock: {
            tabbarController.view
        })
        super.init()
        self.tabItems = items
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tabbarNode.delegate = self
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout(alignItems: .stretch) {
                tabbarControllerNode.flexGrow(1)
                tabbarNode.height(48).padding(.bottom, UIScreen.safeAreaInsets.bottom)
            }
        }
    }
    
    open func tabbar(_ tab: ASTabbarNode, didSelectTab atIndex: Int, willReload flag: Bool) {
        tabbarController.selectedIndex = atIndex
        let vc = viewControllers[atIndex]
        if let delegate = vc as? ASTabbarChildVCDelegate {
            delegate.tabbar(self, didSelect: vc, canReload: flag)
        }
    }
}
