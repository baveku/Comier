//
//  Manager.swift
//  Alamofire
//
//  Created by Bách on 21/01/2021.
//

import Foundation
import RxSwift

public typealias Manager = BaseManager & IManager

open class BaseManager: NSObject {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let appViewModel: AppViewModel
    
    public required init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        super.init()
        managerDidLoad()
    }
    
    open func managerDidLoad() {
        
    }
}
