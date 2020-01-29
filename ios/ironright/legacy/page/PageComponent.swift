
import Foundation
import UIKit
import os.log

open class PageComponent: UIComponent , Page
{
    internal(set) var pageID:PageID?
    internal(set) var pageType:PageType = PageType.INIT
    internal var delegate:PageDelegate?
    fileprivate(set) var animationDuration = AnimationDuration.SHORT.rawValue
    
    deinit {
        os_log("PageComponent : deinit", log: OSLog.default, type: .info)
    }
    
    func viewWillAppear(){}
    func viewWillDisappear(){}
   
    internal func willCreateAnimation() {
        guard let screen = self.superview?.bounds else { return }
        var posX:CGFloat = 0
        var posY:CGFloat = 0
        var valueAlpha:CGFloat = 1
        switch pageType {
            case PageType.INIT : valueAlpha = 0
            case PageType.IN : posX = -screen.width
            case PageType.OUT : posX = screen.width
            case PageType.POPUP : posY = screen.height
        }
        self.frame.origin.x = posX
        self.frame.origin.y = posY
        self.alpha = valueAlpha
    }
    
    internal func onCreateAnimation() -> Double {
        
        var options:UIView.AnimationOptions?
        switch pageType {
            case PageType.INIT : options = UIView.AnimationOptions.curveEaseIn
            case PageType.IN : options = UIView.AnimationOptions.curveLinear
            case PageType.OUT : options = UIView.AnimationOptions.curveLinear
            case PageType.POPUP : options = UIView.AnimationOptions.curveEaseOut
        }
        UIView.animate(withDuration: animationDuration, delay: 0, options: options!, animations: {
            self.frame.origin.x = 0
            self.frame.origin.y = 0
            self.alpha = 1
        }) { _ in
            self.didCreateAnimation()
        }
        delegate?.onCreateAnimation(self)
        return animationDuration
    }
    func didCreateAnimation() {}
    
    
    internal func onClosePopupAnimation() -> Double {
        return onDestroyAnimation()
    }
    
    internal func onDestroyAnimation() -> Double {
        guard let screen = self.superview?.bounds else { return 0 }
        var posX:CGFloat = 0
        var posY:CGFloat = 0
        
        var options:UIView.AnimationOptions?
        switch pageType {
            case PageType.INIT, PageType.IN : options = UIView.AnimationOptions.curveLinear; posX = screen.width
            case PageType.OUT : options = UIView.AnimationOptions.curveLinear; posY = -screen.width
            case PageType.POPUP : options = UIView.AnimationOptions.curveEaseOut; posX = screen.height
        }
        UIView.animate(withDuration: animationDuration, delay: 0, options: options!, animations: {
            self.frame.origin.x = posX
            self.frame.origin.y = posY
        }) { _ in
            self.didDestroyAnimation()
        }
        return animationDuration
    }
    
    override func onDestroy() {
        didDestroyAnimation()
    }
    
    func didDestroyAnimation() {
        removeFromSuperview()
        pageID = nil
        delegate = nil
    }
  
    internal func setParam(_ param: [String : Any]) -> Page {
        return self
    }
    open func isBackAble() -> Bool { return true }
    
}
