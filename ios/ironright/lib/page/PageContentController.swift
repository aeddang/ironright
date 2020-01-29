//
//  PageContentView.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/19.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

final class PageControllerObservable: ObservableObject  {
    @Published var pages:[PageViewProtocol] = []
    @Published var popups:[PageViewProtocol] = []
}

struct PageContentController: View{
    var pageID: PageID = "PageContentController"
    var backgroundBody: AnyView = AnyView(PageBackgroundBody())
    @State var loadingBar: AnyView =  AnyView(CircularProgressIndicator())
    @ObservedObject var pageControllerObservable:PageControllerObservable = PageControllerObservable()
    @ObservedObject internal var pageObservable: PageObservable = PageObservable()
    @EnvironmentObject var pageChanger:PageChanger
    
    var currnetPage:PageViewProtocol?{
        get{
            return pageControllerObservable.pages.first
        }
    }
    
    var currnetView:PageViewProtocol?{
        get{
            if pageControllerObservable.popups.isEmpty { return currnetPage }
            return pageControllerObservable.popups.last
        }
    }
    var prevView:PageViewProtocol?{
        get{
            if pageControllerObservable.popups.count <= 1 { return currnetPage }
            return pageControllerObservable.popups[ pageControllerObservable.popups.count-2 ]
        }
    }
    
    public var body: some View {
        ZStack {
            backgroundBody
            ZStack(){
                ForEach(pageControllerObservable.pages, id: \.pageKey) { page in page.contentBody }
                ForEach(pageControllerObservable.popups, id: \.pageKey) { popup in popup.contentBody }
            }
            if pageChanger.isLoading { loadingBar }
        }
    }
    
    func addPage(_ page:PageViewProtocol){
        pageControllerObservable.pages.append(page)
    }
    func removePage(){
        pageControllerObservable.pages.removeFirst()
    }
    func addPopup(_ page:PageViewProtocol){
        pageControllerObservable.popups.append(page)
    }
    func getPopup(_ key:String) -> PageViewProtocol? {
        guard let findIdx = pageControllerObservable.popups.firstIndex(where: { $0.pageKey == key }) else { return nil }
        return pageControllerObservable.popups[findIdx]
    }
    func removePopup(_ key:String){
        guard let findIdx = pageControllerObservable.popups.firstIndex(where: { $0.pageKey == key }) else { return }
        pageControllerObservable.popups.remove(at: findIdx)
    }
    func removeAllPopup(){
        pageControllerObservable.popups.removeAll()
    }
    
    
    func sceneDidBecomeActive(_ scene: UIScene){
        pageObservable.status = SceneStatus.BecomeActive
        pageControllerObservable.pages.forEach({$0.sceneDidBecomeActive(scene)})
    }
    func sceneDidDisconnect(_ scene: UIScene){
        pageObservable.status = SceneStatus.Disconnect
        pageControllerObservable.pages.forEach({$0.sceneDidDisconnect(scene)})
    }
    func sceneWillResignActive(_ scene: UIScene){
        pageObservable.status = SceneStatus.ResignActive
        pageControllerObservable.pages.forEach({$0.sceneDidDisconnect(scene)})
    }
    func sceneWillEnterForeground(_ scene: UIScene){
        pageObservable.status = SceneStatus.EnterForeground
        pageControllerObservable.pages.forEach({$0.sceneWillEnterForeground(scene)})
    }
    func sceneDidEnterBackground(_ scene: UIScene){
        pageObservable.status = SceneStatus.EnterBackground
        pageControllerObservable.pages.forEach({$0.sceneDidEnterBackground(scene)})
    }
}


#if DEBUG
struct PageContentController_Previews: PreviewProvider {
    static var previews: some View {
        PageContentController().environmentObject(PageChanger())
    }
}
#endif
