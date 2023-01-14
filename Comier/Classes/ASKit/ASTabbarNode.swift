//
//  ASTabbar.swift
//  Alamofire
//
//  Created by khoa on 21/02/2021.
//

import Foundation
import AsyncDisplayKit

open class ASTabItem: ASControlNode {
    public let iconNode: ASImageNode = {
        let node = ASImageNode()
        return node
    }()
    
    public let titleNode: ASTextNode = {
        let node = ASTextNode()
        node.textColorFollowsTintColor = true
        return node
    }()
    
    private var mutableAttributeStr = NSMutableAttributedString()
    private var font = UIFont()
    
    public init(title: String, icon: UIImage?) {
        super.init()
        automaticallyManagesSubnodes = true
        self.mutableAttributeStr = NSMutableAttributedString(string: title).alignment(.center)
        titleNode.attributedText = mutableAttributeStr
        iconNode.image = icon
        setSelected(false)
    }
    
    public var selectedTabColor: UIColor = .gray
    public var deselectedTabColor: UIColor = .black
    
    public func setColor(normal: UIColor, selected: UIColor) {
        self.selectedTabColor = selected
        self.deselectedTabColor = normal
    }
    
    public func setFont(_ font: UIFont) {
        self.font = font
        titleNode.attributedText = mutableAttributeStr.font(font)
    }
    
    public func setSelected(_ selected: Bool) {
        let color: UIColor = selected ? selectedTabColor : deselectedTabColor
        iconNode.tintColor = color
        titleNode.tintColor = color
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout(justifyContent: .center, alignItems: .stretch) {
                CenterLayout {
                    iconNode.preferredSize(.init(width: 24, height: 24))
                }
                titleNode
            }.flexGrow(1)
        }
    }
}

public protocol ASTabbarDelegate: AnyObject {
    func tabbar(_ tab: ASTabbarNode, didSelectTab atIndex: Int, willReload flag: Bool)
}

open class ASTabbarNode: JBDisplayNode {
    
    weak var delegate: ASTabbarDelegate? = nil
    
    let tabItems: [ASTabItem]
    public init(items: [ASTabItem]) {
        tabItems = items
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    public override func didLoad() {
        super.didLoad()
        tabItems.forEach {$0.addTarget(self, action: #selector(didTab), forControlEvents: .touchUpInside)}
        setSelectedTab(at: 0)
    }
    
    public var selectedIndex: Int = 0
    
    @objc private func didTab(_ tab: ASTabItem) {
        guard let index = tabItems.firstIndex(of: tab) else {return}
        setSelectedTab(at: index)
    }
    
    public func setSelectedTab(at index: Int) {
        tabItems.enumerated().forEach {$0.element.setSelected($0.offset == index)}
        let snapshotSelectedIndex = selectedIndex
        if selectedIndex != index {
            self.selectedIndex = index
            self.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
        }
        delegate?.tabbar(self, didSelectTab: index, willReload: snapshotSelectedIndex == index)
    }
    
    public let indicator: ASCornerNode = {
        let node = ASCornerNode()
        node.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 4)
        return node
    }()
    
    public let divider: ASDisplayNode = {
        let node = ASDisplayNode()
        return node
    }()
    
    public func setColor(normal: UIColor, selected: UIColor) {
        tabItems.forEach { (item) in
            item.setColor(normal: normal, selected: selected)
        }
        indicator.backgroundColor = selected
    }
    
    public func setFont(_ font: UIFont) {
        tabItems.forEach { (item) in
            item.setFont(font)
        }
    }
    
    public override func animateLayoutTransition(_ context: ASContextTransitioning) {
        let finalFrame = context.finalFrame(for: indicator)
        UIView.animate(withDuration: 0.1) {
            self.indicator.frame = finalFrame
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout(alignItems: .stretch) {
                divider.height(1)
                HStackLayout {
                    tabItems.enumerated().map { (er) -> AnyLayout in
                        return AnyLayout(VStackLayout(alignItems: .stretch) {
                            if er.offset == selectedIndex {
                                indicator.height(2).padding(.init(top: 0, left: 16, bottom: 0, right: 16))
                            } else {
                                VStackLayout{}.height(2)
                            }
                            er.element.flexGrow(1)
                        }.flexGrow(1))
                    }.map({$0.flexBasis(fraction: CGFloat(1/tabItems.count))})
                }.flexGrow(1)
            }.flexGrow(1)
        }
    }
}
