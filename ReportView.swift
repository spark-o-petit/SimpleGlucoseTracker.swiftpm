import SwiftUI
import Charts

struct ReportView: View {
    @ObservedObject var glucoseData: GlucoseData

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // ✅ Fasting Glucose Section
                ReportSection(title: "Fasting Glucose (Last 7 days)", color: .blue, mealType: "Fasting", glucoseData: glucoseData)
              
              Spacer()

                // ✅ Post-meal Glucose Section
                ReportSection(title: "Post-meal Glucose (Last 7 days)", color: .orange, mealType: "Post-meal", glucoseData: glucoseData)
            }
            .padding()
            .navigationTitle("Report")
        }
    }
}

struct ReportSection: View {
    let title: String
    let color: Color
    let mealType: String
    @ObservedObject var glucoseData: GlucoseData

    var body: some View {
        VStack {
            // ✅ Section Title
            Text(title)
                .font(.headline)
                .padding(.top, 10)

            // ✅ 지난주 대비 % 변화 표시
            let change = getPercentageChange(for: mealType)
            Text(percentageChangeText(percentage: change))
                .font(.subheadline)
                .foregroundColor(percentageChangeColor(percentage: change))

            // ✅ 최근 7일간 혈당 차트
            if let chartData = getChartData(for: mealType) {
                Chart(chartData) {
                    BarMark(
                        x: .value("Date", $0.date, unit: .day),
                        y: .value("Glucose Level", $0.glucoseLevel)
                    )
                    .foregroundStyle(color)
                }
                .frame(height: 200)
                .padding(.horizontal)
            } else {
                Text("No data available for the last 7 days")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    // ✅ 최근 7일 평균 대비 변화율 계산
    private func getPercentageChange(for mealType: String) -> Double? {
        let today = Date()
        let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        let previous7Days = Calendar.current.date(byAdding: .day, value: -14, to: today)!

        let last7DaysAvg = getAverage(from: last7Days, to: today, for: mealType)
        let previous7DaysAvg = getAverage(from: previous7Days, to: last7Days, for: mealType)

        guard previous7DaysAvg > 0 else { return nil } // ✅ 이전 데이터가 없으면 nil 반환

        return round(((last7DaysAvg - previous7DaysAvg) / previous7DaysAvg) * 100 * 100) / 100
    }

    // ✅ 주어진 기간 동안의 평균 혈당 계산
    private func getAverage(from startDate: Date, to endDate: Date, for mealType: String) -> Double {
        let filteredRecords = glucoseData.records
            .filter { Calendar.current.compare($0.date, to: startDate, toGranularity: .day) != .orderedAscending &&
                      Calendar.current.compare($0.date, to: endDate, toGranularity: .day) == .orderedAscending }
            .filter { $0.mealTime == mealType }
            .map { $0.glucoseLevel }

        return filteredRecords.isEmpty ? 0 : Double(filteredRecords.reduce(0, +)) / Double(filteredRecords.count)
    }

    // ✅ 변화율 텍스트 반환
    private func percentageChangeText(percentage: Double?) -> String {
        guard let percentage = percentage else { return "No comparison available" }
        return percentage > 0 ? "Increased by \(percentage)%" : "Decreased by \(-percentage)%"
    }

    // ✅ 변화율에 따른 색상 반환 (🔴 증가, 🟢 감소)
    private func percentageChangeColor(percentage: Double?) -> Color {
        guard let percentage = percentage else { return .gray }
      return percentage > 0 ? .orange : .blue
    }

    // ✅ 최근 7일간 데이터를 막대 그래프로 표시
    private func getChartData(for mealType: String) -> [GlucoseEntry]? {
        let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let filteredRecords = glucoseData.records
            .filter { Calendar.current.isDate($0.date, equalTo: last7Days, toGranularity: .day) || $0.date > last7Days }
            .filter { $0.mealTime == mealType }
            .sorted { $0.date < $1.date }

        return filteredRecords.isEmpty ? nil : filteredRecords.map { GlucoseEntry(date: $0.date, glucoseLevel: $0.glucoseLevel) }
    }
}

// ✅ 차트 데이터 모델
struct GlucoseEntry: Identifiable {
    let id = UUID()
    let date: Date
    let glucoseLevel: Int
}
