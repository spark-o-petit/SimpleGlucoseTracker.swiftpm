import SwiftUI
import Charts

struct ReportView: View {
    @ObservedObject var glucoseData: GlucoseData

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ReportSection(title: "Fasting Glucose", color: .blue, mealType: "Fasting", glucoseData: glucoseData)

                    ReportSection(title: "Post-meal Glucose", color: .orange, mealType: "Post-meal", glucoseData: glucoseData)
                }
                .padding()
            }
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
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            let weeklyAverage = get7DayAverage(for: mealType)
            let percentageChange = getPercentageChange(for: mealType)

            HStack {
                Text("7-Day Avg: \(weeklyAverage.value)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(percentageChange.text)
                    .font(.subheadline)
                    .foregroundColor(percentageChange.color)
            }

            if let chartData = getChartData(for: mealType) {
                Chart {
                    ForEach(chartData) { entry in
                        BarMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Glucose Level", entry.glucoseLevel)
                        )
                        .foregroundStyle(color)
                    }

                    if weeklyAverage.rawValue > 0 {
                        RuleMark(y: .value("Weekly Avg", weeklyAverage.rawValue))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundStyle(.gray)
                            .annotation(position: .top, alignment: .trailing) {
                            }
                    }
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

    private func get7DayAverage(for mealTime: String) -> (value: String, rawValue: Double) {
        let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentRecords = glucoseData.records
            .filter { $0.date >= last7Days && $0.date <= Date() }
            .filter { $0.mealTime == mealTime }
            .map { $0.glucoseLevel }

        if recentRecords.isEmpty {
            return ("No data", 0)
        } else {
            let avg = Double(recentRecords.reduce(0, +)) / Double(recentRecords.count)
            return ("\(Int(avg)) mg/dL", avg)
        }
    }

    private func getPercentageChange(for mealTime: String) -> (text: String, color: Color) {
        let last7Days = get7DayAverage(for: mealTime).rawValue
        let previous7Days = getPrevious7DayAverage(for: mealTime)

        guard previous7Days > 0 else { return ("No comparison", .gray) }

        let change = ((last7Days - previous7Days) / previous7Days) * 100
        let roundedChange = round(change * 10) / 10 // 소수점 1자리 반올림

        if change > 0 {
            return ("↑ \(roundedChange)%", .red) // 🔴 증가
        } else if change < 0 {
            return ("↓ \(-roundedChange)%", .green) // 🟢 감소
        } else {
            return ("No change", .gray)
        }
    }

    private func getPrevious7DayAverage(for mealTime: String) -> Double {
        let start = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let end = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let previousRecords = glucoseData.records
            .filter { $0.date >= start && $0.date < end }
            .filter { $0.mealTime == mealTime }
            .map { $0.glucoseLevel }

        if previousRecords.isEmpty {
            return 0
        } else {
            return Double(previousRecords.reduce(0, +)) / Double(previousRecords.count)
        }
    }

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
