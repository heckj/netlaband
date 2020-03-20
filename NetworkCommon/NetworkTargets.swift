//
//  NetworkTargets.swift
//  netlaband
//
//  Created by Joseph Heck on 3/20/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation

extension Collection {
    func choose(_ number: Int) -> ArraySlice<Element> { shuffled().prefix(number) }
}

struct NetworkTargets {
    static let top10USASites = [
        "https://google.com/",
        "https://youtube.com/",
        "https://www.facebook.com/",
        "https://amazon.com/",
        "https://www.yahoo.com/",
        "https://www.reddit.com/",
        "https://www.wikipedia.org/",
        "https://www.ebay.com/",
        "https://www.netflix.com/",
        "https://www.bing.com/",
    ]

    static func nameFromTarget(url: String) -> String {
        switch url {
        case "https://google.com/":
            return "google"
        case "https://youtube.com/":
            return "youtube"
        case "https://www.facebook.com/":
            return "facebook"
        case "https://amazon.com/":
            return "amazon"
        case "https://www.yahoo.com/":
            return "yahoo"
        case "https://www.reddit.com/":
            return "reddit"
        case "https://www.wikipedia.org/":
            return "wikipedia"
        case "https://www.ebay.com/":
            return "ebay"
        case "https://www.netflix.com/":
            return "netflix"
        case "https://www.bing.com/":
            return "bing"
        default:
            return "unknown"
        }
    }
}
