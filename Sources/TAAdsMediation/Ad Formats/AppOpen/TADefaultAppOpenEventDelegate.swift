//
//  TADefaultAppOpenEventDelegate.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 13.03.2025.
//

import AppLovinSDK
import SwiftUI
import TAAnalytics

public typealias TAAppOpenEventDelegate = MAAdDelegate & NSObject

@MainActor
public class TADefaultAppOpenEventDelegate: TAAppOpenEventDelegate {
    
    nonisolated override public init() {
        super.init()
    }
    
    nonisolated public func didLoad(_ ad: MAAd) {
        // taAnalytics?.track(event: .adDidLoad(for: .appOpen))
    }
    
    nonisolated public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToLoad(for: .appOpen, errorCode: error.code.rawValue))
        }
    }
    
    nonisolated public func didDisplay(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidDisplay(for: .appOpen))
        }
    }
    
    nonisolated public func didHide(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidDismiss(for: .appOpen))
        }
    }
    
    nonisolated public func didClick(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidClick(for: .appOpen))
        }
    }
    
    nonisolated public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToDisplay(for: .appOpen, errorCode: error.code.rawValue))
        }
    }
}
