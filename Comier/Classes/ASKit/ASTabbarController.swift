//
//  ASTabbarController.swift
//  Alamofire
//
//  Created by khoa on 21/02/2021.
//

import Foundation
import AsyncDisplayKit

public protocol ASTabbarChildVCDelegate {
    func tabbar(_ tabVC: ASTabbarViewController, doubleTap vc: UIViewController)
    func tabbar(_ tabVC: ASTabbarViewController, didSelect vc: UIViewController)
}

open class ASTabbarViewController: BaseASViewController, ASPagerDelegate, ASPagerDataSource, ASTabbarDelegate {
    public var tabItems: [ASTabItem] = []
    
    public var tabbarNode: ASTabbarNode
    public var viewControllers: [UIViewController]
    let pageNode = ASPagerNode()
    
    public init(items: [ASTabItem], viewControllers: [UIViewController]) {
        self.tabbarNode = ASTabbarNode(items: items)
        self.viewControllers = viewControllers
        super.init()
        self.tabItems = items
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var doubleTaps = [UITapGestureRecognizer]()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        pageNode.showsVerticalScrollIndicator = false
        pageNode.showsHorizontalScrollIndicator = false
        pageNode.setDataSource(self)
        pageNode.setDelegate(self)
        pageNode.view.isScrollEnabled = false
        tabbarNode.delegate = self
        tabItems.forEach { (item) in
            let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapTabbarItemAction(_:)))
            tap.numberOfTapsRequired = 2
            tap.isEnabled = false
            doubleTaps.append(tap)
            item.view.addGestureRecognizer(tap)
        }
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout(alignItems: .stretch) {
                pageNode.flexGrow(1)
                tabbarNode.height(48).padding(.bottom, UIScreen.safeAreaInsets.bottom)
            }
        }
    }
    
    // MARK: - Page Delegate Datasources
    open func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return tabbarNode.tabItems.count
    }
    
    open func pagerNode(_ pagerNode: ASPagerNode, nodeBlockAt index: Int) -> ASCellNodeBlock {
        let block = { () -> ASCellNode in
            let node = ASCellNode { [weak self] () -> UIViewController in
                guard let self = self else {return UIViewController()}
                return self.viewControllers[index]
            } didLoad: { (node) in}
            return node
        }
        return block
    }
    
    open func tabbar(_ tab: ASTabbarNode, didSelectTab atIndex: Int, willReload flag: Bool) {
        pageNode.scrollToPage(at: atIndex, animated: false)
        let vc = viewControllers[atIndex]
        doubleTaps.enumerated().forEach { (ind, tap) in
            tap.isEnabled = ind == atIndex
        }
        
        if let delegate = vc as? ASTabbarChildVCDelegate {
            delegate.tabbar(self, didSelect: vc)
        }
    }
    
    @objc open func doubleTapTabbarItemAction(_ sender: UITapGestureRecognizer) {
        let vc = getViewController(by: sender)
        if let delegate = vc as? ASTabbarChildVCDelegate {
            delegate.tabbar(self, doubleTap: vc)
        }
    }
    
    func getViewController(by item: UITapGestureRecognizer) -> UIViewController {
        var viewController: UIViewController!
        doubleTaps.enumerated().forEach { (ind, target) in
            if target == item {
                viewController = viewControllers[ind]
            }
        }
        
        return viewController
    }
}
