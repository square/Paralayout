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


class ViewController: UIViewController {
    
    private enum Metrics {
        fileprivate static let controlSize = CGSize(width: 12, height: 12)
    }
    
    /// Use a custom view that forwards touch events instantly (a UIPanGestureRecognizer has a built-in delay).
    private class DragTrackingView: UIView {
        fileprivate weak var viewController: ViewController? = nil
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            viewController?.dragBegan(touches)
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            viewController?.dragMoved(touches)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            viewController?.dragEnded(touches)
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            viewController?.dragEnded(touches)
        }
    }
    
    // MARK: - Properties
    
    private let containerView = UIView()
    private let resizeControls: [ Position : UIView ] = [
        .topLeft        : UIView(),
        .topCenter      : UIView(),
        .topRight       : UIView(),
        
        .leftCenter     : UIView(),
        .rightCenter    : UIView(),
        
        .bottomLeft     : UIView(),
        .bottomCenter   : UIView(),
        .bottomRight    : UIView()
    ]
    private let sampleView = SampleView()
    private let toggle = UISwitch()
    private let slider = UISlider()
    
    // Properties to track an active resize of the container.
    private var resizingTouch: UITouch? = nil
    private var resizingTouchStart: CGPoint = .zero
    private var resizingCorner = Position.center
    private var resizingContainerOriginalFrame: CGRect = .null
    
    // MARK: - UIViewController
    
    override func loadView() {
        let dragTrackingView = DragTrackingView(frame: UIScreen.main.bounds)
        dragTrackingView.backgroundColor = .white
        dragTrackingView.viewController = self
        
        view = dragTrackingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Install the container.
        containerView.frame = maximumContainerFrame.insetBy(dx: 8, dy: 8)
        containerView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = view.hairlineWidth
        
        view.addSubview(containerView)
        
        // Install the resize controls.
        for (_, resizeControl) in resizeControls {
            resizeControl.frame.size = Metrics.controlSize
            resizeControl.backgroundColor = .blue
            
            view.addSubview(resizeControl)
        }
        
        // Install the sample view.
        containerView.addSubview(sampleView)
        
        // Install the controls.
        toggle.isOn = sampleView.isOptionOn
        toggle.addTarget(self, action: #selector(toggleDidChange(_:)), for: .touchUpInside)
        view.addSubview(toggle)
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = Float(sampleView.optionSliderValue)
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        view.addSubview(slider)
    }
    
    override func viewDidLayoutSubviews() {
        for (position, resizeControl) in resizeControls {
            resizeControl.align(position.reflected(), with: containerView, position)
        }
        
        // Size the sample into the container with a hairline inset (so the border doesn't overlap it).
        sampleView.resize(toFit: containerView.bounds.insetBy(dx: view.hairlineWidth, dy: view.hairlineWidth).size)
        sampleView.alignToSuperview(.center)
        
        // Lay out the toggle and slider.
        let optionControlMargin: CGFloat = 8
        
        toggle.sizeToFit()
        toggle.alignToSuperview(.bottomLeft, inset: optionControlMargin)
        
        slider.resize(toFitWidth: view.bounds.width - (toggle.frame.width + 3 * optionControlMargin))
        slider.align(.leftCenter, with: toggle, .rightCenter, horizontalOffset: optionControlMargin)
    }
    
    // MARK: - Actions
    
    public func toggleDidChange(_ sender: Any?) {
        sampleView.isOptionOn = toggle.isOn
        view.setNeedsLayout()
    }
    
    public func sliderDidChange(_ sender: Any?) {
        sampleView.optionSliderValue = CGFloat(slider.value)
        view.setNeedsLayout()
    }
    
    // MARK: - Private Properties & Methods
    
    private var maximumContainerFrame: CGRect {
        return view.bounds.inset(left: Metrics.controlSize.width,
                                 top: 20 + Metrics.controlSize.height,
                                 right: Metrics.controlSize.width,
                                 bottom: Metrics.controlSize.height + 40)
    }
    
    fileprivate func dragBegan(_ touches: Set<UITouch>) {
        guard resizingTouch == nil, touches.count == 1, let touch = touches.first else {
            dragEnded(touches)
            return
        }
        
        for (position, resizeControl) in resizeControls {
            if resizeControl.bounds.contains(touch.location(in: resizeControl)) {
                resizingTouch = touch
                resizingTouchStart = touch.location(in: view)
                resizingCorner = position
                resizingContainerOriginalFrame = containerView.frame
                
                return
            }
        }
        
        // Touch did not land on a resize control. Do nothing.
    }
    
    fileprivate func dragMoved(_ touches: Set<UITouch>) {
        guard let resizingTouch = resizingTouch, touches.contains(resizingTouch) else {
            dragEnded(touches)
            return
        }
        
        let offset = resizingTouch.location(in: view) - resizingTouchStart
        let maximumFrame = maximumContainerFrame
        let originalFrame = resizingContainerOriginalFrame
        let minContainerSize = CGSize(width: Metrics.controlSize.width + 2 * view.hairlineWidth, height: Metrics.controlSize.height + 2 * view.hairlineWidth)
        
        // An edge can be moved out as far as the maximumFrame, and in as far as the opposite edge (minus the minimum width).
        func offsetLeft() -> CGFloat {
            return min(max(originalFrame.minX + offset.horizontal, maximumFrame.minX), containerView.frame.maxX - minContainerSize.width)
        }
        
        func offsetTop() -> CGFloat {
            return min(max(originalFrame.minY + offset.vertical, maximumFrame.minY), containerView.frame.maxY - minContainerSize.height)
        }
        
        func offsetRight() -> CGFloat {
            return max(min(originalFrame.maxX + offset.horizontal, maximumContainerFrame.maxX), containerView.frame.minX + minContainerSize.width)
        }
        
        func offsetBottom() -> CGFloat {
            return max(min(originalFrame.maxY + offset.vertical, maximumContainerFrame.maxY), containerView.frame.minY + minContainerSize.height)
        }
        
        // Based on which corner is being moved, offset or preserve the original edge.
        switch resizingCorner {
        case .topLeft:
            containerView.frame = CGRect(left: offsetLeft(), top: offsetTop(), right: originalFrame.maxX, bottom: originalFrame.maxY)
        case .topCenter:
            containerView.frame = CGRect(left: originalFrame.minX, top: offsetTop(), right: originalFrame.maxX, bottom: originalFrame.maxY)
        case .topRight:
            containerView.frame = CGRect(left: originalFrame.minX, top: offsetTop(), right: offsetRight(), bottom: originalFrame.maxY)
            
        case .leftCenter:
            containerView.frame = CGRect(left: offsetLeft(), top: originalFrame.minY, right: originalFrame.maxX, bottom: originalFrame.maxY)
        case .center:
            break
        case .rightCenter:
            containerView.frame = CGRect(left: originalFrame.minX, top: originalFrame.minY, right: offsetRight(), bottom: originalFrame.maxY)
            
        case .bottomLeft:
            containerView.frame = CGRect(left: offsetLeft(), top: originalFrame.minY, right: originalFrame.maxX, bottom: offsetBottom())
        case .bottomCenter:
            containerView.frame = CGRect(left: originalFrame.minX, top: originalFrame.minY, right: originalFrame.maxX, bottom: offsetBottom())
        case .bottomRight:
            containerView.frame = CGRect(left: originalFrame.minX, top: originalFrame.minY, right: offsetRight(), bottom: offsetBottom())
        }
        
        view.setNeedsLayout()
    }
    
    fileprivate func dragEnded(_ touches: Set<UITouch>) {
        resizingTouch = nil
        resizingTouchStart = .zero
        resizingCorner = .center
        resizingContainerOriginalFrame = .null
    }
    
}
