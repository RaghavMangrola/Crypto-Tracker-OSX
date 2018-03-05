//
//  AppDelegate.swift
//  XRP Tracker
//
//  Created by Raghav Mangrola on 3/5/18.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var priceTimer: Timer!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        if let button = statusItem.button {
            button.title = "..."
        }

        createMenu()

        priceTimer = Timer(timeInterval: 10, repeats: true) { (_) in
            self.sendRequest()
        }
        priceTimer.fire()

        RunLoop.main.add(priceTimer, forMode: .commonModes)
    }

    func sendRequest() {
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default

        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        /* Create the Request:
         Request (GET https://api.bitfinex.com/v1/pubticker//xrpusd)
         */

        guard var URL = URL(string: "https://api.bitfinex.com/v1/pubticker//xrpusd") else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"

        // Headers


        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")

                guard let data = data else {
                    return
                }

                if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                    guard let midPrice = jsonData?["mid"] as? String else {
                        return
                    }

                    DispatchQueue.main.async {
                        self.statusItem.title = midPrice
                    }

                }
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }


        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

    @objc func createMenu() {
        let menu = NSMenu()

        let quitKillXcode = NSMenuItem(title: "Quit XRP Tracker", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")

        menu.addItem(quitKillXcode)

        statusItem.menu = menu
    }


}

