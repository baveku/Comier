//
//  ASImageNode+SVG.swift
//  Comier
//
//  Created by Bách VQ on 03/12/2021.
//

import Foundation
import SVGKit
import AsyncDisplayKit

public extension ASImageNode {
    func setImage(svgNamed: String) {
        let svgImage = SVGKImage(named: svgNamed)
        self.image = svgImage?.uiImage
    }
}
