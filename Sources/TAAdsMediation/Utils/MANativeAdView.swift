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
//  MANativeAdView.swift
//  TAAdsMediation
//
//  Created by Robert Tataru on 04.03.2025.
//

import UIKit
import SwiftUI
import AppLovinSDK
import TAAnalytics

public struct TANativeAdAppearance {
    public var backgroundColor: UIColor = .white
    public var titleFont: UIFont = .boldSystemFont(ofSize: 15)
    public var titleTextColor: UIColor = .black
    public var advertiserFont: UIFont = .systemFont(ofSize: 12)
    public var advertiserTextColor: UIColor = .gray
    public var bodyFont: UIFont = .systemFont(ofSize: 12)
    public var bodyTextColor: UIColor = .darkGray
    public var callToActionFont: UIFont = .systemFont(ofSize: 17)
    public var callToActionTextColor: UIColor = .white
    public var callToActionBackgroundColor: UIColor = .blue

    public init() { }
}

public class NativeAdView: MANativeAdView {
    
    private let appearance: TANativeAdAppearance
    
    public let optionsView: UIView = {
        let view = UIView()
        view.tag = 1005
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Initializers
    
    public init(appearance: TANativeAdAppearance = TANativeAdAppearance()) {
        self.appearance = appearance
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.appearance = TANativeAdAppearance()
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: Setup subviews and layout
    
    private func setupView() {
        backgroundColor = appearance.backgroundColor
        
        let adAttributionLabel = UILabel()
        adAttributionLabel.text = "Ad"
        adAttributionLabel.font = UIFont.boldSystemFont(ofSize: 12)
        adAttributionLabel.textColor = .gray
        adAttributionLabel.tag = 1009
        adAttributionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(adAttributionLabel)

        NSLayoutConstraint.activate([
            adAttributionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            adAttributionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        
        addSubview(optionsView)

        NSLayoutConstraint.activate([
            optionsView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            optionsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            optionsView.widthAnchor.constraint(equalToConstant: 20),
            optionsView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        if let titleLabel = self.titleLabel {
            titleLabel.font = appearance.titleFont
            titleLabel.textColor = appearance.titleTextColor
            titleLabel.tag = 1001
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let advertiserLabel = self.advertiserLabel {
            advertiserLabel.font = appearance.advertiserFont
            advertiserLabel.textColor = appearance.advertiserTextColor
            advertiserLabel.tag = 1002
            advertiserLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let bodyLabel = self.bodyLabel {
            bodyLabel.font = appearance.bodyFont
            bodyLabel.textColor = appearance.bodyTextColor
            bodyLabel.numberOfLines = 0
            bodyLabel.tag = 1003
            bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let iconImageView = self.iconImageView {
            iconImageView.contentMode = .scaleAspectFill
            iconImageView.clipsToBounds = true
            iconImageView.tag = 1004
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let mediaContentView = self.mediaContentView {
            mediaContentView.tag = 1006
            mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let callToActionButton = self.callToActionButton {
            callToActionButton.titleLabel?.font = appearance.callToActionFont
            callToActionButton.setTitleColor(appearance.callToActionTextColor, for: .normal)
            callToActionButton.backgroundColor = appearance.callToActionBackgroundColor
            callToActionButton.tag = 1007
            callToActionButton.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let starRatingContentView = self.starRatingContentView {
            starRatingContentView.tag = 1008
            starRatingContentView.translatesAutoresizingMaskIntoConstraints = false
        }
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        if let iconImageView = self.iconImageView {
            iconContainer.addSubview(iconImageView)
            NSLayoutConstraint.activate([
                iconImageView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
                iconImageView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
                iconImageView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
                iconImageView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
                iconContainer.widthAnchor.constraint(equalToConstant: 50),
                iconContainer.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        
        if let titleLabel = self.titleLabel { textContainer.addSubview(titleLabel) }
        if let advertiserLabel = self.advertiserLabel { textContainer.addSubview(advertiserLabel) }
        if let starRatingContentView = self.starRatingContentView { textContainer.addSubview(starRatingContentView) }

        
        if let titleLabel = self.titleLabel {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: textContainer.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: 8),
                titleLabel.heightAnchor.constraint(equalToConstant: 25)
            ])
        }
        
        if let starRatingContentView = self.starRatingContentView {
            NSLayoutConstraint.activate([
                starRatingContentView.topAnchor.constraint(equalTo: titleLabel?.bottomAnchor ?? textContainer.topAnchor),
                starRatingContentView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 8),
                starRatingContentView.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
                starRatingContentView.heightAnchor.constraint(equalToConstant: 11)
            ])
        }
        
        if let advertiserLabel = self.advertiserLabel, let starRatingContentView {
            NSLayoutConstraint.activate([
                advertiserLabel.topAnchor.constraint(equalTo: starRatingContentView.bottomAnchor),
                advertiserLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 8),
                advertiserLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
                advertiserLabel.heightAnchor.constraint(equalToConstant: 14)
            ])
        }
        
        let iconAndTextStackView = UIStackView(arrangedSubviews: [iconContainer, textContainer])
        iconAndTextStackView.axis = .horizontal
        iconAndTextStackView.alignment = .fill
        iconAndTextStackView.spacing = 8
        iconAndTextStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconAndTextStackView)
        if let bodyLabel = self.bodyLabel { addSubview(bodyLabel) }
        if let mediaContentView = self.mediaContentView { addSubview(mediaContentView) }
        if let callToActionButton = self.callToActionButton { addSubview(callToActionButton) }
        
        NSLayoutConstraint.activate([
            iconAndTextStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconAndTextStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconAndTextStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            iconAndTextStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        if let bodyLabel = self.bodyLabel {
            NSLayoutConstraint.activate([
                bodyLabel.topAnchor.constraint(equalTo: iconAndTextStackView.bottomAnchor, constant: 8),
                bodyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
            ])
        }
        
        if let mediaContentView = self.mediaContentView {
            NSLayoutConstraint.activate([
                mediaContentView.topAnchor.constraint(equalTo: bodyLabel?.bottomAnchor ?? iconAndTextStackView.bottomAnchor, constant: 8),
                mediaContentView.centerXAnchor.constraint(equalTo: centerXAnchor),
                mediaContentView.widthAnchor.constraint(equalToConstant: 189),
                mediaContentView.heightAnchor.constraint(equalTo: mediaContentView.widthAnchor, multiplier: 9.0/16.0)
            ])
        }
        
        if let callToActionButton = self.callToActionButton {
            NSLayoutConstraint.activate([
                callToActionButton.topAnchor.constraint(equalTo: mediaContentView?.bottomAnchor ?? iconAndTextStackView.bottomAnchor, constant: 8),
                callToActionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                callToActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                callToActionButton.heightAnchor.constraint(equalToConstant: 39),
                callToActionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        }
    }
}
