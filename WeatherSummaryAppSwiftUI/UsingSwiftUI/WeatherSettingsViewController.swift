

import SwiftUI

struct WeatherSettingsViewController: View {
    @State var colour = UIColor(red:0.5, green:0.5, blue:0.5, alpha:1.0)
    @State var description = ""
    @State var selectedIcon = 0
    @State var selectedColour = 0

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Description")
                TextField("Please enter a description", text: $description)
                
                Text("Icon")
                Picker(selection: $selectedIcon, label: Text("Icon")) {
                    Text("Sun").tag(0)
                    Text("Cloud").tag(1)
                    Text("Lightning").tag(2)
                    Text("Rain").tag(3)
                    Text("Snow").tag(4)
                }
                .pickerStyle(.segmented)
                
                Color(colour).frame(height: 30.0)
                
                Spacer()
                
                NavigationLink(destination: WeatherSummaryView()) {
                    Text("Show Weather Summary")
                }
                .padding()
                
            }
            .padding()
            .navigationTitle("Weather Settings")
        }

    }
}

#Preview {
    WeatherSettingsViewController()
}
