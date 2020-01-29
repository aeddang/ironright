//
//  PageGestureComponent.swift
//  user
//
//  Created by KimJeongCheol on 20/02/2019.
//  Copyright © 2019 kakaovx. All rights reserved.
//

import Foundation
import UIKit
import os.log

protocol PageGestureViewDelegate {
    func onMove(_ view: PageGestureView, pct:CGFloat)
    func onAnimate(_ view: PageGestureView, pct:CGFloat)
    func onClose(_ view: PageGestureView)
    func onReturn(_ view: PageGestureView)
}
extension PageGestureViewDelegate {
    func onMove(_ view: PageGestureView, pct:CGFloat){}
    func onAnimate(_ view: PageGestureView, pct:CGFloat){}
    func onClose(_ view: PageGestureView){}
    func onReturn(_ view: PageGestureView){}
}

open class PageGestureView:GestureBody, GestureDelegate
{
    @IBOutlet var contentsView:UIView!
    
    let DURATION_DIV:CGFloat = 3000
    
    var delegate:PageGestureViewDelegate?
    
    private(set) var isClosed = false
    private var trigger = true
    private var startPosition:CGFloat = 0
    private var finalGesture = Gesture.GestureType.NONE
    
    lazy var contentSize:CGFloat = { return isVertical ? contentsView.bounds.height : contentsView.bounds.width }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        onCreated()
    }
    
    deinit {
        os_log("PageGestureView : deinit", log: OSLog.default, type: .info)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onCreated()
    }
    
    override func onCreated(){
        super.onCreated()
        gesture.delegate = self
    }
    
    func setGestureStart(_ startPos:CGFloat) {
        if isVertical { contentsView.frame.origin.y = startPos } else { contentsView.frame.origin.x = startPos }
    }
    
    func setGestureClose() {
        let closePosX = getClosePos().0
        let closePosY = getClosePos().1
        contentsView.frame.origin.x = closePosX
        contentsView.frame.origin.y = closePosY
    }
    
    override func onDestroy() {
        super.onDestroy()
        delegate = nil
    }
    
    func stateChange(_ g: Gesture, e: Gesture.GestureType) {
        let d = g.changePosA[0]
        switch e {
            case Gesture.GestureType.START : touchStart()
        case Gesture.GestureType.MOVE_V : touchMove(delta: d.y)
        case Gesture.GestureType.MOVE_H : touchMove(delta: d.x)
            case Gesture.GestureType.END, Gesture.GestureType.CANCEL : touchEnd()
            default : return
        }
    }
    
    private func touchStart() {
        finalGesture = Gesture.GestureType.NONE
        startPosition = isVertical ? contentsView.frame.origin.y : contentsView.frame.origin.x
    }
    
    private func getMoveAmount(_ pos:CGFloat) -> CGFloat {
        var p = pos
        var max:CGFloat = 0
        let frame = contentsView.frame
        switch closeType {
            case Gesture.GestureType.PAN_DOWN :
                max = frame.height
                if p > max { p = max } else if p < 0 { p = 0 }
                contentsView.frame.origin.y = p
            
            case Gesture.GestureType.PAN_UP :
                max = -frame.height
                if p < max { p = max } else if p > 0 { p = 0 }
                contentsView.frame.origin.y = p
        
            case Gesture.GestureType.PAN_RIGHT :
                max = frame.width
                if p > max { p = max } else if p < 0 { p = 0 }
                contentsView.frame.origin.x = p
            
            case Gesture.GestureType.PAN_LEFT :
                max = -frame.width
                if p < max { p = max } else if p > 0 { p = 0 }
                contentsView.frame.origin.x = p
            default : return 0
        }
        return  (max - p) / max
    }
    
    
    private func touchMove(delta:CGFloat) {
        let p = delta + startPosition
        delegate?.onMove(self, pct:getMoveAmount(p))
    }
    
    private func touchEnd() {
        if finalGesture == closeType { onGestureClose() } else { onGestureReturn() }
    }
    
    func gestureComplete(_ g: Gesture, e: Gesture.GestureType) {
        finalGesture = e
    }
    
    private func getClosePos() -> (CGFloat,CGFloat) {
        var closePosX:CGFloat = 0
        var closePosY:CGFloat = 0
        let frame = contentsView.frame
        switch closeType {
            case Gesture.GestureType.PAN_DOWN : closePosY = frame.height
            case Gesture.GestureType.PAN_UP : closePosY = -frame.height
            case Gesture.GestureType.PAN_RIGHT : closePosX = frame.width
            case Gesture.GestureType.PAN_LEFT : closePosX = -frame.width
            default : return (closePosX,closePosY)
        }
        return (closePosX,closePosY)
    }
    
    @discardableResult
    func onGestureClose(isClosure:Bool = true) -> Double {
        isClosed = true
        let closePosX = getClosePos().0
        let closePosY = getClosePos().1
        //let start = isVertical ? gestureView.frame.origin.y : gestureView.frame.origin.x
        //let end = isVertical ? closePosY : closePosX
        //update .setUpdateListener{this.onUpdateAnimation(it, start, end)}
        var d = isVertical ? abs(closePosY - contentsView.frame.origin.y) : abs(closePosX - contentsView.frame.origin.x)
        d /= DURATION_DIV
        let duration = Double(d)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.contentsView.frame.origin.x = closePosX
            self.contentsView.frame.origin.y = closePosY
        }) { _ in
            if isClosure { self.didCloseAnimation() }
        }
        return duration
    }
    
    func didCloseAnimation() {
        delegate?.onClose(self)
    }
    
    @discardableResult
    func onGestureReturn(isClosure:Bool = true) -> Double {
        isClosed = false
        //let start = isVertical ? gestureView.frame.origin.y : gestureView.frame.origin.x
        // .setUpdateListener{this.onUpdateAnimation(it, start, 0f)}
        var d = isVertical ? abs(contentsView.frame.origin.y) : abs(contentsView.frame.origin.x)
        d /= DURATION_DIV
        let duration = Double(d)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            self.contentsView.frame.origin.x = 0
            self.contentsView.frame.origin.y = 0
        }) { _ in
            if isClosure { self.didReturnAnimation() }
        }
        return duration
    }
    
    /*
    func onUpdateAnimation(animation: ValueAnimator, start: Float, end: Float) {
        val dr = if (end > start) 1f else -1f
        val range = Math.abs(end - start)
        val pct = animation.animatedValue as Float
        val pos = start + (dr*range*pct)
        delegate?.onAnimate(this, getMoveAmount(pos))
    }
    */
    
    func didReturnAnimation() {
        delegate?.onReturn(self)
    }
    
}

