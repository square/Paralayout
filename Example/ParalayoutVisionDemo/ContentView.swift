//
//  ContentView.swift
//  ParalayoutVisionDemo
//
//  Created by Nicholas Entin on 1/26/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import UIKit

struct ContentView: View {
    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            UIKitContentView()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
