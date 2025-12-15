//
//  qonaqstayApp.swift
//  qonaqstay
//
//  Created by Nurgazy Zhangozy on 14.12.2025.
//

import SwiftUI

@main
struct qonaqstayApp: App {
    private let container = AppContainer.liveInMemory()

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
                .environment(container)
        }
    }
}
