//
//  TADefaultRewardAdEventDelegate.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 13.03.2025.
//

import SwiftUI
import AppLovinSDK
import TAAnalytics

public typealias TARewardAdEventDelegate = MARewardedAdDelegate & NSObject

@MainActor
public class TADefaultRewardAdEventDelegate: TARewardAdEventDelegate {
    
    nonisolated override public init() {
        super.init()
    }
    
    nonisolated public func didLoad(_ ad: MAAd) {
        // taAnalytics?.track(event: .adDidLoad(for: .rewardedVideo))
    }
    
    nonisolated public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToLoad(for: .rewardedVideo, errorCode: error.code.rawValue))
        }
    }
    
    nonisolated public func didDisplay(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidDisplay(for: .rewardedVideo))
        }
    }
    
    nonisolated public func didHide(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidDismiss(for: .rewardedVideo))
        }
    }
    
    nonisolated public func didClick(_ ad: MAAd) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidClick(for: .rewardedVideo))
        }
    }
    
    nonisolated public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidFailToDisplay(for: .rewardedVideo, errorCode: error.code.rawValue))
        }
    }
    
    nonisolated public func didRewardUser(for ad: MAAd, with reward: MAReward) {
        Task { @MainActor in
            globalTAAnalytics?.track(event: .adDidRewardUser(for: .rewardedVideo, rewardAmount: Int(truncating: reward.amount as NSNumber), rewardType: reward.label))
        }
    }
}
