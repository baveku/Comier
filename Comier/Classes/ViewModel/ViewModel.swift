//
//  ViewModel.swift
//  Seeler
//
//  Created by Bách on 7/15/20.
//  Copyright © 2020 BachVQ. All rights reserved.
//

import Foundation

public typealias ViewModel = BaseViewModel & IViewModel

open class BaseViewModel: NSObject {
    // MARK: - Properties

    let appViewModel: AppViewModel

    public required init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        super.init()
        viewModelDidLoad()
    }

    public func viewModelDidLoad() {

    }
}
