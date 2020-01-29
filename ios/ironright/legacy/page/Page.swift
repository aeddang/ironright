
import Foundation
import UIKit

typealias PageID = String

enum PageType {
    case INIT, IN, OUT, POPUP
}

protocol PageDelegate{
    func onCreateAnimation(_ v:Page)
}

protocol Component {
    func onCreated()
    func onDestroy()
    func getNibName()->String
}
extension Component {
    func getNibName()->String {return ""}
}

protocol Page:Component {
    var pageID:PageID? {get set}
    var pageType:PageType {get set}
    var delegate:PageDelegate? {get set}
    func viewWillAppear()
    func viewWillDisappear()
    func willCreateAnimation()
    @discardableResult func onCreateAnimation() -> Double
    @discardableResult func onClosePopupAnimation() -> Double
    @discardableResult func onDestroyAnimation() -> Double
    @discardableResult func isBackAble() -> Bool
    @discardableResult func setParam(_ param:[String:Any] ) -> Page
}

protocol Presenter {
    func goHome()
    @discardableResult func goBack() -> Bool
    func toggleNavigation()
    func showNavigation()
    func hideNavigation()
    func onDestroy()
    @discardableResult func closePopup(_ id:PageID) -> Presenter
    @discardableResult func openPopup(_ id:PageID) -> Presenter
    @discardableResult func openPopup(_ id:PageID, param:[String:Any] ) -> Presenter
    @discardableResult func pageStart(_ id:PageID) -> Presenter
    @discardableResult func pageChange(_ id:PageID) -> Presenter
    @discardableResult func pageChange(_ id:PageID, param:[String:Any]) -> Presenter
    @discardableResult func pageChange(_ id:PageID, isHistory:Bool) -> Presenter
    @discardableResult func pageChange(_ id:PageID, isHistory:Bool, isBack:Bool) -> Presenter
    @discardableResult func pageChange(_ id:PageID, param:[String:Any], isHistory:Bool, isBack:Bool) -> Presenter
}

protocol View {
    func onPageStart(_ id:PageID)
    func onPageChange(_ id:PageID, param:[String:Any], isBack:Bool)
    func onOpenPopup(_ id:PageID, param:[String:Any])
    func onClosePopup(_ id:PageID)
    func onShowNavigation()
    func onHideNavigation()
    func getPageByID(_ id:PageID) -> UIView?
    func getPopupByID(_ id:PageID) -> UIView?
}

protocol Model {
    func getHome() -> PageID
    func addHistory(_ id:PageID, param:[String:Any], isHistory:Bool)
    func getHistory() -> (PageID?, [String:Any]?)?
    func clearAllHistory()
    func removePopup(_ id:PageID)
    func addPopup(_ id:PageID)
    func getPopup() -> PageID?
    func onDestroy()
}
