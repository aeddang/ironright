//
//  SceneDelegate.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/18.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//
import UIKit
import SwiftUI
import Combine
import os.log
class PageChanger:ObservableObject{
    private(set) var page:PageObject? {
        didSet{
            guard let p = page else { return }
            PageSceneDelegate.instance?.changePage( p )
        }
    }
    private var popup:PageObject? {
        didSet{
            guard let p = popup else { return }
            PageSceneDelegate.instance?.openPopup( p )
        }
    }
    func changePage(_ pageID:PageID, params:[String:Any]? = nil, idx:Int = 0){
        if isBusy { return }
        page = PageObject(pageID: pageID, pageIDX: idx, params: params)
    }
    func openPopup(_ pageID:PageID, params:[String:Any]? = nil, idx:Int = 0){
        popup = PageObject(pageID: pageID, pageIDX: idx, params: params)
    }
    func closePopup(_ pageKey:String){
        PageSceneDelegate.instance?.closePopup(pageKey)
    }
    func closeAllPopup(){
        PageSceneDelegate.instance?.closeAllPopup()
    }
    func goBack(){
        PageSceneDelegate.instance?.goBack()
    }
    
    @Published var isLoading:Bool = false
    @Published var bodyColor:Color = Color.yellow
    @Published fileprivate(set) var isBusy:Bool = false
}

open class PageSceneDelegate: UIResponder, UIWindowSceneDelegate {
    static internal let CHANGE_DURATION = 0.5
    static internal let PAGE_ANIMATION = Animation.linear(duration: PageSceneDelegate.CHANGE_DURATION)
    static internal let POPUP_ANIMATION = Animation.easeOut(duration: PageSceneDelegate.CHANGE_DURATION)
    
    static internal var instance:PageSceneDelegate?
    
    public var window: UIWindow?
    var contentController:PageContentController?
    var historys:[PageObject] = []
    var popups:[PageObject] = []
    private let pageChanger = PageChanger()
    private var changeSubscription:AnyCancellable?
    private var popupSubscriptions:[String:AnyCancellable] = [String:AnyCancellable]()
    deinit {
        changeSubscription?.cancel()
        changeSubscription = nil
        popupSubscriptions.forEach{ $0.value.cancel() }
        popupSubscriptions.removeAll()
    }
    
    final public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        PageSceneDelegate.instance = self
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            setupRootViewController(window)
            self.window = window
            window.makeKeyAndVisible()
        }
        onInitPage()
    }
    
    private func setupRootViewController(_ window: UIWindow){
        contentController = PageContentController()
        let view = contentController?.environmentObject(pageChanger)
        window.rootViewController = UIHostingController(rootView: adjustEnvironmentObjects(view))
    }

    final func changePage(_ newPage:PageObject, isBack:Bool = false){
        pageChanger.isBusy = true
        let prevContent = contentController?.currnetPage
        let prevPage = prevContent?.pageObservable.pageObject
        var pageOffset:CGFloat = 0
        if let historyPage = prevPage {
            pageOffset = (historyPage.pageIDX > newPage.pageIDX) ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width
            if isBack {
                pageOffset = -pageOffset
            }else{
                historys.append(historyPage)
            }
            prevContent?.removeAnimationStart()
            prevContent?.pageObservable.pagePosition.x = -pageOffset
        }
        let nextContent = getPageContentBody(newPage)
        nextContent.setPageObject(newPage, offSetX:pageOffset)
        onWillChangePage(prevPage: prevPage, nextPage: newPage)
        contentController?.addPage(nextContent)
        changeSubscription = Timer.publish(every: PageSceneDelegate.CHANGE_DURATION, on: .current, in: RunLoop.Mode.common)
            .autoconnect()
            .sink() {_ in
                if prevContent != nil { self.contentController?.removePage()}
                self.pageChanger.isBusy = false
                self.changeSubscription?.cancel()
                self.changeSubscription = nil
                nextContent.initAnimationComplete()
        }
    }
    
    final func openPopup(_ popup:PageObject){
        popups.append(popup)
        let popupContent = getPageContentBody(popup)
        popupContent.setPageObject(popup, offSetY:UIScreen.main.bounds.height)
        onWillChangePage(prevPage: nil, nextPage: popup)
        contentController?.addPopup(popupContent)
        let key = popup.pageKey
        let subscription = Timer.publish(every: PageSceneDelegate.CHANGE_DURATION, on: .current, in: RunLoop.Mode.common)
            .autoconnect()
            .sink() {_ in
                self.popupSubscriptions[key]?.cancel()
                self.popupSubscriptions.removeValue(forKey: key)
                popupContent.initAnimationComplete()
    
        }
        popupSubscriptions.updateValue(subscription, forKey: key)
    }
    
    final func closePopup(_ key:String){
        guard let findIdx = popups.firstIndex(where: { $0.pageKey == key}) else { return }
        popups.remove(at: findIdx)
        guard let popupContent = contentController?.getPopup(key) else { return }
        popupContent.removeAnimationStart()
        popupContent.pageObservable.pagePosition.y = UIScreen.main.bounds.height
        onWillChangePage(prevPage: nil, nextPage: contentController?.prevView?.pageObservable.pageObject)
        let subscription = Timer.publish(every: PageSceneDelegate.CHANGE_DURATION, on: .current, in: RunLoop.Mode.common)
            .autoconnect()
            .sink() {_ in
                self.popupSubscriptions[key]?.cancel()
                self.popupSubscriptions.removeValue(forKey: key)
                self.contentController?.removePopup(key)
        }
        popupSubscriptions.updateValue(subscription, forKey: key)
    }
    
    final func closeAllPopup(){
        let key = UUID().description
        popups.removeAll()
        self.popupSubscriptions[key]?.cancel()
        contentController?.pageControllerObservable.popups.forEach{
            $0.removeAnimationStart()
            $0.pageObservable.pagePosition.y = UIScreen.main.bounds.height
        }
        onWillChangePage(prevPage: nil, nextPage: contentController?.currnetPage?.pageObservable.pageObject)
        
        let subscription = Timer.publish(every: PageSceneDelegate.CHANGE_DURATION, on: .current, in: RunLoop.Mode.common)
        .autoconnect()
            .sink() {_ in
                self.popupSubscriptions[key]?.cancel()
                self.popupSubscriptions.removeValue(forKey: key)
                self.contentController?.removeAllPopup()
        }
        popupSubscriptions.updateValue(subscription, forKey: key)
    }
    
    final func goBack(){
        let isHistoryBack = popups.isEmpty
        guard let back = isHistoryBack ? pageChanger.page : popups.last else { return }
        if isHistoryBack {
            guard let next = historys.last else { return }
            if !isGoBackAble(prevPage: back, nextPage: next) { return }
            historys.removeLast()
            changePage(next, isBack: true)
    
        }else{
            guard let next = popups.count <= 1 ? pageChanger.page : popups[popups.count-2] else { return }
            if !isGoBackAble(prevPage: back, nextPage: next) { return }
            closePopup(back.pageKey)
        }
    }
    
    
    open func onInitPage(){}
    open func getPageContentBody(_ page:PageObject) -> PageViewProtocol{ return PageContentBody(childViews:[getPageContentProtocol(page)]) }
    open func getPageContentProtocol(_ page:PageObject) -> PageViewProtocol{ return PageContent() }
    open func adjustEnvironmentObjects<T>(_ view:T) -> AnyView where T : View { return AnyView(view) }
    open func isGoBackAble(prevPage:PageObject?, nextPage:PageObject?) -> Bool { return true }
    open func onWillChangePage(prevPage:PageObject?, nextPage:PageObject?){}
    
    open func sceneDidDisconnect(_ scene: UIScene) { contentController?.sceneDidDisconnect(scene) }
    open func sceneDidBecomeActive(_ scene: UIScene) { contentController?.sceneDidBecomeActive(scene) }
    open func sceneWillResignActive(_ scene: UIScene) { contentController?.sceneWillResignActive(scene) }
    open func sceneWillEnterForeground(_ scene: UIScene) { contentController?.sceneWillEnterForeground(scene) }
    open func sceneDidEnterBackground(_ scene: UIScene) { contentController?.sceneDidEnterBackground(scene) }

}

