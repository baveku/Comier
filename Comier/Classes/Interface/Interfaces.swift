//
//  Interfaces.swift
//  Seeler
//
//  Created by Bách on 7/15/20.
//  Copyright © 2020 BachVQ. All rights reserved.
//

//import UIKit
import RxSwift
import Swinject
import IGListKit
import AsyncDisplayKit
import RxCocoa
import Foundation

public protocol Class: AnyObject { }

public protocol Interface: CustomStringConvertible { }

public protocol IManager: Interface {
    func managerDidLoad()
}

public protocol IService: Interface {
    func serviceDidLoad()
}

public protocol IModel: Interface { }

public protocol IViewModel: Interface {
    func viewModelDidLoad()
}

public protocol IListViewModel: IViewModel {
    associatedtype Element: ListDiffable
    var elements: BehaviorSubject<[Element]> { get }
    func bindToAdapter(_ adapter: ListAdapter) -> Disposable
}
public protocol IReusableView: Interface, Class where Self: UIView {
    func prepareForReuse()
}

public protocol IReuseIdentifiable: Interface, Class {
    static var reuseIdentifier: String { get }
}

public protocol IViewModelViewController {
    associatedtype IViewModelType: IViewModel
    var viewModel: IViewModelType { get }
    init(viewModel: IViewModelType)
    func bindToViewModel()
    func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
}

public class UIContext {
	public static let shared = UIContext()
	public let languageCode = BehaviorRelay<String>(value: "en")
    
    public static var currentLanguageCode: String {
        return shared.languageCode.value
    }
    
    public func setLang(_ new: String) {
        guard new != Self.currentLanguageCode else {return}
        languageCode.accept(new)
    }
}
