//
//  Component.swift
//  user
//
//  Created by KimJeongCheol on 20/02/2019.
//  Copyright © 2019 kakaovx. All rights reserved.
//

import Foundation
import UIKit
import os.log

open class UIComponent: UIView, Component
{
    @IBOutlet var contentView:UIView!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        bindingNib()
        onCreated()
    }
    
    deinit {
        os_log("UIConponent : deinit", log: OSLog.default, type: .info)
    }
        
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        bindingNib()
        onCreated()
    }
    
    private func bindingNib() {
        Bundle.main.loadNibNamed(getNibName(), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func getNibName() -> String {
        preconditionFailure("This method must be overridden")
    }
    
    func onDestroy() {
        preconditionFailure("This method must be overridden")
    }
    
    func onCreated() {
    }
    
        
}
