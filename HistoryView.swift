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

        List {
          Section(header: Text("Summary").font(.headline)) {
            summaryView()
          }

          let filteredRecords = glucoseData.records
            .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date > $1.date }

          if filteredRecords.isEmpty {
            Text("No records for this date")
              .foregroundColor(.gray)
          } else {
            Section(header: Text("Detailed Info").font(.headline)) {
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
      }
      .navigationTitle("History")
    }
  }

  private func summaryView() -> some View {
    let fastingToday = getGlucoseAverage(for: "Fasting", on: selectedDate)
    let fastingYesterday = getGlucoseAverage(for: "Fasting", on: Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!)
    let fastingChange = calculatePercentageChange(today: fastingToday.rawValue, yesterday: fastingYesterday.rawValue)

    let postMealToday = getGlucoseAverage(for: "Post-meal", on: selectedDate)
    let postMealYesterday = getGlucoseAverage(for: "Post-meal", on: Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!)
    let postMealChange = calculatePercentageChange(today: postMealToday.rawValue, yesterday: postMealYesterday.rawValue)

    return VStack {
      HStack {
        VStack {
          Text("Fasting Glucose")
            .font(.caption)
            .foregroundColor(.gray)
          Text(fastingToday.value)
            .font(.headline)
          Text(fastingChange.text)
            .font(.caption)
            .foregroundColor(fastingChange.color)
        }
        .frame(maxWidth: .infinity)
        
        VStack {
          Text("Post-meal Glucose")
            .font(.caption)
            .foregroundColor(.gray)
          Text(postMealToday.value)
            .font(.headline)
          Text(postMealChange.text)
            .font(.caption)
            .foregroundColor(postMealChange.color)
        }
        .frame(maxWidth: .infinity)
      }
      .padding()
    }
  }

  private func getGlucoseAverage(for mealType: String, on date: Date) -> (value: String, rawValue: Double) {
    let records = glucoseData.records
      .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
      .filter { $0.mealTime == mealType }
      .map { $0.glucoseLevel }

    if records.isEmpty {
      return ("No data", 0)
    } else {
      let avg = Double(records.reduce(0, +)) / Double(records.count)
      return ("\(Int(avg)) mg/dL", avg)
    }
  }

  private func calculatePercentageChange(today: Double, yesterday: Double) -> (text: String, color: Color) {
    guard yesterday > 0 else { return ("No comparison", .gray) }

    let change = ((today - yesterday) / yesterday) * 100
    let roundedChange = round(change * 10) / 10 

    if change > 0 {
      return ("↑ \(roundedChange)%", .orange)
    } else if change < 0 {
      return ("↓ \(-roundedChange)%", .blue)
    } else {
      return ("No change", .gray)
    }
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
