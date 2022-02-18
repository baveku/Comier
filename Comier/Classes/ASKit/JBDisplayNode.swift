//
//  JBDisplayNode.swift
//  Comier
//
//  Created by khoa on 23/02/2021.
//

import Foundation
import AsyncDisplayKit
import RxSwift

public protocol MultiLangable {
    func didChangedLanguage()
}

open class JBDisplayNode: ASDisplayNode, MultiLangable {
	private let _langBag = DisposeBag()

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
		UIContext.shared.languageCode.skip(1).subscribe(onNext: { [weak self] _ in
			self?.didChangedLanguage()
		}) => _langBag
    }

	open func didChangedLanguage() {}

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

open class JBControlNode: ASControlNode {
	private let _langBag = DisposeBag()
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
		UIContext.shared.languageCode.skip(1).subscribe(onNext: { [weak self] _ in
				self?.didChangedLanguage()
			}) => _langBag
    }

	open func didChangedLanguage() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

open class ASMCellNode: ASCellNode {
	private let _langBag = DisposeBag()
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    open override func didLoad() {
		super.didLoad()
		UIContext.shared.languageCode.skip(1).subscribe(onNext: { [weak self] _ in
			self?.didChangedLanguage()
		}) => _langBag
	}

	open func didChangedLanguage() {}
}

open class ASMNode: ASDisplayNode {
	private let _langBag = DisposeBag()
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
        automaticallyRelayoutOnSafeAreaChanges = true
        automaticallyRelayoutOnLayoutMarginsChanges = true
    }

    open override func didLoad() {
		super.didLoad()
		UIContext.shared.languageCode.skip(1).subscribe(onNext: { [weak self] _ in
			self?.didChangedLanguage()
		}) => _langBag
	}

	open func didChangedLanguage() {}
}

open class ASMControlNode: ASControlNode {
    private let _langBag = DisposeBag()
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
        automaticallyRelayoutOnSafeAreaChanges = true
        automaticallyRelayoutOnLayoutMarginsChanges = true
    }

    open override func didLoad() {
		super.didLoad()
		UIContext.shared.languageCode.skip(1).subscribe(onNext: { [weak self] _ in
			self?.didChangedLanguage()
		}) => _langBag
	}

	open func didChangedLanguage() {}
}

open class ASMScrollNode: ASScrollNode {
	private let _langBag = DisposeBag()
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
        automaticallyManagesContentSize = true
        automaticallyRelayoutOnSafeAreaChanges = true
        automaticallyRelayoutOnLayoutMarginsChanges = true
    }

    open override func didLoad() {
		super.didLoad()
		UIContext.shared.languageCode.skip(1).subscribe(onNext: { [weak self] _ in
			self?.didChangedLanguage()
		}) => _langBag
	}

	open func didChangedLanguage() {}
}
