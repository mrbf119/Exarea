//
//  Toaster.swift
//  exarea
//
//  Created by Soroush on 1/16/1398 AP.
//  Copyright © 1398 tamtom. All rights reserved.
//

import SwiftMessages

protocol ToastableError: LocalizedError {
    var image: UIImage? { get }
}

class Toaster {
    
    static let `default` = Toaster()
    
    func toast(error: RetryNeededError, handler: @escaping () -> Void) {
        self.toast(title: error.failureReason!,
                   content: error.recoverySuggestion!,
                   image: error.image,
                   theme: .error,
                   duration: .forever,
                   buttonHandler: handler,
                   buttonTitle: "تلاش مجدد")
    }
    
    func toast(error: ToastableError) {
        self.toast(title: error.failureReason!,
                   content: error.recoverySuggestion!,
                   image: error.image,
                   theme: .error,
                   duration: .automatic)
    }
    
    
    
    func toast(title: String,
               content: String,
               image: UIImage? = nil,
               theme: Theme = .success,
               layout: MessageView.Layout = MessageView.Layout.cardView,
               duration: SwiftMessages.Duration = .automatic,
               buttonHandler: (() -> Void)? = nil,
               buttonTitle: String? = nil) {
        
        
//        let view: MessageView = try! SwiftMessages.viewFromNib(named: "CustomMessageView")
        let view: MessageView = MessageView.viewFromNib(layout: .tabView)
        view.configureTheme(theme)
        view.titleLabel?.font = UIFont.iranSans.withSize(17)
        view.bodyLabel?.font = UIFont.iranSans.withSize(17)
        
        view.iconImageView?.image = image
        view.configureDropShadow()
        view.configureContent(title: "", body: content)
        
        if let title = buttonTitle, let action = buttonHandler {
            view.button?.titleLabel?.font = UIFont.iranSans.withSize(15)
            view.button?.setTitle(title, for: .normal)
            view.buttonTapHandler = { _ in
                action()
                SwiftMessages.hide()
            }
            view.titleLabel?.textAlignment =  .right
            view.bodyLabel?.textAlignment = .right
        } else {
            view.button?.isHidden = true
            view.titleLabel?.textAlignment =  .center
            view.bodyLabel?.textAlignment = .center
        }
        
        
        
        var config = SwiftMessages.Config()
        config.duration = duration
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: .statusBar)
        SwiftMessages.show(config: config, view: view)
    }
    
}
