//
//  ASCornerNode.swift
//  Alamofire
//
//  Created by khoa on 21/02/2021.
//

import Foundation
import UIKit
import AsyncDisplayKit

open class ASCornerNode: ASDisplayNode {
    private var corners: UIRectCorner = .init()
    private var radius: CGFloat = 0
    
    public override func nodeDidLayout() {
        super.nodeDidLayout()
        refreshCorners()
    }
    
    public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        self.corners = corners
        self.radius = radius
        self.refreshCorners()
    }
    
    private func refreshCorners() {
        if #available(iOS 11, *) {
            var cornerMask = CACornerMask()
            if(corners.contains(.bottomLeft)){
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if(corners.contains(.bottomRight)){
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            if(corners.contains(.topLeft)){
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if(corners.contains(.topRight)){
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask
        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}

