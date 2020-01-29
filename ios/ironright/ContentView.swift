//
//  ContentView.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/18.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import SwiftUI

struct ContentView: PageView {
    @ObservedObject var pageObservable: PageObservable = PageObservable()
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentViewA: View {
    var body: some View {
        Text("Hello, World!")
    }
}
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ContentView().contentBody
            ContentViewA()
        }
    }
}
#endif
