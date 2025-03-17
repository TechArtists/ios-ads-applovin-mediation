//
//  TAIntestitialService.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 17.02.2025.
//

import SwiftUI
import AppLovinSDK
import TAAnalytics

@MainActor
public class TAInterstitialService: NSObject, ObservableObject {
    
    @Published var isAdAvailable: Bool = false
    
    let adUnitId: String
    let coordinator: Coordinator
    
    public init(adUnitId: String, delegate: TAInterstitialAdEventDelegate = TADefaultInterstitialAdEventDelegate()) {
        self.adUnitId = adUnitId
        self.coordinator = Coordinator(adUnitId: adUnitId, delegate: delegate)
        
        super.init()
        
        Task { [weak self] in
            guard let self else { return }
            for await value in self.coordinator.stream {
                await MainActor.run {
                    self.isAdAvailable = value
                }
            }
        }
        
        TALogger.log("[TAInterstitialService] Initialized with AdUnitID: \(adUnitId)", level: .info)
        
        loadAd()
    }
    
    func loadAd() {
        TALogger.log("[TAInterstitialService] Loading interstitial ad...", level: .info)
        coordinator.loadAd()
    }
    
    public func showAdIfAvailable() {
        if isAdAvailable {
            TALogger.log("[TAInterstitialService] Showing interstitial ad...", level: .info)
            coordinator.showAdIfAvailable()
        } else {
            TALogger.log("[TAInterstitialService] No interstitial ad available to show.", level: .info)
        }
    }
}

extension TAInterstitialService {
    
    @MainActor
    class Coordinator: NSObject, MAAdDelegate {
        
        private var retryAttempt = 0.0
        private var interstitialAd: MAInterstitialAd
        
        var isAdAvailable: Bool = false {
            didSet {
                continuation.yield(isAdAvailable)
            }
        }
        
        let delegate: TAInterstitialAdEventDelegate
        let stream: AsyncStream<Bool>
        private let continuation: AsyncStream<Bool>.Continuation
        
        init(adUnitId: String, delegate: TAInterstitialAdEventDelegate) {
            self.interstitialAd = MAInterstitialAd(adUnitIdentifier: adUnitId)
            let (stream, continuation) = AsyncStream.makeStream(of: Bool.self)
            self.delegate = delegate
            self.stream = stream
            self.continuation = continuation
            super.init()
            self.interstitialAd.delegate = self
        }
        
        deinit {
            continuation.finish()
        }
        
        func loadAd() {
            interstitialAd.load()
        }
        
        func showAdIfAvailable() {
            if isAdAvailable {
                interstitialAd.show()
            }
        }
        
        // MARK: MAAdDelegate Protocol
        
        nonisolated func didLoad(_ ad: MAAd) {
            Task { @MainActor in
                self.retryAttempt = 0
                self.isAdAvailable = true
                delegate.didLoad(ad)
            }
        }
        
        nonisolated func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
            Task { @MainActor in
                self.isAdAvailable = false
                self.retryAttempt += 1
                let delaySec = pow(2.0, min(6.0, retryAttempt))
                
                delegate.didFailToLoadAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) { [weak self] in
                    self?.interstitialAd.load()
                }
            }
        }
        
        nonisolated func didDisplay(_ ad: MAAd) {
            Task { @MainActor in
                self.isAdAvailable = false
                delegate.didDisplay(ad)
            }
        }
        
        nonisolated func didClick(_ ad: MAAd) {
            Task { @MainActor in
                delegate.didClick(ad)
            }
        }
        
        nonisolated func didHide(_ ad: MAAd) {
            Task { @MainActor in
                interstitialAd.load()
                delegate.didHide(ad)
            }
        }
        
        nonisolated func didFail(toDisplay ad: MAAd, withError error: MAError) {
            Task { @MainActor in
                interstitialAd.load()
                delegate.didFail(toDisplay: ad, withError: error)
            }
        }
    }
}
