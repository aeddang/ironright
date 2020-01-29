//
//  CircularProgressIndicator.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct CircularProgressIndicator: View {
    static private let _animation = Animation
        .linear(duration: 2)
        .repeatForever(autoreverses: false)

    @State var active: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke()
            Circle()
                .fill(Color.blue)
                .scaleEffect(CGFloat(0.10))
                .offset(x: 0, y: -40)
                .rotationEffect(.degrees(active ? 0 : -360))
                .animation(CircularProgressIndicator._animation)
        }
        .frame(height:CGFloat(80))
        .onAppear { self.active.toggle() }
    }
    
    
}
#if DEBUG
struct CircularProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressIndicator()
    }
}
#endif
