//
//  PageContentBody.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os.log

struct PageBackgroundBody: View {
    @EnvironmentObject var pageChanger:PageChanger
    var body: some View {
        ZStack{
            Rectangle().fill(pageChanger.bodyColor)
        }
    }
}

struct PageContentBody: PageView  {
    @State var childViews:[PageViewProtocol] = []
    @EnvironmentObject var pageChanger:PageChanger
    @ObservedObject var pageObservable:PageObservable = PageObservable()

    var body: some View {

        VStack(alignment: .leading){
            ForEach(childViews, id: \.pageID) { page in
                page.contentBody
            }
        }
        .frame(alignment: .leading)
        .offset(x: self.pageObservable.pagePosition.x, y:self.pageObservable.pagePosition.y ).animation(PageSceneDelegate.PAGE_ANIMATION)
        .onAppear{
            os_log("onAppear : %@",self.pageID)
            self.pageObservable.pagePosition.x = 0
            self.pageObservable.pagePosition.y = 0
        }
        .onDisappear{
            os_log("onDisappear : %@",self.pageID)
        }
    }
}

struct PageContent: PageView  {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @EnvironmentObject var pageChanger:PageChanger
    @State var bodyColor:Color = Color.red
    static internal var index = 0
    
    var body: some View {
        ZStack(){
            Rectangle().fill(bodyColor)
            VStack{
                Button<Text>(action: {
                    self.pageChanger.changePage("Next" + PageContent.index.description)
                    PageContent.index += 1
                }) {
                    Text(pageObservable.isAnimationComplete ? pageID : "Loading")
                }
                Button<Text>(action: {
                    self.pageChanger.openPopup("Popup" + PageContent.index.description)
                    PageContent.index += 1
                }) {
                    Text("openPopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.closePopup(self.pageKey)
                }) {
                    Text("closePopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.closeAllPopup()
                }) {
                    Text("closeAllPopup")
                }
                
                Button<Text>(action: {
                    self.pageChanger.goBack()
                }) {
                    Text("back")
                }
            }
            
        }
    }
}

#if DEBUG
struct PageContentBody_Previews: PreviewProvider {
    static var previews: some View {
        PageBackgroundBody()
    }
}
#endif
