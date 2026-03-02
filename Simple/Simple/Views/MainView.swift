import SwiftUI
import SwiftData

/// Root view for the main window: sidebar + task list detail.
struct MainView: View {
    @State private var selection: SidebarItem? = .section(.inbox)
    @State private var showNewCategory = false

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, showNewCategory: $showNewCategory)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 260)
        } detail: {
            switch selection {
            case .section(let section):
                TaskListView(filter: .section(section))
            case .category(let id):
                TaskListView(filter: .category(id))
            case nil:
                TaskListView(filter: .section(.inbox))
            }
        }
        .sheet(isPresented: $showNewCategory) {
            NewCategorySheet()
        }
    }
}
