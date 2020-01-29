import UIKit
import os.log

open class PageController: UIViewController, View, PageDelegate {
    
    @IBOutlet var contentView:UIView!
    
    private(set) var pagePresenter:Presenter?
    private(set) var currentPage:Page?
    private(set) var popups:[String:Page] = [:]
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        pagePresenter = PagePresenter(view:self, model:PageModel())
    }
    
    deinit {
        os_log("PageController : deinit", log: OSLog.default, type: .info)
    }
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        pagePresenter?.onDestroy()
        pagePresenter = nil
        currentPage?.onDestroy()
        currentPage = nil
        popups.forEach({$0.value.onDestroy()})
        popups.removeAll()
        
    }
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage?.viewWillAppear()
        popups.forEach({$0.value.viewWillAppear()})
        
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentPage?.viewWillDisappear()
        popups.forEach({$0.value.viewWillDisappear()})
    }
    
    func getPageByID(_ id:PageID) -> UIView? {
        preconditionFailure("This method must be overridden")
    }
    
    func onPageStart(_ id:PageID) {
        guard let v = getPageByID(id) else { return }
        guard var willChangePage = v as? Page else { return }
        willChangePage.pageID = id
        willChangePage.delegate = self
        willChangePage.pageType = PageType.INIT
        appandView(v)
        willChangePage.willCreateAnimation()
        willChangePage.onCreateAnimation()
    }
    
    func onPageChange(_ id:PageID, param:[String:Any], isBack:Bool) {
        guard let v = getPageByID(id) else { return }
        guard var willChangePage = v as? Page else { return }
        willChangePage.pageID = id
        willChangePage.delegate = self
        willChangePage.pageType =  (isBack) ? PageType.OUT : PageType.IN
        if !param.isEmpty { willChangePage.setParam(param) }
        appandView(v)
        willChangePage.willCreateAnimation()
        willChangePage.onCreateAnimation()
    }
    
    private func appandView(_ v:UIView) {
        let bounds = contentView.bounds
        v.frame = bounds
        v.autoresizingMask=[UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        contentView.insertSubview(v, at: 0)
    }
    
    func onCreateAnimation(_ v:Page) {
        if v.pageType == PageType.POPUP { return }
        if var page = currentPage {
            page.pageType = v.pageType
            page.onDestroyAnimation()
        }
        currentPage = v
    }
    
    func getPopupByID(_ id:PageID) -> UIView? {
        preconditionFailure("This method must be overridden")
    }
    
    func onOpenPopup(_ id:PageID, param:[String:Any]) {
        guard let v = getPopupByID(id) else { return }
        guard var popup = v as? Page else { return }
        popup.pageID = id
        popup.pageType = PageType.POPUP
        if !param.isEmpty { popup.setParam(param) }
        popups[id] = popup
        
        let bounds = contentView.bounds
        v.frame = bounds
        v.autoresizingMask=[UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        contentView.addSubview(v)
        popup.willCreateAnimation()
        popup.onCreateAnimation()
    }
    
    func onClosePopup(_ id:PageID) {
        guard let popup = popups.removeValue(forKey: id) else { return }
        popup.onClosePopupAnimation()
    }
    
    func onShowNavigation(){
        os_log("PageController : onShowNavigation", log: OSLog.default, type: .info)
    }
    func onHideNavigation(){
        os_log("PageController : onHideNavigation", log: OSLog.default, type: .info)
    }
    
}

