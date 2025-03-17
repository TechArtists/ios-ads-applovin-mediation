//
//  TAAppOpenAdService.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 24.02.2025.
//

import AppLovinSDK
import SwiftUI
import TAAnalytics

@MainActor
public class TAAppOpenAdService: NSObject, ObservableObject {
    
    @Published var isAdAvailable: Bool = false
    
    let adUnitId: String
    let coordinator: Coordinator
    
    public init(adUnitId: String, delegate: TAAppOpenEventDelegate = TADefaultAppOpenEventDelegate()) {
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
        
        loadAd()
        
        TALogger.log("[TAAppOpenAdService] Initialized with AdUnitID: \(adUnitId)", level: .info)
    }
    
    func loadAd() {
        TALogger.log("[TAAppOpenAdService] Loading app open ad...", level: .info)
        coordinator.loadAd()
    }
    
    public func showAdIfAvailable() {
        if isAdAvailable {
            TALogger.log("[TAAppOpenAdService] Showing app open ad...", level: .info)
            coordinator.showAdIfAvailable()
        } else {
            TALogger.log("[TAAppOpenAdService] No app open ad available to show.", level: .info)
        }
    }
}

extension TAAppOpenAdService {
    
    @MainActor
    class Coordinator: NSObject, MAAdDelegate {
        
        private var retryAttempt = 0.0
        private var appOpenAd: MAAppOpenAd
        
        var isAdAvailable: Bool = false {
            didSet {
                continuation.yield(isAdAvailable)
            }
        }
        
        let delegate: TAAppOpenEventDelegate
        let stream: AsyncStream<Bool>
        private let continuation: AsyncStream<Bool>.Continuation
        
        init(adUnitId: String, delegate: TAAppOpenEventDelegate) {
            self.appOpenAd = MAAppOpenAd(adUnitIdentifier: adUnitId)
            let (stream, continuation) = AsyncStream.makeStream(of: Bool.self)
            self.delegate = delegate
            self.stream = stream
            self.continuation = continuation
            super.init()
            self.appOpenAd.delegate = self
        }
        
        deinit {
            continuation.finish()
        }
        
        func loadAd() {
            appOpenAd.load()
        }
        
        func showAdIfAvailable() {
            if isAdAvailable {
                appOpenAd.show()
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
                    self?.appOpenAd.load()
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
                appOpenAd.load()
                
                delegate.didHide(ad)
            }
        }
        
        nonisolated func didFail(toDisplay ad: MAAd, withError error: MAError) {
            Task { @MainActor in
                appOpenAd.load()
                
                delegate.didFail(toDisplay: ad, withError: error)
            }
        }
    }
}
