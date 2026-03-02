import SwiftUI
import SwiftData

@main
struct SimpleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let modelContainer: ModelContainer = {
        let schema = Schema([TodoItem.self, Category.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let url = config.url
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.appendingPathExtension("wal"))
            try? FileManager.default.removeItem(at: url.appendingPathExtension("shm"))
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Could not create ModelContainer after recovery: \(error)")
            }
        }
    }()

    var body: some Scene {
        Window("Simple", id: "main") {
            MainView()
                .modelContainer(modelContainer)
        }
        .defaultSize(width: 780, height: 560)
        .defaultPosition(.center)

        MenuBarExtra("Simple", systemImage: "checklist") {
            MenuBarView()
                .modelContainer(modelContainer)
                .onAppear {
                    appDelegate.modelContainer = modelContainer
                }
        }
        .menuBarExtraStyle(.window)
    }
}
