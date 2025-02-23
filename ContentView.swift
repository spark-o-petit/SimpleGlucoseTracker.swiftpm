import SwiftUI

struct ContentView: View {
  @State private var selectedDate = Date()
  @State private var selectedTime = Date()
  @State private var bloodGlucose = ""
  @State private var selectedMealTime = "Fasting"
  
  
  let mealTimes = ["Fasting", "After Meal", "Other"]
  
  init() {
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
                .frame(width: 150, height: 150)
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
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
              Text("mg/dL")
                .foregroundColor(.gray)
            }
            
            Picker("Meal Time", selection: $selectedMealTime) {
              ForEach(mealTimes, id: \.self) { mealTime in
                Text(mealTime)
              }
            }
          }
          
        }
        
        Button(action: saveRecord) {
          Text("Save")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
      }
      .navigationTitle("Home")
    }
  }
  
  func getFooterText() -> String {
         switch selectedMealTime {
         case "Fasting":
             return "Target fasting blood glucose: 80-130mg/dL"
         case "After Meal":
             return "Target post-meal blood glucose: <180mg/dL"
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
    : "Please remember to check your blood sugar two hours after your meal this afternoon. It helps us better understand how your body is responding to food."
  }
  
  func saveRecord() {
    print("Blood Glucose Record Saved:")
    print("Date: \(selectedDate)")
    print("Time: \(selectedTime)")
    print("Blood Glucose: \(bloodGlucose) mg/dL")
    print("Meal Time: \(selectedMealTime)")
  }
}

