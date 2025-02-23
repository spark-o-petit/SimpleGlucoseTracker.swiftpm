import SwiftUI

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @ObservedObject var glucoseData: GlucoseData
    @Binding var selectedFilter: String

    private let calendar = Calendar.current
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack {
            Text(getFormattedMonthYear(date: selectedDate))
                .font(.title2)
                .padding()

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(getDaysInMonth(), id: \.self) { day in
                    let currentDate = getDate(for: day)
                    let color = getDotColor(for: currentDate)

                    ZStack(alignment: .topTrailing) {
                        Text("\(day)")
                            .font(.headline)
                            .frame(width: 35, height: 35)
                            .background(isSameDay(date1: selectedDate, date2: currentDate) ? Color.blue.opacity(0.3) : Color.clear)
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedDate = currentDate
                            }

                        if color != .clear {
                            Circle()
                                .fill(color)
                                .frame(width: 6, height: 6)
                                .offset(x: 10, y: -5) // ✅ 날짜의 우상단에 점 배치
                        }
                    }
                }
            }
            .padding()
        }
    }

    // ✅ 날짜별 혈당 이상 여부에 따라 점 색상 결정
    private func getDotColor(for date: Date) -> Color {
        let recordsForDate = glucoseData.records.filter { calendar.isDate($0.date, inSameDayAs: date) }

        if recordsForDate.isEmpty { return .clear }

        var hasAbnormalData = false

        for record in recordsForDate {
            switch selectedFilter {
            case "Fasting":
                if isFastingAbnormal(record) { hasAbnormalData = true; return .red }
            case "After Meal":
                if isAfterMealAbnormal(record) { hasAbnormalData = true; return .orange }
            case "Other":
                if isOtherAbnormal(record) { hasAbnormalData = true; return .purple }
            default:
                return .clear
            }
        }

        return hasAbnormalData ? .clear : .gray
    }

    private func isFastingAbnormal(_ record: BloodGlucoseRecord) -> Bool {
        return record.mealTime == "Fasting" && (record.glucoseLevel < 80 || record.glucoseLevel > 130)
    }

    private func isAfterMealAbnormal(_ record: BloodGlucoseRecord) -> Bool {
        return record.mealTime == "After Meal" && record.glucoseLevel >= 180
    }

    private func isOtherAbnormal(_ record: BloodGlucoseRecord) -> Bool {
        return record.mealTime == "Other" && (record.glucoseLevel < 70 || record.glucoseLevel > 200)
    }

    private func getDaysInMonth() -> [Int] {
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        return Array(range)
    }

    private func getDate(for day: Int) -> Date {
        return calendar.date(bySetting: .day, value: day, of: selectedDate)!
    }

    private func isSameDay(date1: Date, date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    private func getFormattedMonthYear(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
