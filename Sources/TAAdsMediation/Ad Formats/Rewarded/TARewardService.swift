//
//  TARewardService.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 17.02.2025.
//

import SwiftUI
import AppLovinSDK
import TAAnalytics

@MainActor
public class TARewardService: NSObject, ObservableObject {
    
    @Published var isAdAvailable: Bool = false
    
    let adUnitId: String
    let coordinator: Coordinator

    public init(adUnitId: String, delegate: TARewardAdEventDelegate = TADefaultRewardAdEventDelegate()) {
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
        
        TALogger.log("[TARewardService] Initialized with AdUnitID: \(adUnitId)", level: .info)
    }
    
    func loadAd() {
        TALogger.log("[TARewardService] Loading rewarded ad...", level: .info)
        coordinator.loadAd()
    }
    
    public func showAdIfAvailable() {
        if isAdAvailable {
            TALogger.log("[TARewardService] Showing rewarded ad...", level: .info)
            coordinator.showAdIfAvailable()
        } else {
            TALogger.log("[TARewardService] No rewarded ad available to show.", level: .info)
        }
    }
}

extension TARewardService {
    
    @MainActor
    class Coordinator: NSObject, MARewardedAdDelegate {
        
        private var retryAttempt = 0.0
        private var rewardedAd: MARewardedAd
        
        var isAdAvailable: Bool = false {
            didSet {
                continuation.yield(isAdAvailable)
            }
        }
        
        let delegate: TARewardAdEventDelegate
        let stream: AsyncStream<Bool>
        private let continuation: AsyncStream<Bool>.Continuation
        
        init(adUnitId: String, delegate: TARewardAdEventDelegate) {
            self.rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: adUnitId)
            let (stream, continuation) = AsyncStream.makeStream(of: Bool.self)
            self.delegate = delegate
            self.stream = stream
            self.continuation = continuation
            super.init()
            self.rewardedAd.delegate = self
        }
        
        deinit {
            continuation.finish()
        }
        
        func loadAd() {
            rewardedAd.load()
        }
        
        func showAdIfAvailable() {
            if isAdAvailable {
                rewardedAd.show()
            }
        }
        
        // MARK: - MARewardedAdDelegate Methods
        
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
                    self.rewardedAd.load()
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
                rewardedAd.load()
                delegate.didHide(ad)
            }
        }
        
        nonisolated func didFail(toDisplay ad: MAAd, withError error: MAError) {
            Task { @MainActor in
                rewardedAd.load()
                delegate.didFail(toDisplay: ad, withError: error)
            }
        }
        
        nonisolated func didRewardUser(for ad: MAAd, with reward: MAReward) {
            Task { @MainActor in
                delegate.didRewardUser(for: ad, with: reward)
            }
        }
    }
}
