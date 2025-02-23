import SwiftUI

struct ContentView: View {
  @State private var selectedDate = Date()
  @State private var selectedTime = Date()
  @State private var bloodGlucose = ""
  @State private var selectedMealTime = "Fasting"
  
  
  let mealTimes = ["Fasting", "After Meal", "Other"]
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
                .padding(.top, 10)
              
              Text("Good Morning,\nLet's check fasting glucose level")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
              
              Text("Please remember to check your fasting blood sugar in the morning before eating or drinking anything. It’s important for monitoring your health effectively")
                .font(.caption)
                .multilineTextAlignment(.center)
            }
          }
          
          // ✅ 기존의 혈당 기록 입력 필드 유지
          Section(header: Text("Record Blood Glucose")) {
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
        .padding(.horizontal) // 좌우 패딩 유지
        .padding(.vertical, 10) // 버튼과 Form 간격 조정
      }
      .navigationTitle("Home")
    }
  }
  
  func saveRecord() {
    // 저장 로직 추가 가능 (예: UserDefaults, CoreData, Firebase 등)
    print("Blood Glucose Record Saved:")
    print("Date: \(selectedDate)")
    print("Time: \(selectedTime)")
    print("Blood Glucose: \(bloodGlucose) mg/dL")
    print("Meal Time: \(selectedMealTime)")
  }
}

