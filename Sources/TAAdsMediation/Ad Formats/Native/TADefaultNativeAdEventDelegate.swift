//
//  TADefaultNativeAdEventDelegate.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 13.03.2025.
//

import SwiftUI
import UIKit
import AppLovinSDK
import TAAnalytics

public typealias TANativeAdEventDelegate = MANativeAdDelegate & MAAdRevenueDelegate & NSObject

@MainActor
public class TADefaultNativeAdEventDelegate: TANativeAdEventDelegate {
  
    nonisolated override public init() {
        super.init()
    }
    
    nonisolated public func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        // taAnalytics?.track(event: .adDidLoad(for: .native))
    }
    
    nonisolated public func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToLoad(for: .native, errorCode: error.code.rawValue))
        }
    }
    
    nonisolated public func didClickNativeAd(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidClick(for: .native))
        }
    }
    
    nonisolated public func didExpireNativeAd(_ ad: MAAd) {
        Task { @MainActor in
            TALogger.log("[TANativeAdView] Native ad expired.", level: .info)
        }
    }
    
    nonisolated public func didPayRevenue(for ad: MAAd) {
        Task { @MainActor in
            TALogger.log("[TANativeAdView] Revenue paid for native ad.", level: .info)
        }
    }
}
