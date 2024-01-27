//
//  UIKitContentView.swift
//  ParalayoutVisionDemo
//
//  Created by Nicholas Entin on 1/26/24.
//

import Paralayout
import SwiftUI
import UIKit

struct UIKitContentView: UIViewRepresentable {

    typealias UIViewType = CustomView

    func makeUIView(context: Context) -> CustomView {
        return CustomView()
    }

    func updateUIView(_ uiView: CustomView, context: Context) {
        // No-op.
    }

}

final class CustomView: UIView {

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.text = "Hello, TV"
        label.textColor = .black
        addSubview(label)

        backgroundColor = .white
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Properties

    private let label: UILabel = .init()

    // MARK: - UIView

    override func layoutSubviews() {
        label.sizeToFit()
        label.align(withSuperview: .center)
    }

}
