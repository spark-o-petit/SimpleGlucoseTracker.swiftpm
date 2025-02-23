import SwiftUI

class GlucoseData: ObservableObject {
  @Published var records: [BloodGlucoseRecord] = []
}

struct HomeView: View {
  @State private var selectedDate = Date()
  @State private var selectedTime = Date()
  @State private var bloodGlucose = ""
  @State private var selectedMealTime = "Fasting"
  
  @ObservedObject var glucoseData: GlucoseData
  
  let mealTimes = ["Fasting", "After Meal", "Other"]
  
  init(glucoseData: GlucoseData) {
    self.glucoseData = glucoseData
    let hour = Calendar.current.component(.hour, from: Date())
    _selectedMealTime = State(initialValue: hour < 12 ? "Fasting" : "After Meal")
  }
  
  var body: some View {
    NavigationView {
      VStack {
        Form {
          Section {
            VStack {
              Image("glucose_meter")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .padding(.top, 20)
              
              Text(getGreetingMessage())
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
              
              Text(getReminderMessage())
                .font(.caption)
                .multilineTextAlignment(.center)
            }
          }
          
          Section(header: Text("Record Blood Glucose"), footer: Text(getFooterText())) {
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
            DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
            
            HStack {
              Text("Blood Glucose")
                .frame(maxWidth: .infinity, alignment: .leading)
              
              TextField("Enter value", text: $bloodGlucose)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: bloodGlucose) { newValue in
                  validateBloodGlucoseInput(newValue)
                }
              
              Text("mg/dL")
                .foregroundColor(.gray)
              
              if bloodGlucose.isEmpty {
                Image(systemName: "exclamationmark.triangle.fill")
                  .foregroundColor(.gray)
              } else if isBloodGlucoseNormal() {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundColor(.green)
              } else if !isBloodGlucoseNormal() {
                Image(systemName: "exclamationmark.triangle.fill")
                  .foregroundColor(.yellow)
              }
            }
            
            Picker("Meal Time", selection: $selectedMealTime) {
              ForEach(mealTimes, id: \.self) { mealTime in
                Text(mealTime)
              }
            }
          }
        }
        Button(action: saveRecord) {
          HStack {
            Image(systemName: "plus.circle.fill")
              .foregroundColor(.white)
            Text("Record")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(bloodGlucose.isEmpty ? Color.gray : Color.blue)
          .foregroundColor(.white)
          .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .disabled(bloodGlucose.isEmpty)      }
      .navigationTitle("Home")
    }
  }
  
  
  func isBloodGlucoseNormal() -> Bool {
    guard let glucoseValue = Int(bloodGlucose) else { return false }
    
    switch selectedMealTime {
    case "Fasting":
      return glucoseValue >= 80 && glucoseValue <= 130
    case "After Meal":
      return glucoseValue >= 100 && glucoseValue < 180
    default:
      return false
    }
  }
  
  func validateBloodGlucoseInput(_ newValue: String) {
    let filteredValue = newValue.filter { "0123456789".contains($0) }
    
    if let intValue = Int(filteredValue) {
      if intValue > 1000 {
        bloodGlucose = "1000"
      } else {
        bloodGlucose = filteredValue
      }
    } else {
      bloodGlucose = ""
    }
  }
  
  
  func getFooterText() -> String {
    switch selectedMealTime {
    case "Fasting":
      return "Target fasting blood glucose: 80-130mg/dL (American Diabetes Association)"
    case "After Meal":
      return "Target post-meal blood glucose: < 180mg/dL (American Diabetes Association)"
    default:
      return "Maintain a healthy blood glucose level for overall well-being."
    }
  }
  
  func getGreetingMessage() -> String {
    let hour = Calendar.current.component(.hour, from: Date())
    return hour < 12 ? "Good Morning,\nLet's check fasting glucose level"
    : "Good Afternoon,\nHave you checked your glucose today?"
  }
  
  func getReminderMessage() -> String {
    let hour = Calendar.current.component(.hour, from: Date())
    return hour < 12
    ? "Please remember to check your fasting blood sugar in the morning before eating or drinking anything. It’s important for monitoring your health effectively."
    : "Monitoring your glucose levels throughout the day is crucial. Make sure to record your post-meal readings for better tracking."
  }
  
  func saveRecord() {
    guard let glucoseValue = Int(bloodGlucose) else { return }
    
    let newRecord = BloodGlucoseRecord(
      id: UUID(),
      date: selectedDate,
      time: selectedTime,
      glucoseLevel: glucoseValue,
      mealTime: selectedMealTime
    )
    
    glucoseData.records.append(newRecord)
    bloodGlucose = ""
  }
}
