//
//  ViewModel.swift
//  Seeler
//
//  Created by Bách on 7/15/20.
//  Copyright © 2020 BachVQ. All rights reserved.
//

import Foundation
import RxSwift

open class ViewModel: NSObject, IViewModel {
    // MARK: - Properties
    public let disposeBag = DisposeBag()

    public let appViewModel: AppViewModel

    public required init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        super.init()
        viewModelDidLoad()
    }

    open func viewModelDidLoad() {

    }
}
