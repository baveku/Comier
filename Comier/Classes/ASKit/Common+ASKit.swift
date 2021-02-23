//
//  Common+ASKit.swift
//  Comier
//
//  Created by khoa on 23/02/2021.
//

import Foundation
import AsyncDisplayKit
import UIKit

open class BSButtonNode: ASButtonNode {
    public let activity: ASDisplayNode = {
        let ac = ASDisplayNode { () -> UIView in
            return UIActivityIndicatorView(style: .white)
        }
        
        return ac
    }()
    
    public var activityView: UIActivityIndicatorView {
        return activity.view as! UIActivityIndicatorView
    }
    
    public var isLoading = false
    
    open func startLoading() {
        guard !isLoading else {return}
        isLoading = true
        titleNode.alpha = 0
        activityView.startAnimating()
        self.setNeedsLayout()
    }
    
    open func stopLoading() {
        guard isLoading else {return}
        isLoading = false
        titleNode.alpha = 1
        activityView.stopAnimating()
        self.setNeedsLayout()
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = super.layoutSpecThatFits(constrainedSize)
        return LayoutSpec {
            if isLoading {
                stack.overlay({
                    HStackLayout(justifyContent: .center, alignItems: .center) {
                        activity
                    }
                }())
            } else {
                stack
            }
        }
    }
}
