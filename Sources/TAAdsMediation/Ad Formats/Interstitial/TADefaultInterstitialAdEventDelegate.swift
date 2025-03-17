//
//  TADefaultInterstitialAdEventDelegate.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 13.03.2025.
//

import SwiftUI
import AppLovinSDK
import TAAnalytics

public typealias TAInterstitialAdEventDelegate = MAAdDelegate & NSObject

@MainActor
public class TADefaultInterstitialAdEventDelegate: TAInterstitialAdEventDelegate {
    
    nonisolated override public init() {
        super.init()
    }
    
    nonisolated public func didLoad(_ ad: MAAd) {
        // taAnalytics?.track(event: .adDidLoad(for: .interstitial))
    }
    
    nonisolated public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToLoad(for: .interstitial, errorCode: error.code.rawValue))
        }
    }
    
    nonisolated public func didDisplay(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidDisplay(for: .interstitial))
        }
    }
    
    nonisolated public func didHide(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidDismiss(for: .interstitial))
        }
    }
    
    nonisolated public func didClick(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidClick(for: .interstitial))
        }
    }
    
    nonisolated public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToDisplay(for: .interstitial, errorCode: error.code.rawValue))
        }
    }
}
