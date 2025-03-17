//
//  TANativeAdView.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 04.03.2025.
//

import SwiftUI
import UIKit
import AppLovinSDK
import TAAnalytics

@available(iOS 13.0, *)
public struct TANativeAdView: UIViewRepresentable {
    
    @Binding var isAdLoaded: Bool
    
    let adUnitId: String
    let appearance: TANativeAdAppearance
    let delegate: TANativeAdEventDelegate
    
    public init(adUnitId: String,
                appearance: TANativeAdAppearance = TANativeAdAppearance(),
                isAdLoaded: Binding<Bool>,
                delegate: TANativeAdEventDelegate = TADefaultNativeAdEventDelegate()) {
        self.adUnitId = adUnitId
        self.appearance = appearance
        self._isAdLoaded = isAdLoaded
        self.delegate = delegate
    }
    
    public func makeUIView(context: Context) -> MANativeAdView {
        let nativeAdView = NativeAdView(appearance: appearance)
        
        let adViewBinder = MANativeAdViewBinder(builderBlock: { builder in
            builder.titleLabelTag = 1001
            builder.advertiserLabelTag = 1002
            builder.bodyLabelTag = 1003
            builder.iconImageViewTag = 1004
            builder.optionsContentViewTag = 1005
            builder.mediaContentViewTag = 1006
            builder.callToActionButtonTag = 1007
            builder.starRatingContentViewTag = 1008
        })
        
        nativeAdView.bindViews(with: adViewBinder)
        
        context.coordinator.loadAd(into: nativeAdView)
        
        TALogger.log("[TANativeAdView] Initialized and loading native ad with AdUnitID: \(adUnitId)", level: .info)
        
        return nativeAdView
    }
    
    public func updateUIView(_ uiView: MANativeAdView, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        return Coordinator(adUnitId: adUnitId, isAdLoaded: $isAdLoaded, delegate: delegate)
    }
}

// MARK: - Coordinator (Handles Callbacks)
@available(iOS 13.0, *)
public extension TANativeAdView {
    class Coordinator: NSObject, MANativeAdDelegate, MAAdRevenueDelegate {
        
        private let isAdLoaded: Binding<Bool>
        private var retryAttempt = 0.0
        private var loadedNativeAd: MAAd?
        
        var adLoader: MANativeAdLoader
        let adUnitId: String
        let delegate: TANativeAdEventDelegate
        
        init(adUnitId: String, isAdLoaded: Binding<Bool>, delegate: TANativeAdEventDelegate) {
            self.adUnitId = adUnitId
            self.isAdLoaded = isAdLoaded
            self.adLoader = MANativeAdLoader(adUnitIdentifier: adUnitId)
            self.delegate = delegate
            
            super.init()
            
            adLoader.nativeAdDelegate = self
            adLoader.revenueDelegate = self
        }
        
        deinit {
           if let ad = loadedNativeAd {
               adLoader.destroy(ad)
           }
       }
        
        func loadAd(into nativeAdView: NativeAdView) {
            self.adLoader.loadAd(into: nativeAdView)
        }
        
        // MARK: - MANativeAdDelegate Methods
        public func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
            Task { @MainActor in
                if let previousAd = loadedNativeAd {
                    adLoader.destroy(previousAd)
                    TALogger.log("[TANativeAdView] Destroyed previous native ad.", level: .info)
                }
                loadedNativeAd = ad
                isAdLoaded.wrappedValue = true
                delegate.didLoadNativeAd(nativeAdView, for: ad)
            }
        }
        
        public func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
            Task { @MainActor in
                isAdLoaded.wrappedValue = false
                delegate.didFailToLoadNativeAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)
                
                self.retryAttempt += 1
                let delaySec = pow(2.0, min(6.0, retryAttempt))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) { [weak self] in
                    guard let self = self else { return }
                    self.adLoader.loadAd()
                }
            }
        }
        
        public func didClickNativeAd(_ ad: MAAd) {
            Task { @MainActor in
                delegate.didClickNativeAd(ad)
            }
        }
        
        public func didExpireNativeAd(_ ad: MAAd) {
            Task { @MainActor in
                delegate.didExpireNativeAd?(ad)
            }
        }
        
        // MARK: - MAAdRevenueDelegate Methods
        
        public func didPayRevenue(for ad: MAAd) {
            Task { @MainActor in
                delegate.didPayRevenue(for: ad)
            }
        }
    }
}
