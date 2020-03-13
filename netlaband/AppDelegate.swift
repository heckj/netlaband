//
//  AppDelegate.swift
//  netlaband
//
//  Created by Joseph Heck on 12/27/19.
//  Copyright © 2019 JFH Consulting. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let netanalysis = NetworkAnalyzer(urlsToCheck: ["https://google.com/", "https://www.facebook.com", "https://amazon.com"])

        let contentView = ContentView(networkModel: netanalysis)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable,
                        .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.canHide = true
        window.isOpaque = true
        window.minSize = CGSize(width: 400, height: 300)
        // ^^ widow.minSize appears to be ignored when I'm
        // using swiftUI elements within... or I'm just missing
        // something.
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
