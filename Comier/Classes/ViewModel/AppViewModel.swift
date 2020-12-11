//
//  AppViewModel.swift
//  Seeler
//
//  Created by Bách on 7/15/20.
//  Copyright © 2020 BachVQ. All rights reserved.
//
import UIKit
import RxSwift
import UserNotifications

public final class AppViewModel: NSObject, IViewModel {
	
    public enum Action {
		case didBackground
		case willResignActive
		case didBecomeActive
		case willTerminate
	}
	
    public let disposeBag = DisposeBag()
	// MARK: - Properties
	
    public var appDisplayName: String? {
		return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
	}
	
    public var bundleID: String? {
		return Bundle.main.bundleIdentifier
	}
	
    public var statusBarHeight: CGFloat {
		return UIApplication.shared.statusBarFrame.height
	}
	
    public var appBuild: String? {
		return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
	}
	
    public var applicationIconBadgeNumber: Int {
		get { return UIApplication.shared.applicationIconBadgeNumber }
		set { UIApplication.shared.applicationIconBadgeNumber = newValue }
	}
	
    public var appVersion: String? {
		return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
	}
	
    public var batteryLevel: Float {
		return UIDevice.current.batteryLevel
	}
	
    public var currentDevice: UIDevice {
		return UIDevice.current
	}
	
    public var deviceModel: String {
        return currentDevice.model
	}
	
    public var deviceName: String {
		return currentDevice.name
	}
	
    public var deviceOrientation: UIDeviceOrientation {
		return currentDevice.orientation
	}
	
    public var isInDebuggingMode: Bool {
		#if DEBUG
		return true
		#else
		return false
		#endif
	}
	
    public var isInTestFlight: Bool {
		return Bundle.main.appStoreReceiptURL?.path.contains("sandboxReceipt") == true
	}
	
    public var isNetworkActivityIndicatorVisible: Bool {
		get { return UIApplication.shared.isNetworkActivityIndicatorVisible }
		set { UIApplication.shared.isNetworkActivityIndicatorVisible = newValue }
	}
	
    public var isPhone: Bool {
		return UIDevice.current.userInterfaceIdiom == .phone
	}
	
    public var isRegisteredForRemoteNotifications: Bool {
		return UIApplication.shared.isRegisteredForRemoteNotifications
	}
	
    public var isRunningOnSimulator: Bool {
		#if targetEnvironment(simulator)
		return true
		#else
		return false
		#endif
	}
	
	// MARK: - Init
    public override init() {
		super.init()
		viewModelDidLoad()
	}
	
    public func viewModelDidLoad() {
		
	}
	
    public let selector = PublishSubject<Action>()
}
