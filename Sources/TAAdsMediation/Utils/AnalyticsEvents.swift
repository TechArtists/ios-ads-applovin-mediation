/*
MIT License

Copyright (c) 2025 Tech Artists Agency

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//
//  AnalyticsEvents.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 17.02.2025.
//

import TAAnalytics

public var globalTAAnalytics: TAAnalytics?

enum AdFormat: String {
    case banner
    case interstitial
    case rewardedVideo
    case native
    case appOpen
}

public enum AnalyticsEventCategory: String, Hashable, CaseIterable {
    case load
    case display
    case click
    case dismiss
    case revenue
    case reward
    case expiry
    case impression
    case view
}

extension EventAnalyticsModel {
    
    // MARK: - Ad Load Events
    static func adDidLoad(for adFormat: AdFormat) -> Self { .init("adDidLoad_\(adFormat.rawValue)") }
    static func adDidFailToLoad(for adFormat: AdFormat, errorCode: Int) -> Self { .init("adDidFailToLoad_\(adFormat.rawValue)_error_\(errorCode)") }
    
    // MARK: - Ad Display Events
    static func adDidDisplay(for adFormat: AdFormat) -> Self { .init("adDidDisplay_\(adFormat.rawValue)") }
    static func adDidFailToDisplay(for adFormat: AdFormat, errorCode: Int) -> Self { .init("adDidFailToDisplay_\(adFormat.rawValue)_error_\(errorCode)") }
    
    // MARK: - Ad Click Events
    static func adDidClick(for adFormat: AdFormat) -> Self { .init("adDidClick_\(adFormat.rawValue)") }
    
    // MARK: - Ad Dismiss Events
    static func adDidDismiss(for adFormat: AdFormat) -> Self { .init("adDidDismiss_\(adFormat.rawValue)") }
    
    // MARK: - Ad Revenue Events
    static func adRevenuePaid(for adFormat: AdFormat, revenue: Double, currency: String) -> Self {
        .init("adRevenuePaid_\(adFormat.rawValue)_\(currency)_\(revenue)")
    }
    
    // MARK: - Ad Reward Events
    static func adDidRewardUser(for adFormat: AdFormat, rewardAmount: Int, rewardType: String) -> Self {
        .init("adDidRewardUser_\(adFormat.rawValue)_\(rewardType)_\(rewardAmount)")
    }
    
    // MARK: - Ad Expiry Events
    static func adExpired(for adFormat: AdFormat) -> Self { .init("adExpired_\(adFormat.rawValue)") }
    
    // MARK: - Ad Impression Events
    static func adImpressionTracked(for adFormat: AdFormat) -> Self { .init("adImpressionTracked_\(adFormat.rawValue)") }
    
    // MARK: - Ad View Events (Banner Specific MAAdViewAdDelegate)
    static func adDidExpand(for adFormat: AdFormat) -> Self { .init("adDidExpand_\(adFormat.rawValue)") }
    static func adDidCollapse(for adFormat: AdFormat) -> Self { .init("adDidCollapse_\(adFormat.rawValue)") }
}

enum AdAnalyticsEvent {
    case adDidLoad(for: AdFormat)
    case adDidFailToLoad(for: AdFormat, errorCode: Int)
    case adDidDisplay(for: AdFormat)
    case adDidFailToDisplay(for: AdFormat, errorCode: Int)
    case adDidClick(for: AdFormat)
    case adDidDismiss(for: AdFormat)
    case adRevenuePaid(for: AdFormat, revenue: Double, currency: String)
    case adDidRewardUser(for: AdFormat, rewardAmount: Int, rewardType: String)
    case adExpired(for: AdFormat)
    case adImpressionTracked(for: AdFormat)
    case adDidExpand(for: AdFormat)
    case adDidCollapse(for: AdFormat)
    
    var category: AnalyticsEventCategory {
        switch self {
        case .adDidLoad, .adDidFailToLoad:
            return .load
        case .adDidDisplay, .adDidFailToDisplay:
            return .display
        case .adDidClick:
            return .click
        case .adDidDismiss:
            return .dismiss
        case .adRevenuePaid:
            return .revenue
        case .adDidRewardUser:
            return .reward
        case .adExpired:
            return .expiry
        case .adImpressionTracked:
            return .impression
        case .adDidExpand, .adDidCollapse:
            return .view
        }
    }
    
    var analyticsModel: EventAnalyticsModel {
        switch self {
        case .adDidLoad(let adFormat):
            return .adDidLoad(for: adFormat)
        case .adDidFailToLoad(let adFormat, let errorCode):
            return .adDidFailToLoad(for: adFormat, errorCode: errorCode)
        case .adDidDisplay(let adFormat):
            return .adDidDisplay(for: adFormat)
        case .adDidFailToDisplay(let adFormat, let errorCode):
            return .adDidFailToDisplay(for: adFormat, errorCode: errorCode)
        case .adDidClick(let adFormat):
            return .adDidClick(for: adFormat)
        case .adDidDismiss(let adFormat):
            return .adDidDismiss(for: adFormat)
        case .adRevenuePaid(let adFormat, let revenue, let currency):
            return .adRevenuePaid(for: adFormat, revenue: revenue, currency: currency)
        case .adDidRewardUser(let adFormat, let rewardAmount, let rewardType):
            return .adDidRewardUser(for: adFormat, rewardAmount: rewardAmount, rewardType: rewardType)
        case .adExpired(let adFormat):
            return .adExpired(for: adFormat)
        case .adImpressionTracked(let adFormat):
            return .adImpressionTracked(for: adFormat)
        case .adDidExpand(let adFormat):
            return .adDidExpand(for: adFormat)
        case .adDidCollapse(let adFormat):
            return .adDidCollapse(for: adFormat)
        }
    }
}
