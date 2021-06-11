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
import RxCocoa
import NVActivityIndicatorView

open class ASActivityButtonNode: ASButtonNode {
    public let activity: ASDisplayNode = {
        let ac = ASDisplayNode { () -> UIView in
            let view = NVActivityIndicatorView(frame: .init(x: 0, y: 0, width: 24, height: 24), type: .circleStrokeSpin, padding: 0)
            return view
        }
        
        return ac
    }()
    
    public var activityView: NVActivityIndicatorView {
        return activity.view as! NVActivityIndicatorView
    }
    
    public var isLoading = false
    
    open func startLoading() {
        guard !isLoading else {return}
        isLoading = true
        titleNode.alpha = 0
        imageNode.alpha = 0
        activityView.startAnimating()
        self.setNeedsLayout()
    }
    
    open func stopLoading() {
        guard isLoading else {return}
        isLoading = false
        titleNode.alpha = 1
        imageNode.alpha = 1
        activityView.stopAnimating()
        self.setNeedsLayout()
    }
    
    public func setAnimationType(_ type: NVActivityIndicatorType) {
        activityView.type = type
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = super.layoutSpecThatFits(constrainedSize)
        return LayoutSpec {
            if isLoading {
                stack.overlay({
                    HStackLayout(justifyContent: .center, alignItems: .center) {
                        activity.preferredSize(.init(width: 24, height: 24))
                    }
                }())
            } else {
                stack
            }
        }
    }
}

public extension Reactive where Base: ASActivityButtonNode {
    func subscribe(_ value: BehaviorRelay<Bool>) -> Disposable {
        return value.subscribe(onNext: { [weak base](loading) in
            loading ? base?.startLoading() : base?.stopLoading()
        })
    }
}
