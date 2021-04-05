//
//  JBDisplayNode.swift
//  Comier
//
//  Created by khoa on 23/02/2021.
//

import Foundation
import AsyncDisplayKit

open class JBDisplayNode: ASDisplayNode {
    @objc open func hotReload() {
        self.setNeedsLayout()
    }
    
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    open override func didLoad() {
        super.didLoad()
        NotificationCenter.default.addObserver(self,
            selector: #selector(hotReload),
            name: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

open class JBControlNode: ASControlNode {
    @objc open func hotReload() {
        self.setNeedsLayout()
    }
    
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    open override func didLoad() {
        super.didLoad()
        NotificationCenter.default.addObserver(self,
            selector: #selector(hotReload),
            name: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
