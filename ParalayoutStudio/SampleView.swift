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
        static let contentMargin: CGFloat = 16
        static let iconSize: CGFloat = 40
        static let iconMargin: CGFloat = 16
        static let textMargin: CGFloat = 12
        
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
        let (titleSize, subtextSize) = labelSizesThatFit(size)
        let heightThatFits = heightForContentExcludingAllText + (titleSize.height - titleLabel.verticalAlignmentInset) + (subtextSize.height - subtextLabel.verticalAlignmentInset)
        
        return CGSize(width: size.width, height: heightThatFits)
    }
    
    override func layoutSubviews() {
        (titleLabel.frame.size, subtextLabel.frame.size) = labelSizesThatFit(bounds.size)
        
        applySubviewDistribution(ViewDistributionItem.collapsing(
            iconFPOView,
            Metrics.iconMargin.fixed,
            titleLabel,
            Metrics.textMargin.fixed,
            subtextLabel
        ))
    }
    
    // MARK: Private Methods
    
    private var heightForContentExcludingAllText: CGFloat {
        return (Metrics.contentMargin +
            (iconFPOView.isHidden ? 0 : (Metrics.iconSize + Metrics.iconMargin)) +
            Metrics.textMargin +
            Metrics.contentMargin)
    }
    
    private func labelSizesThatFit(_ size: CGSize) -> (CGSize, CGSize) {
        // The title is vertically unconstrained.
        let textWidth = max(0, size.width - 2 * Metrics.contentMargin)
        let titleLabelSize = titleLabel.frameSize(thatFitsWidth: textWidth, height: size.height, constraints: .wrap)
        
        // The subtext needs to fit in the space that remains. Take into account text heights.
        let titleLabelLayoutHeight = titleLabelSize.height - titleLabel.verticalAlignmentInset
        let verticalSpaceForSubtextLabel = size.height - heightForContentExcludingAllText - titleLabelLayoutHeight + subtextLabel.verticalAlignmentInset
        let subtextLabelSize = subtextLabel.frameSize(thatFitsWidth: textWidth, height: verticalSpaceForSubtextLabel, constraints: .wrap)
        
        return (titleLabelSize, subtextLabelSize)
    }
    
}
