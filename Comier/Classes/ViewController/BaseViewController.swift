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
    
    public required init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(node: ASDisplayNode())
        self.node.automaticallyManagesSubnodes = true
        self.node.backgroundColor = .white
        self.node.layoutSpecBlock = {[weak self] (node, size) in
            guard let self = self else {return ASLayoutSpec()}
            return self.layoutSpecThatFits(size)
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
}
