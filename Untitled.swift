
import SwiftUI
import Charts

struct ReportView: View {
    @ObservedObject var glucoseData: GlucoseData
    @State private var selectedFilter: String = "Fasting"

    let filterOptions = ["Fasting", "Post-meal"]

    var body: some View {
        NavigationView {
            VStack {
                // ✅ 필터 선택 (Fasting / Post-meal)
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filterOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // ✅ 최근 7일간 막대 그래프
                if let chartData = getChartData() {
                    Chart(chartData) {
                        BarMark(
                            x: .value("Date", $0.date, unit: .day),
                            y: .value("Glucose Level", $0.glucoseLevel)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 250)
                    .padding()
                } else {
                    Text("No data available for the last 7 days")
                        .foregroundColor(.gray)
                        .padding()
                }

                // ✅ 최근 7일 평균 변화율 표시
                let changePercentage = getPercentageChange()
                Text("Last 7 days vs. Previous 7 days: \(changePercentage)%")
                    .font(.headline)
                    .foregroundColor(changePercentage > 0 ? .red : .green)
                    .padding()
            }
            .navigationTitle("Report")
        }
    }

    // ✅ 최근 7일간 데이터를 막대 그래프로 표시
    private func getChartData() -> [GlucoseEntry]? {
        let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let filteredRecords = glucoseData.records
            .filter { $0.date >= last7Days && $0.mealTime == selectedFilter }
            .sorted { $0.date < $1.date }

        if filteredRecords.isEmpty { return nil }
        
        return filteredRecords.map { GlucoseEntry(date: $0.date, glucoseLevel: $0.glucoseLevel) }
    }

    // ✅ 최근 7일 평균과 이전 7일 평균 비교하여 변화율 계산
    private func getPercentageChange() -> Double {
        let today = Date()
        let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        let previous7Days = Calendar.current.date(byAdding: .day, value: -14, to: today)!

        let last7DaysAvg = getAverage(from: last7Days, to: today)
        let previous7DaysAvg = getAverage(from: previous7Days, to: last7Days)

        guard previous7DaysAvg > 0 else { return 0 }

        let change = ((last7DaysAvg - previous7DaysAvg) / previous7DaysAvg) * 100
        return round(change * 100) / 100 // 소수점 2자리까지 표시
    }

    // ✅ 주어진 기간 동안의 평균 혈당 계산
    private func getAverage(from startDate: Date, to endDate: Date) -> Double {
        let filteredRecords = glucoseData.records
            .filter { $0.date >= startDate && $0.date < endDate && $0.mealTime == selectedFilter }
            .map { $0.glucoseLevel }

        guard !filteredRecords.isEmpty else { return 0 }
        
        return Double(filteredRecords.reduce(0, +)) / Double(filteredRecords.count)
    }
}

// ✅ 차트 데이터 모델
struct GlucoseEntry: Identifiable {
    let id = UUID()
    let date: Date
    let glucoseLevel: Int
}
