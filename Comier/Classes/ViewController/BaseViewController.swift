//
//  BaseViewController.swift
//  Comier
//
//  Created by Bách on 11/12/2020.
//

import Foundation
import AsyncDisplayKit
import RxSwift

public let ASBlank = ASStackLayoutSpec.vertical

open class ASDisplayNodePlus: ASDisplayNode {
    
    public override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = .white
    }
    
    public var transitionBlock: ((ASSizeRange, Bool, Bool, (() -> Void)?) -> Void)? = nil
    public var animateLayoutTransitionBlock: ((ASContextTransitioning) -> Void)? = nil
    public var didCompleteLayoutTransitionBlock: ((ASContextTransitioning) -> Void)? = nil
    
    open override func transitionLayout(with constrainedSize: ASSizeRange, animated: Bool, shouldMeasureAsync: Bool, measurementCompletion completion: (() -> Void)? = nil) {
        guard let block = transitionBlock else {
            return super.transitionLayout(
                with: constrainedSize,
                animated: animated,
                shouldMeasureAsync: shouldMeasureAsync,
                measurementCompletion: completion)
        }
        block(constrainedSize, animated, shouldMeasureAsync, completion)
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        super.layoutSpecThatFits(constrainedSize)
    }
    
    open override func layout() {
        super.layout()
    }
    
    open override func animateLayoutTransition(_ context: ASContextTransitioning) {
        guard let block = animateLayoutTransitionBlock else {return super.animateLayoutTransition(context)}
        block(context)
    }
    
    open override func didCompleteLayoutTransition(_ context: ASContextTransitioning) {
        guard let block = didCompleteLayoutTransitionBlock else {return super.didCompleteLayoutTransition(context)}
        block(context)
    }
}

open class COViewController<VM: ViewModel>: ASDKViewController<ASDisplayNode>, IViewModelViewController {
    public typealias IViewModelType = VM
    
    public let disposeBag = DisposeBag()
    public var viewModel: VM
    
    open var safeAreaInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
        
        return .zero
    }
    
    open var enableSafeArea: Bool {
        return true
    }
    
    open var useCustomTransitionAnimation: Bool {
        return false
    }
    
    public required init(viewModel: VM) {
        self.viewModel = viewModel
        let mainNode = ASDisplayNodePlus()
        super.init(node: mainNode)
        mainNode.backgroundColor = .white
        mainNode.layoutSpecBlock = {[weak self] (node, size) in
            guard let self = self else {return ASLayoutSpec()}
            return self.layoutSpecThatFits(size)
        }
        
        if useCustomTransitionAnimation {
            mainNode.transitionBlock = { [weak self] (size, animated, shouldMeasureAsync, completion) in
                guard let self = self else {return}
                self.transitionLayout(with: size, animated: animated, shouldMeasureAsync: shouldMeasureAsync, measurementCompletion: completion)
            }
            
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
        bindToViewModel()
    }
    
    open func bindToViewModel() {}
    
    open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASLayoutSpec()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open override func loadView() {
        super.loadView()
    }
    
    open override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        } else {
            // Fallback on earlier versions
        }
    }
    
    open func transitionLayout(with constrainedSize: ASSizeRange, animated: Bool, shouldMeasureAsync: Bool, measurementCompletion completion: (() -> Void)? = nil) {}
    open func animateLayoutTransition(_ context: ASContextTransitioning) {}
    open func didCompleteLayoutTransition(_ context: ASContextTransitioning) {}
}
