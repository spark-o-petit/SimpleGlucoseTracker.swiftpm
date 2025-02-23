import SwiftUI

struct ContentView: View {
  //  @StateObject private var glucoseData = GlucoseData()
  @StateObject private var glucoseData = GlucoseDataDummy()
  
  
  var body: some View {
    TabView {
      HomeView(glucoseData: glucoseData)
        .tabItem {
          Image(systemName: "house.fill")
          Text("Home")
        }
      
      HistoryView(glucoseData: glucoseData)
        .tabItem {
          Image(systemName: "calendar")
          Text("History")
        }
      
      ReportView(glucoseData: glucoseData)
        .tabItem {
          Label("Report", systemImage: "chart.bar.fill")
        }
    }
  }
}
