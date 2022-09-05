//
//  CornerLayout.swift
//  TextureSwiftSupport
//
//  Created by arya.cia on 14/03/22.
//  Copyright © 2022 muukii. All rights reserved.
//

import Foundation

public struct CornerLayout<CornerContent, Content> : _ASLayoutElementType where CornerContent : _ASLayoutElementType, Content : _ASLayoutElementType {
	
	public let content: Content
	public let cornerContent: CornerContent
	public let location: ASCornerLayoutLocation
	public let offset: CGPoint
	
	public init(
		child: Content,
		corner: CornerContent,
		location: ASCornerLayoutLocation,
		offset: CGPoint = .zero
	) {
		self.content = child
		self.cornerContent = corner
		self.location = location
		self.offset = offset
	}
	
	public func tss_make() -> [ASLayoutElement] {
		let stack = ASStackLayoutSpec()
		stack.alignItems = .center
		stack.justifyContent = .center
		
		let corner = cornerContent.tss_make().first ?? ASLayoutSpec()
		stack.children = [corner]
		let cornerLayout = ASCornerLayoutSpec(
			child: content.tss_make().first!,
			   corner: stack,
			   location: self.location
		   )
		cornerLayout.offset = offset
		return [
			cornerLayout
		]
	}
}
