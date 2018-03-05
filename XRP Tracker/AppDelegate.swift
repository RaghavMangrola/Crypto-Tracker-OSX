//
//  AppDelegate.swift
//  XRP Tracker
//
//  Created by Raghav Mangrola on 3/5/18.
//

import Cocoa

struct Quote: Codable {
    let lastPrice: String
    private enum CodingKeys: String, CodingKey {
        case lastPrice = "last_price"
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "..."
        createMenu()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.sendRequest()
        }
        self.sendRequest()
    }

    private func sendRequest() {
        let url = URL(string: "https://api.bitfinex.com/v1/pubticker//xrpusd")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let quote = try? JSONDecoder().decode(Quote.self, from: data) else {
                    print("failed")
                return
            }
            DispatchQueue.main.async {
                self.statusItem.title = "\(quote.lastPrice)"
            }
        }.resume()
    }

    @objc private func createMenu() {
        let menu = NSMenu()
        let quitKillXcode = NSMenuItem(title: "Quit XRP Tracker", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        menu.addItem(quitKillXcode)
        statusItem.menu = menu
    }
}

