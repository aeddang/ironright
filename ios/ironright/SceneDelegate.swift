//
//  SceneDelegate.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/18.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import UIKit
import SwiftUI
import os.log

class TestObservable:ObservableObject{
    func test(testStr:String){
        os_log("TestObservable : %@",testStr)
    }
}


class SceneDelegate: PageSceneDelegate {


    override func onInitPage() {
        changePage(PageObject(pageID: "Init Page"))
    }
    
    override func adjustEnvironmentObjects<T>(_ view: T) -> AnyView where T : View
    {
        return AnyView(view.environmentObject(TestObservable()))
    }
    
    override func getPageContentProtocol(_ page: PageObject) -> PageViewProtocol {
        return super.getPageContentProtocol(page)
    }
}

