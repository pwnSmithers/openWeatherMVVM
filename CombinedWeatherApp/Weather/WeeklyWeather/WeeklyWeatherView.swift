

import SwiftUI

struct WeeklyWeatherView: View {
  var body: some View {
    NavigationView {
      VStack {
        NavigationLink(
          "Best weather app :] ⛅️",
          destination: CurrentWeatherView()
        )
      }
    }
  }
}
