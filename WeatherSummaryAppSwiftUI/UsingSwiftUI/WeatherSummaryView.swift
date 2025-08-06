import SwiftUI

struct WeatherSummaryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    // Add your action here
                }) {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .foregroundColor(.white)
                        
                        Text("No Weather Details")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12) // Optional: for nicer rounded corners
                }
            }
            .padding()
            .navigationTitle("Weather Summary") // This shows in the nav bar
        }
    }
}

#Preview {
    WeatherSummaryView()
}

