import Foundation

struct BloodGlucoseRecord: Identifiable {
  let id: UUID
  let date: Date
  let time: Date
  let glucoseLevel: Int
  let mealTime: String
}
