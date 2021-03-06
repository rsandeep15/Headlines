//
//  NewsControllerMain.swift
//  Headline
//
//  Created by Sandeep Raghunandhan on 1/5/17.
//  Copyright © 2017 Sandeep Raghunandhan. All rights reserved.
//  API Support: News API
//  Articles from NYTimes 
//

import Foundation
import Cocoa
@available(OSX 10.12.2, *)
// Identifiers for each headline to be displayed
extension NSTouchBarItemIdentifier {
    static let headline1 = NSTouchBarItemIdentifier("com.sandeepraghu.headline1")
    static let headline2 = NSTouchBarItemIdentifier("com.sandeepraghu.headline2")
    static let headline3 = NSTouchBarItemIdentifier("com.sandeepraghu.headline3")
    static let wrapper = NSTouchBarItemIdentifier("com.sandeepraghu.wrapper")
}
var fetched_urls : Array = ["", "", ""]
@available(OSX 10.12.2, *)
extension NewsWindowController : NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.wrapper, .headline1, .headline2, .headline3]
        return touchBar
    }
    // Create an indexing for each headline button
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        // Attribution display
        case NSTouchBarItemIdentifier.wrapper:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let attributeWrap : NSScrollView = NSScrollView()
            let button = NSButton(title: "Powered By: NewsAPI", target: nil, action: nil)
            attributeWrap.addSubview(button)
            item.view = attributeWrap
            return item
        // The three different current headlines
        case NSTouchBarItemIdentifier.headline1:
            let item = NSCustomTouchBarItem(identifier: identifier)
            fetch(item, 0)
            return item
        case NSTouchBarItemIdentifier.headline2:
            let item = NSCustomTouchBarItem(identifier: identifier)
            fetch(item, 1)
            return item
        case NSTouchBarItemIdentifier.headline3:
            let item = NSCustomTouchBarItem(identifier: identifier)
            fetch(item, 2)
            return item
        default: return nil
        }
    }
    // Perform a live fetch of the current articles and parse the JSON for the blurbs
    func fetch(_ item: NSCustomTouchBarItem, _ index: Int) {
       
        let url = URL(string: "https://newsapi.org/v1/articles?source=the-new-york-times&sortBy=top&apiKey=d15328f167764bfca6d7cb6ea4a25218")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            DispatchQueue.main.async {
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = json as? [String: Any]{
                    if let articles = dictionary["articles"] as? [[String: String]]{
                        let title = articles[index]["title"]!
                        let article_url = articles[index]["url"]!
                        let button = NSButton(title: title, target: nil, action: nil)
                        button.font = NSFont(name: "San Francisco", size: 14)
                        button.tag = index
                        fetched_urls[index] = article_url
                        button.action = #selector(self.openUrl)
                        let wrapper: NSScrollView = NSScrollView()
                        wrapper.addSubview(button)
                        item.view = wrapper
                        
                    }
                }
            }
        }
        
        task.resume()
    }
    // Open the article on the user's default browser when the headline button is touched
    func openUrl(_ sender: AnyObject) {
        if let url = URL(string: fetched_urls[sender.tag]), NSWorkspace.shared().open(url){
            print("opened")
        }
    }
}
