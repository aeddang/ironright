//
//  PagePresenter.swift
//  user
//
//  Created by KimJeongCheol on 19/02/2019.
//  Copyright © 2019 kakaovx. All rights reserved.
//

import Foundation
import os.log

class PagePresenter : Presenter {
    
    private static var currentInstance: PagePresenter?
    static func getInstance() -> PagePresenter {
        guard let instance = currentInstance else { return PagePresenter(view:nil, model:PageModel())}
        return instance
    }
    
    private var view: View?
    internal let model: Model
    internal(set) var isNavigationShow = false
    
    init(view:View?, model:Model) {
        self.view = view
        self.model = model
        PagePresenter.currentInstance = self
    }
    
    deinit {
        os_log("PagePresenter : deinit", log: OSLog.default, type: .info)
    }
    
    internal func onDestroy() {
        self.model.onDestroy()
        PagePresenter.currentInstance = nil
        view = nil
    }
    
    func toggleNavigation() {
        if isNavigationShow { hideNavigation() } else { showNavigation() }
    }
    
    func showNavigation() {
        isNavigationShow = true
        view?.onShowNavigation()
    }
    
    func hideNavigation() {
        isNavigationShow = false
        view?.onHideNavigation()
    }
    
    func goHome() {
        pageChange(model.getHome(),isHistory: true, isBack: false)
    }
    
    @discardableResult
    func goBack() -> Bool { return onBack() }
    
    @discardableResult
    internal func onBack() -> Bool {
        if isNavigationShow {
            hideNavigation()
            return false
        }
        if let pop = model.getPopup() {
            closePopup(pop)
            return false
        }
        
        let tuple = model.getHistory()
        if let page = tuple?.0 {
            pageChange(page, param:tuple!.1!, isHistory:false, isBack:false)
            return false
        }
        return true
    }
    
    @discardableResult
    func closePopup(_ id:PageID) -> Presenter {
        model.removePopup(id)
        view?.onClosePopup(id)
        return self
    }
    
    @discardableResult
    func openPopup(_ id:PageID) -> Presenter {
        return openPopup(id, param:[String:Any]())
    }
    
    @discardableResult
    func openPopup(_ id:PageID, param:[String:Any]) -> Presenter{
        view?.onOpenPopup(id, param:param)
        model.addPopup(id)
        return self
    }
    
    @discardableResult
    func pageStart(_ id:PageID) -> Presenter {
        view?.onPageStart(id)
        model.addHistory(id, param:[String:Any](), isHistory:true)
        return self
    }
    
    @discardableResult
    func pageChange(_ id:PageID) -> Presenter {
        return pageChange(id, param:[String:Any](), isHistory:true, isBack:false)
    }
    @discardableResult
    func pageChange(_ id:PageID, param:[String:Any]) -> Presenter {
        return pageChange(id, param:param, isHistory:true, isBack:false)
    }
    
    @discardableResult
    func pageChange(_ id:PageID, isHistory:Bool) -> Presenter {
        return pageChange(id, param:[String:Any](), isHistory:isHistory, isBack:false)
    }
    
    @discardableResult
    func pageChange(_ id:PageID, isHistory:Bool, isBack:Bool) -> Presenter {
        return pageChange(id, param:[String:Any](), isHistory:isHistory, isBack:isBack)
    }
    
    @discardableResult
    func pageChange(_ id:PageID, param:[String:Any], isHistory:Bool, isBack:Bool) -> Presenter {
        view?.onPageChange(id, param:param, isBack:isBack)
        model.addHistory(id, param:param, isHistory:isHistory)
        return self
    }
    
    
}

