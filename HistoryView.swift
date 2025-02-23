import SwiftUI

struct HistoryView: View {
  @ObservedObject var glucoseData: GlucoseData
  
  var body: some View {
    NavigationView {
      List {
        if glucoseData.records.isEmpty {
          Text("No records available")
            .foregroundColor(.gray)
        } else {
          ForEach(glucoseData.records) { record in
            VStack(alignment: .leading) {
              Text("Date: \(formatDate(record.date))")
              Text("Time: \(formatTime(record.time))")
              Text("Glucose Level: \(record.glucoseLevel) mg/dL")
              Text("Meal Time: \(record.mealTime)")
            }
            .padding()
          }
        }
      }
      .navigationTitle("History")
    }
  }
  
  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
  }
  
  func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
