//
//  TABannerAdView.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 17.02.2025.
//

import SwiftUI
import UIKit
import AppLovinSDK
import TAAnalytics

public struct TABannerAdView: UIViewRepresentable {
    
    @Binding var isAdLoaded: Bool
    
    let adUnitId: String
    let delegate: TADefaultBannerAdEventDelegate
    
    public init(adUnitId: String, isAdLoaded: Binding<Bool>, delegate: TADefaultBannerAdEventDelegate = TADefaultBannerAdEventDelegate()) {
        self.adUnitId = adUnitId
        self._isAdLoaded = isAdLoaded
        self.delegate = delegate
    }
    
    public func makeUIView(context: Context) -> MAAdView {
        let adView = MAAdView(adUnitIdentifier: adUnitId)
        adView.delegate = context.coordinator
        adView.backgroundColor = .clear
        adView.loadAd()
        
        TALogger.log("[TABannerAdView] Initialized and loading banner ad with AdUnitID: \(adUnitId)", level: .info)
        
        return adView
    }
    
    public func updateUIView(_ uiView: MAAdView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(adUnitId: adUnitId, isAdLoaded: $isAdLoaded, delegate: delegate)
    }
}

public extension TABannerAdView {
    @MainActor
    class Coordinator: NSObject, MAAdViewAdDelegate {
        
        private let adView: MAAdView
        private let isAdLoaded: Binding<Bool>
        
        let delegate: TABannerAdEventDelegate
        
        init(adUnitId: String, isAdLoaded: Binding<Bool>, delegate: TABannerAdEventDelegate) {
            self.adView = MAAdView(adUnitIdentifier: adUnitId)
            self.isAdLoaded = isAdLoaded
            self.delegate = delegate
            super.init()
            self.adView.delegate = self
        }
        
        func loadAd() {
            adView.loadAd()
        }
        
        // MARK: MAAdViewAdDelegate Protocol
        
        nonisolated public func didLoad(_ ad: MAAd) {
            Task { @MainActor in
                self.isAdLoaded.wrappedValue = true
                delegate.didLoad(ad)
            }
        }
        
        nonisolated public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
            Task { @MainActor in
                self.isAdLoaded.wrappedValue = false
                delegate.didFailToLoadAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)
            }
        }
        
        nonisolated public func didDisplay(_ ad: MAAd) {
            Task { @MainActor in
                delegate.didDisplay(ad)
            }
        }
        
        nonisolated public func didClick(_ ad: MAAd) {
            Task { @MainActor in
                delegate.didClick(ad)
            }
        }
        
        nonisolated public func didHide(_ ad: MAAd) {
            Task { @MainActor in
                delegate.didHide(ad)
            }
        }
        
        nonisolated public func didFail(toDisplay ad: MAAd, withError error: MAError) {
            Task { @MainActor in
                delegate.didFail(toDisplay: ad, withError: error)
            }
        }

        nonisolated public func didExpand(_ ad: MAAd) {
            Task { @MainActor in
                delegate.didExpand(ad)
            }
        }

        nonisolated public func didCollapse(_ ad: MAAd) {
            Task { @MainActor in
                delegate.didCollapse(ad)
            }
        }
    }
}


