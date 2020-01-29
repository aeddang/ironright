//
//  PageProtocol.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/20.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//
import SwiftUI
import os.log
public typealias PageID = String
public struct PageObject{
    private(set) var pageID: PageID = ""
    private(set) var pageIDX = 0
    private(set) var params:[String:Any]?
    private(set) var isPopup = false
    private(set) var pageKey = UUID().description
}

enum SceneStatus {
    case Init,
    BecomeActive,
    Disconnect ,
    ResignActive  ,
    EnterForeground ,
    EnterBackground
}

open class PageObservable: ObservableObject  {
    @Published var status:SceneStatus = SceneStatus.Init
    @Published var pageObject:PageObject?
    @Published var pagePosition:CGPoint = CGPoint()
    
    @Published var isBackground:Bool = false
    @Published var isAnimationComplete:Bool = false
}

public protocol PageContentProtocol {
    var childViews:[PageViewProtocol] { get }
    var pageObservable:PageObservable { get }
}
public extension PageContentProtocol {
    //override func
    func onSetPageObject(_ page:PageObject){}
    func onInitAnimationComplete(){}
    func onRemoveAnimationStart(){}
    func onSceneDidBecomeActive(){}
    func onSceneDidDisconnect(){}
    func onSceneWillResignActive(){}
    func onSceneWillEnterForeground(){}
    func onSceneDidEnterBackground(){}
    
    //super func
    func setPageObject(_ page:PageObject, offSetX:CGFloat = 0, offSetY:CGFloat = 0){
        pageObservable.pageObject = page
        pageObservable.pagePosition.x = offSetX
        pageObservable.pagePosition.y = offSetY
        childViews.forEach{ $0.setPageObject(page)}
        onSetPageObject(page)
    }
    func initAnimationComplete(){
        childViews.forEach{ $0.initAnimationComplete() }
        pageObservable.isAnimationComplete = true
        onInitAnimationComplete()
    }
    func removeAnimationStart(){
        childViews.forEach{ $0.removeAnimationStart() }
        pageObservable.isAnimationComplete = false
        onRemoveAnimationStart()
    }
    func sceneDidBecomeActive(_ scene: UIScene){
        childViews.forEach{ $0.sceneDidBecomeActive( scene ) }
        pageObservable.status = SceneStatus.BecomeActive
        pageObservable.isBackground = false
        onSceneDidBecomeActive()
    }
    func sceneDidDisconnect(_ scene: UIScene){
        childViews.forEach{ $0.sceneDidDisconnect( scene ) }
        pageObservable.status = SceneStatus.Disconnect
        onSceneDidDisconnect()
    }
    func sceneWillResignActive(_ scene: UIScene){
        childViews.forEach{ $0.sceneWillResignActive( scene ) }
        pageObservable.status = SceneStatus.ResignActive
        onSceneWillResignActive()
    }
    func sceneWillEnterForeground(_ scene: UIScene){
        childViews.forEach{ $0.sceneWillEnterForeground( scene ) }
        pageObservable.status = SceneStatus.EnterForeground
        onSceneWillEnterForeground()
    }
    func sceneDidEnterBackground(_ scene: UIScene){
        childViews.forEach{ $0.sceneDidEnterBackground( scene ) }
        pageObservable.status = SceneStatus.EnterBackground
        pageObservable.isBackground = true
        onSceneDidEnterBackground()
    }
}
public protocol PageViewProtocol : PageContentProtocol{
    var pageID:PageID { get }
    var pageKey:String { get }
    var contentBody:AnyView { get }
}

public protocol PageView : View, PageViewProtocol{}
public extension PageView {
    var childViews:[PageViewProtocol] {
        get{ [] }
    }
    var pageID:PageID{
        get{ pageObservable.pageObject?.pageID ?? ""}
    }
    var pageKey:String{
        get{ pageObservable.pageObject?.pageKey ?? ""}
    }
    var contentBody:AnyView { get{
        return AnyView(self)
    }}
    
}
