
import SwiftUI
import Combine

// 1
class WeeklyWeatherViewModel: ObservableObject, Identifiable {
  // 2
  @Published var city: String = ""

  // 3
  @Published var dataSource: [DailyWeatherRowViewModel] = []

  private let weatherFetcher: WeatherFetchable

  // 4
  private var disposables = Set<AnyCancellable>()

  // 1
  init(
    weatherFetcher: WeatherFetchable,
    scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
  ) {
    self.weatherFetcher = weatherFetcher
    
    // 2
    $city
      // 3
      .dropFirst(1)
      // 4
      .debounce(for: .seconds(0.5), scheduler: scheduler)
      // 5
      .sink(receiveValue: fetchWeather(forCity:))
      // 6
      .store(in: &disposables)
  }

  
  func fetchWeather(forCity city: String) {
    // 1
    weatherFetcher.weeklyWeatherForecast(forCity: city)
      .map { response in
        // 2
        response.list.map(DailyWeatherRowViewModel.init)
      }

      // 3
      .map(Array.removeDuplicates)

      // 4
      .receive(on: DispatchQueue.main)

      // 5
      .sink(
        receiveCompletion: { [weak self] value in
          guard let self = self else { return }
          switch value {
          case .failure:
            // 6
            self.dataSource = []
          case .finished:
            break
          }
        },
        receiveValue: { [weak self] forecast in
          guard let self = self else { return }

          // 7
          self.dataSource = forecast
      })

      // 8
      .store(in: &disposables)
  }
}

extension WeeklyWeatherViewModel {
  var currentWeatherView: some View {
    return WeeklyWeatherBuilder.makeCurrentWeatherView(
      withCity: city,
      weatherFetcher: weatherFetcher
    )
  }
}
