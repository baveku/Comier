//
//  Common+ASKit.swift
//  Comier
//
//  Created by khoa on 23/02/2021.
//

import Foundation
import AsyncDisplayKit
import UIKit
import RxSwift
import NVActivityIndicatorView

extension ASSizeRange {
    public init(fixedWidth: CGFloat) {
        self.init(width: fixedWidth, height: 0...CGFloat.greatestFiniteMagnitude)
    }
    
    public init(fixedHeight: CGFloat) {
        self.init(width: 0...CGFloat.greatestFiniteMagnitude, height: fixedHeight)
    }
}

open class ASActivityButtonNode: ASButtonNode {
    public let activity: ASDisplayNode = {
        let ac = ASDisplayNode { () -> UIView in
            let view = NVActivityIndicatorView(frame: .init(x: 0, y: 0, width: 24, height: 24), type: .circleStrokeSpin, padding: 0)
            return view
        }
        ac.isHidden = true
        return ac
    }()
    
    public var activityView: NVActivityIndicatorView {
        return activity.view as! NVActivityIndicatorView
    }
    
    public var isLoading = false
    
    open override func setTitle(_ title: String, with font: UIFont?, with color: UIColor?, for state: UIControl.State) {
        if let color {
            ASPerformBlockOnMainThread {
                self.activityView.color = color
            }
        }
        super.setTitle(title, with: font, with: color, for: state)
    }
    
    open func startLoading() {
        guard !isLoading else {return}
        isLoading = true
        titleNode.alpha = 0
        imageNode.alpha = 0
        activity.isHidden = false
        activityView.startAnimating()
    }
    
    open func stopLoading() {
        guard isLoading else {return}
        isLoading = false
        titleNode.alpha = 1
        imageNode.alpha = 1
        activityView.stopAnimating()
        activity.isHidden = true
    }
    
    public func setAnimationType(_ type: NVActivityIndicatorType) {
        activityView.type = type
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return LayoutSpec {
            super.layoutSpecThatFits(constrainedSize).overlay({
                HStackLayout(justifyContent: .center, alignItems: .center) {
                    activity.preferredSize(.init(width: 24, height: 24))
                }
            }())
        }
    }
}

public extension Reactive where Base: ASActivityButtonNode {
    var isLoading: ASBinder<Bool> {
        return ASBinder(self.base) { node, loading in
            loading ? node.startLoading() : node.stopLoading()
        }
    }
}

public func calculateNodeHeight(target: ASDisplayNode, width: CGFloat, insets: UIEdgeInsets = .zero) -> CGSize {
    return ASFakeNode(node: target, insets: insets, width: width).childrenSize
}

class ASFakeNode: ASScrollNode {
    private weak var wrapNode: ASDisplayNode?
    private let sizeWraper = ASDisplayNode()
    private let insets: UIEdgeInsets
    
    init(node: ASDisplayNode, insets: UIEdgeInsets, width: CGFloat) {
        self.wrapNode = node
        self.insets = insets
        super.init()
        automaticallyManagesSubnodes = true
        automaticallyManagesContentSize = true
        view.frame = .init(origin: .zero, size: .init(width: width, height: 1))
        view.layoutIfNeeded()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout {
                VStackLayout {
                    VStackLayout {
                        wrapNode
                    }.padding(insets).background(sizeWraper)
                }
            }
        }
    }
    
    var childrenSize: CGSize {
        return sizeWraper.frame.size
    }
}
