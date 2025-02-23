import SwiftUI

struct HistoryView: View {
  @ObservedObject var glucoseData: GlucoseData
  @State private var selectedDate = Date()
  
  var body: some View {
    NavigationView {
      VStack {
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
          .datePickerStyle(GraphicalDatePickerStyle())
          .padding()
        
        summaryView()
        
        List {
          let filteredRecords = glucoseData.records
            .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date > $1.date }
          
          if filteredRecords.isEmpty {
            Text("No records for this date")
              .foregroundColor(.gray)
          } else {
            ForEach(filteredRecords) { record in
              VStack(alignment: .leading) {
                HStack {
                  Text(formatTime(record.time))
                    .foregroundStyle(.gray)
                  Text(record.mealTime)
                    .padding(.leading, 5)
                  Spacer()
                  Text("\(record.glucoseLevel) mg/dL")
                    .foregroundColor(getGlucoseLevelColor(record))
                }
              }
              .padding(.vertical, 5)
            }
          }
        }
      }
      .navigationTitle("History")
    }
  }
  
  private func summaryView() -> some View {
    let filteredRecords = glucoseData.records.filter {
      Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
    }
    
    let fastingValues = filteredRecords
      .filter { $0.mealTime == "Fasting" }
      .map { $0.glucoseLevel }
    
    let afterMealValues = filteredRecords
      .filter { $0.mealTime == "After Meal" }
      .map { $0.glucoseLevel }
    
    let fastingAverage = fastingValues.isEmpty ? "No data" : "\(fastingValues.reduce(0, +) / fastingValues.count) mg/dL"
    let afterMealAverage = afterMealValues.isEmpty ? "No data" : "\(afterMealValues.reduce(0, +) / afterMealValues.count) mg/dL"
    
    return HStack {
      VStack {
        Text("Fasting")
          .font(.caption)
          .foregroundColor(.gray)
        Text(fastingAverage)
          .font(.headline)
      }
      .frame(maxWidth: .infinity)
      
      VStack {
        Text("After Meal")
          .font(.caption)
          .foregroundColor(.gray)
        Text(afterMealAverage)
          .font(.headline)
      }
      .frame(maxWidth: .infinity)
    }
    .padding()
  }
  
  func getGlucoseLevelColor(_ record: BloodGlucoseRecord) -> Color {
    if (record.mealTime == "Fasting" && (record.glucoseLevel < 80 || record.glucoseLevel > 130)) ||
        (record.mealTime == "After Meal" && record.glucoseLevel >= 180) ||
        (record.mealTime == "Other" && (record.glucoseLevel < 70 || record.glucoseLevel > 200)) {
      return .orange
    }
    return .primary
  }
  
  func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
