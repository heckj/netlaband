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
        "https://youtube.com",
        "https://www.facebook.com",
        "https://amazon.com",
        "https://facebook.com",
        "https://www.yahoo.com",
        "https://www.reddit.com",
        "https://www.wikipedia.org",
        "https://www.ebay.com",
        "https://www.netflix.com/",
        "https://www.bing.com/",
    ]
}
