import SwiftUI

struct HistoryView: View {
    @State private var selectedDate = Date()
    @State private var bloodGlucoseRecords: [String: [String]] = [
        "2024-02-24": ["Fasting: 95 mg/dL", "After Meal: 140 mg/dL"],
        "2024-02-23": ["Fasting: 100 mg/dL", "After Meal: 160 mg/dL"]
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // ✅ 캘린더(DatePicker) 추가
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                // ✅ 선택한 날짜에 대한 기록 표시
                List {
                    let dateKey = formatDate(selectedDate)
                    if let records = bloodGlucoseRecords[dateKey] {
                        ForEach(records, id: \.self) { record in
                            Text(record)
                        }
                    } else {
                        Text("No records for this date")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
