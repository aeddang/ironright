//
//  PageGestureComponent.swift
//  user
//
//  Created by KimJeongCheol on 21/02/2019.
//  Copyright © 2019 kakaovx. All rights reserved.
//

import Foundation
import UIKit

class PageGestureComponent: PageComponent, PageGestureViewDelegate {
    
    @IBOutlet var gestureView:PageGestureView!
    @IBOutlet var backgroundView:UIView!
    
    
    override func onCreated() {
        super.onCreated()
    }
    
    
    override func onDestroy() {
        super.onDestroy()
    }
    
    override func willCreateAnimation() {
        backgroundView.alpha = 0
        gestureView.delegate = self
        gestureView.setGestureStart(self.bounds.height)
    }
    
    @discardableResult
    override func onCreateAnimation() -> Double {
        gestureView.onGestureReturn(isClosure: false)
        let duration = AnimationDuration.SHORT.rawValue
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.backgroundView.alpha = 1
        }) { _ in
            self.didCreateAnimation()
        }
        return duration
    }
    
    @discardableResult
    override func onClosePopupAnimation() -> Double {
        if gestureView.isClosed { return onDestroyAnimation() }
        gestureView.onGestureClose(isClosure: true)
        return 0
    }
    
    @discardableResult
    override func onDestroyAnimation() -> Double {
        gestureView.onGestureClose(isClosure: false)
        let duration = AnimationDuration.SHORT.rawValue
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.backgroundView.alpha = 0
        }) { _ in
            self.didDestroyAnimation()
        }
        return duration
    }
    
    func onMove(_ view: PageGestureView, pct:CGFloat) {
        backgroundView.alpha = pct
    }
    
    func onClose(_ view: PageGestureView) {
        if let id = pageID {
            PagePresenter.getInstance().closePopup(id)
            return
        }
        onDestroyAnimation()
    }
    
    override func didDestroyAnimation() {
        super.didDestroyAnimation()
        gestureView.onDestroy()
    }
    
    func onReturn(view: PageGestureView) {
        onCreateAnimation()
    }
    
    
}
