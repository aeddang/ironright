//
//  WebView.swift
//  ironright
//
//  Created by JeongCheol Kim on 2019/11/29.
//  Copyright © 2019 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
  
struct WebView : UIViewRepresentable {
      
    let request: URLRequest
    let scriptMessageHandler :WKScriptMessageHandler? = nil
    
    func makeUIView(context: Context) -> WKWebView  {
        if let scriptMessage = scriptMessageHandler {
            let webConfiguration = WKWebViewConfiguration()
            let contentController = WKUserContentController()
            contentController.add(scriptMessage, name: "scriptHandler")
            webConfiguration.userContentController = contentController
            return WKWebView(frame: .zero, configuration: webConfiguration)
        } else{
            return WKWebView()
        }
    }
      
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
      
}
/*
class WKScriptController: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message:WKScriptMessage) {
        // message.name = "scriptHandler" -> 위에 WKUserContentController()에 설정한 name
        // message.body = "searchBar" -> 스크립트 부분에 webkit.messageHandlers.scriptHandler.postMessage(<<이부분>>)
        
        if let body = message.body as? String, body == "searchBar" {
            guard let url = URL(string: Key.searchUrl) else { return }
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
            
        }
        if message.body is Array<Any> { print(message.body) }
    }
}
*/
  
#if DEBUG
struct WebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(request: URLRequest(url: URL(string: "https://www.apple.com")!))
    }
}
#endif
