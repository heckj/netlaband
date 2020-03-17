//
//  GridStack.swift
//  netlaband
//
//  Created by Joseph Heck on 3/17/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import SwiftUI

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }

    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}

struct GridStack_Previews: PreviewProvider {
    static var previews: some View {
        GridStack(rows: 4, columns: 4) { row, col in

            if row == 2 {
                Text("EXTRA")
            }
            // Image(systemName: "\(row * 4 + col).circle")
            Text("R\(row) C\(col)")
        }
    }
}
