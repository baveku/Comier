//
//  SafeArea+.swift
//  Alamofire
//
//  Created by Bách on 05/02/2021.
//

import Foundation
import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

public extension _ASLayoutElementType {
    func useSafeAreaInset() -> InsetLayout<Self> {
        return self.padding(UIScreen.safeAreaInsets)
    }
}


public extension UIScreen {
    static var safeAreaInsets: UIEdgeInsets {
        return getScreenSafeArea()
    }
    
    private class func getScreenSafeArea() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return  UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        } else {
            return .zero
        }
    }
}

