import SwiftUI

struct HistoryView: View {
  @ObservedObject var glucoseData: GlucoseData
  @State private var selectedDate = Date()
  
  var body: some View {
    NavigationView {
      VStack {
        // ✅ 캘린더(DatePicker) 추가
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
          .datePickerStyle(GraphicalDatePickerStyle())
          .padding()
        
        List {
          let filteredRecords = glucoseData.records.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
          
          if filteredRecords.isEmpty {
            Text("No records for this date")
              .foregroundColor(.gray)
          } else {
            ForEach(filteredRecords) { record in
              VStack(alignment: .leading) {
                Text("Time: \(formatTime(record.time))")
                Text("Glucose Level: \(record.glucoseLevel) mg/dL")
                Text("Meal Time: \(record.mealTime)")
              }
              .padding()
            }
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
