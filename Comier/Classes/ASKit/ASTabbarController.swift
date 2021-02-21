//
//  ASTabbarController.swift
//  Alamofire
//
//  Created by khoa on 21/02/2021.
//

import Foundation
import AsyncDisplayKit

open class ASTabbarViewController: BaseASViewController, ASPagerDelegate, ASPagerDataSource, ASTabbarDelegate {
    public var tabItems: [ASTabItem] = []
    
    public var tabbarNode: ASTabbarNode
    public var viewControllers: [UIViewController]
    let pageNode = ASPagerNode()
    
    init(items: [ASTabItem], viewControllers: [UIViewController]) {
        self.tabbarNode = ASTabbarNode(items: items)
        self.viewControllers = viewControllers
        super.init()
        self.tabItems = items
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        pageNode.showsVerticalScrollIndicator = false
        pageNode.showsHorizontalScrollIndicator = false
        pageNode.setDataSource(self)
        pageNode.setDelegate(self)
        pageNode.view.isScrollEnabled = false
        tabbarNode.delegate = self
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout(alignItems: .stretch) {
                pageNode.flexGrow(1)
                tabbarNode.height(48).padding(.bottom, UIScreen.safeAreaInsets.bottom)
            }
        }
    }
    
    // MARK: - Page Delegate Datasources
    public func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return tabbarNode.tabItems.count
    }
    
    public func pagerNode(_ pagerNode: ASPagerNode, nodeBlockAt index: Int) -> ASCellNodeBlock {
        let block = { () -> ASCellNode in
            let node = ASCellNode { () -> UIViewController in
                return self.viewControllers[index]
            } didLoad: { (node) in}
            return node
        }
        return block
    }
    
    public func tabbar(_ tab: ASTabbarNode, didSelectTab atIndex: Int, willReload flag: Bool) {
        pageNode.scrollToPage(at: atIndex, animated: false)
    }
}
