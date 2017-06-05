//
//  Copyright © 2017 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Paralayout
import UIKit


class SampleView: UIView {
    
    enum Metrics {
        static let contentMargin: CGFloat = 8
        static let iconSize: CGFloat = 40
        static let iconMargin: CGFloat = 16
        static let titleTextMargin: CGFloat = 12
        static let subtextMargin: CGFloat = 8
        
        static let minSubtextAspectRatio: CGFloat = 2
        static let maxSubtextAspectRatio: CGFloat = 20
    }
    
    // MARK: - Properties
    
    let iconFPOView = UIView()
    let titleLabel = Label()
    let subtextLabel = Label()
    
    /// Control some conditional attribute of this view or one of its subviews, e.g. visibility of an element, layout mode, etc.
    var isOptionOn: Bool {
        get {
            return iconFPOView.isHidden
        }
        set {
            print("icon --> " + (newValue ? "HIDDEN" : "VISIBLE"))
            iconFPOView.isHidden = newValue
            setNeedsLayout()
        }
    }
    
    /// Control some variable attribute of this view or one of its subviews, e.g. alpha, aspect ratio, etc.
    var optionSliderValue: CGFloat {
        get {
            return Interpolation(of: subtextLabel.preferredMaximumAspectRatio, from: Metrics.minSubtextAspectRatio, to: Metrics.maxSubtextAspectRatio).interpolate(from: 0, to: 1)
        }
        set {
            subtextLabel.preferredMaximumAspectRatio = Interpolation(ofUnit: newValue).interpolate(from: Metrics.minSubtextAspectRatio, to: Metrics.maxSubtextAspectRatio)
            print("subtext aspect ratio --> \(subtextLabel.preferredMaximumAspectRatio)")
            setNeedsLayout()
        }
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        /// Install subviews and configure appearance here.
        
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 8
        
        iconFPOView.frame.size = CGSize(width: Metrics.iconSize, height: Metrics.iconSize)
        iconFPOView.backgroundColor = .cyan
        iconFPOView.layer.cornerRadius = Metrics.iconSize / 2
        addSubview(iconFPOView)
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.text = "Title Text"
        addSubview(titleLabel)
        
        subtextLabel.numberOfLines = 0
        subtextLabel.textAlignment = .center
        subtextLabel.textColor = .gray
        subtextLabel.font = UIFont.systemFont(ofSize: 12)
        subtextLabel.text = "This is some detail text for the UI element"
        addSubview(subtextLabel)
    }
    
    // MARK: - UIView
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        /// Determine the best size that fits the container based on content (e.g. with methods in UIViewAdditions_Sizing).
        
        return CGSize(width: size.width, height: layoutInfo(for: size).totalHeight)
    }
    
    override func layoutSubviews() {
        /// Lay out subviews (e.g. with methods in UIViewAdditions_Alignment, _Distribution, and Interpolation).
        
        titleLabel.wrap(toFit: bounds.size, margins: Metrics.contentMargin)
        let (distribution, _, subtextLabelSize) = layoutInfo(for: bounds.size)
        
        subtextLabel.frame.size = subtextLabelSize
        applySubviewDistribution(distribution)
    }
    
    // MARK: - Private Methods
    
    private func layoutInfo(for boundsSize: CGSize) -> (distribution: [ViewDistributionItem], totalHeight: CGFloat, subtextSizeThatFits: CGSize) {
        let distribution = ViewDistributionItem.collapsing(
            iconFPOView,
            Metrics.iconMargin.fixed,
            
            Metrics.titleTextMargin.fixed,
            titleLabel,
            Metrics.titleTextMargin.fixed,
            
            Metrics.subtextMargin.fixed,
            subtextLabel
        )
        
        // Subtract the subtextLabel's actual height from the layout.
        let layoutHeightExcludingSubtext = ViewDistributionItem.layoutSize(of: distribution, axis: .vertical, flexibleSpaceMultiplier: Metrics.contentMargin) - subtextLabel.frameContentSize.height
        
        let subtextSizeThatFits = subtextLabel.frameSize(thatFitsWidth: boundsSize.width - Metrics.contentMargin * 2, height: boundsSize.height - layoutHeightExcludingSubtext, constraints: .wrap)
        
        return (distribution, layoutHeightExcludingSubtext + subtextSizeThatFits.height, subtextSizeThatFits)
    }
    
}
