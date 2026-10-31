import SwiftUI
import SwiftData

@main struct MyApp: App {
    @State private var store = TemplateStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .modelContainer(for: GitignoreFile.self)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About My Gitignore") {
                    NSApplication.shared.orderFrontStandardAboutPanel(options: [
                        .credits: NSAttributedString(
                            string: "Create and manage your .gitignore files."
                        ),
                    ])
                }
            }
        }
    }
}
