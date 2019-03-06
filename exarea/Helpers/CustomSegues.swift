//
//  CustomSegues.swift
//  exarea
//
//  Created by Soroush on 12/9/1397 AP.
//  Copyright © 1397 tamtom. All rights reserved.
//

import SwiftMessages

public class MessagesCenteredSegue: SwiftMessagesSegue {
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        self.interactiveHide = false
        self.configure(layout: .centered)
        self.messageView.backgroundHeight = destination.preferredContentSize.height
        self.containerView.cornerRadius = 7
    }
}

public class MessagesBottomCardSegue: SwiftMessagesSegue {
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        self.interactiveHide = false
        self.dimMode = .blur(style: .dark, alpha: 0.3, interactive: false)
        self.configure(layout: .bottomCard)
        self.messageView.backgroundHeight = 120
        self.containerView.cornerRadius = 7
    }
}
