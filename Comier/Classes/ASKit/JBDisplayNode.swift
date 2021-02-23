//
//  JBDisplayNode.swift
//  Comier
//
//  Created by khoa on 23/02/2021.
//

import Foundation
import AsyncDisplayKit

open class JBDisplayNode: ASDisplayNode {
    @objc open func injected() {
        self.setNeedsLayout()
    }
    
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
}
