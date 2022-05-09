//
//  BaseViewController.swift
//  Comier
//
//  Created by Bách on 11/12/2020.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import UIKit

public let ASBlank = ASStackLayoutSpec.vertical

open class ASDisplayNodePlus: ASDisplayNode {
    var nodeLayoutBlock: (() -> Void)? = nil
    var nodeLayoutDidFinishedBlock: (() -> Void)? = nil
    
    public override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = .white
    }
    
    public var animateLayoutTransitionBlock: ((ASContextTransitioning) -> Void)? = nil
    public var didCompleteLayoutTransitionBlock: ((ASContextTransitioning) -> Void)? = nil
    
    open override func layout() {
        super.layout()
        nodeLayoutBlock?()
    }
    
    open override func animateLayoutTransition(_ context: ASContextTransitioning) {
        guard let block = animateLayoutTransitionBlock else {return super.animateLayoutTransition(context)}
        block(context)
    }
    
    open override func didCompleteLayoutTransition(_ context: ASContextTransitioning) {
        guard let block = didCompleteLayoutTransitionBlock else {return super.didCompleteLayoutTransition(context)}
        block(context)
    }
    
    open override func layoutDidFinish() {
        super.layoutDidFinish()
        guard let block = nodeLayoutDidFinishedBlock else {return}
        block()
    }
}

open class ASViewModelController<VM: ViewModel>: BaseASViewController, IViewModelViewController {
    public typealias IViewModelType = VM
    public var viewModel: VM
    
    weak var refCollectionNode: ASCollectionNode! = nil
    
    public required init(viewModel: VM) {
        self.viewModel = viewModel
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("Comier doen't not support Xib + Storyboard, please use code to make beautiful layout")
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASLayoutSpec()
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        } else {
            // Fallback on earlier versions
        }
    }
    
    open override func transitionLayout(animated: Bool = true, shouldMeasureAsync: Bool = false, completion: (() -> Void)? = nil) {
        self.node.transitionLayout(withAnimation: animated, shouldMeasureAsync: shouldMeasureAsync, measurementCompletion: completion)
    }
    open override func animateLayoutTransition(_ context: ASContextTransitioning) {}
    open override func didCompleteLayoutTransition(_ context: ASContextTransitioning) {}
    
    open override func nodeLayout() {}
    open override func nodeLayoutDidFinish() {}
}

open class BaseASViewController: ASDKViewController<ASDisplayNode> {
    public let disposeBag = DisposeBag()
	private let _langBag = DisposeBag()
    
    open var useCustomTransitionAnimation: Bool {
        return false
    }
    
    public var ignoreSafeAreaInset: Bool = true {
        didSet {
            self.node.setNeedsLayout()
        }
    }
    
    private var firstLoad = true
    open func layoutFirstLoad() {}
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLoad {
            firstLoad = false
            layoutFirstLoad()
        }
    }
    
    public override init() {
        let mainNode = ASDisplayNodePlus()
        super.init(node: mainNode)
        mainNode.backgroundColor = .white
        
        mainNode.layoutSpecBlock = { [weak self] (node, size) in
            guard let self = self else {return ASStackLayoutSpec()}
            if self.ignoreSafeAreaInset {
                return self.layoutSpecThatFits(size)
            } else {
                return self.useSafeArea(size)
            }
        }
        
        mainNode.nodeLayoutBlock = { [weak self] in
            self?.nodeLayout()
        }
        
        mainNode.nodeLayoutDidFinishedBlock = { [weak self] in
            self?.nodeLayoutDidFinish()
        }
        
        if useCustomTransitionAnimation {
            
            mainNode.animateLayoutTransitionBlock = { [weak self] context in
                self?.animateLayoutTransition(context)
            }
            
            mainNode.didCompleteLayoutTransitionBlock = { [weak self] context in
                self?.didCompleteLayoutTransition(context)
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("Comier doen't not support Xib + Storyboard, please use code to make beautiful layout")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
        bindToViewModel()
        NotificationCenter.default.addObserver(self,
            selector: #selector(updateUI),
            name: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"), object: nil)
		UIContext.shared.languageCode.skip(1).subscribe(onNext: { [weak self] _ in
			self?.didChangedLanguage()
		}) => _langBag
	}

	open func didChangedLanguage() {}
    
    @objc open func updateUI() {
        self.node.setNeedsLayout()
    }
    
    open func bindToViewModel() {}
    
    open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASLayoutSpec()
    }
    
    func useSafeArea(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return LayoutSpec {
            InsetLayout(insets: safeAreaInsets) {
                self.layoutSpecThatFits(constrainedSize)
            }
        }
    }
    
    public var safeAreaInsets: UIEdgeInsets {
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        } else {
            insets.top = topLayoutGuide.length
            insets.bottom = bottomLayoutGuide.length
        }
        
        return insets
    }

	@available(iOS 11.0, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self.node.setNeedsLayout()
    }
    
    open func transitionLayout(animated: Bool = true, shouldMeasureAsync: Bool = false, completion: (() -> Void)? = nil) {
        self.node.transitionLayout(withAnimation: animated, shouldMeasureAsync: shouldMeasureAsync, measurementCompletion: completion)
    }
    open func animateLayoutTransition(_ context: ASContextTransitioning) {}
    open func didCompleteLayoutTransition(_ context: ASContextTransitioning) {}
    
    public var nodeHeight: CGFloat {
        return self.node.calculatedSize.height
    }
    
    open func nodeLayout() {}
    open func nodeLayoutDidFinish() {}

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

open class BaseViewController: UIViewController {
	private let _langBag = DisposeBag()
    open override func viewDidLoad() {
        super.viewDidLoad()
        fd_prefersNavigationBarHidden = true
		UIContext.shared.languageCode.skip(1).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            print("[COMIER][didChangedLanguage] \(String(describing: self))")
			self.didChangedLanguage()
		}) => _langBag
	}

	open func didChangedLanguage() {}
}
