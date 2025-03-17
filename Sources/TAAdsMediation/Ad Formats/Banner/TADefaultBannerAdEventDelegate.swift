//
//  TADefaultBannerAdEventDelegate.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 13.03.2025.
//
import SwiftUI
import UIKit
import AppLovinSDK
import TAAnalytics

public typealias TABannerAdEventDelegate = MAAdViewAdDelegate & NSObject

@MainActor
public class TADefaultBannerAdEventDelegate: TABannerAdEventDelegate {
    
    nonisolated override public init() {
        super.init()
    }
    
    nonisolated public func didLoad(_ ad: MAAd) {
        // taAnalytics?.track(event: .adDidLoad(for: .banner))
    }
    
    nonisolated public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToLoad(for: .banner, errorCode: error.code.rawValue))
        }
    }
    
    nonisolated public func didDisplay(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidDisplay(for: .banner))
        }
    }
    
    nonisolated public func didHide(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidDismiss(for: .banner))
        }
    }
    
    nonisolated public func didClick(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidClick(for: .banner))
        }
    }
    
    nonisolated public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToDisplay(for: .banner, errorCode: error.code.rawValue))
        }
    }

    nonisolated public func didExpand(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidExpand(for: .banner))
        }
    }

    nonisolated public func didCollapse(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidCollapse(for: .banner))
        }
    }
}
