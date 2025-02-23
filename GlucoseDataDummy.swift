import Foundation
import Combine

class GlucoseDataDummy: GlucoseData {
    override init() {
        super.init()
        generateDummyData()
    }

    private func generateDummyData() {
        let calendar = Calendar.current
        let today = Date()

        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                var fastingGlucose: Int
                var postMealGlucose: Int
                
                if i < 7 {
                    fastingGlucose = Int.random(in: 80...130)
                    postMealGlucose = Int.random(in: 110...160)
                } else if i < 14 {
                    fastingGlucose = Int.random(in: 110...150)
                    postMealGlucose = Int.random(in: 140...200)
                } else {
                    fastingGlucose = Int.random(in: 90...140)
                    postMealGlucose = Int.random(in: 120...180)
                }
                
                let fastingTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: date)!
                let postMealTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date)!

                records.append(BloodGlucoseRecord(id: UUID(), date: date, time: fastingTime, glucoseLevel: fastingGlucose, mealTime: "Fasting"))
                records.append(BloodGlucoseRecord(id: UUID(), date: date, time: postMealTime, glucoseLevel: postMealGlucose, mealTime: "Post-meal"))
            }
        }
    }
}
