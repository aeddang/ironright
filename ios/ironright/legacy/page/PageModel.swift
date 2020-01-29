//
//  PageModel.swift
//  user
//
//  Created by KimJeongCheol on 19/02/2019.
//  Copyright © 2019 kakaovx. All rights reserved.
//

import Foundation
import os.log

class PageModel : Model {
    private var currentHistoryStack:PageID?
    private var currentParamStack:[String:Any]?
    private var histories:[PageID] = []
    private var params:[[String:Any]] = []
    private var popups:[PageID] = []
    var homes:[PageID] = ["home"]
    
    deinit {
        os_log("PageModel : deinit", log: OSLog.default, type: .info)
    }
    
    func onDestroy() {
        currentHistoryStack = nil
        currentParamStack = nil
        histories.removeAll()
        params.removeAll()
        popups.removeAll()
        homes.removeAll()
    }
    
    func getHome() -> PageID {
        return homes[0]
    }
    
    func addHistory(_ id:PageID, param:[String:Any], isHistory:Bool) {
        if isHistory  {
            if let it = currentHistoryStack { histories.append(it) }
            if let it = currentParamStack { params.append(it) }
        }
        
        if homes.firstIndex(of: id) != nil { clearAllHistory() }
        currentHistoryStack = id
        currentParamStack = param
    }
    
    func getHistory() -> (PageID?, [String:Any]?)? {
        if histories.isEmpty  { return nil }
        currentHistoryStack = nil
        currentParamStack = nil
        return (histories.popLast() , params.popLast())
    }
    
    func clearAllHistory() {
        histories.removeAll()
        params.removeAll()
    }
    
    func removePopup(_ id:PageID) {
        guard let idx = popups.lastIndex(of:id) else { return }
        popups.remove(at:idx)
    }
    
    func addPopup(_ id:PageID) {
        popups.append(id)
    }
    
    func getPopup() -> PageID? {
        if popups.isEmpty { return nil }
        return popups.last
    }
    
}
