import Foundation

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeather(_ weatherViewModel: WeatherViewModel, weather: WeatherModel)
    func didFailWithError(_ weatherViewModel: WeatherViewModel, error: Error)
}

class WeatherViewModel {
    private let weatherManager = WeatherManager()
    weak var delegate: WeatherViewModelDelegate?
    var onWeatherUpdate: ((WeatherModel) -> Void)?
    var onError: ((Error) -> Void)?

    init() {
        weatherManager.delegate = self
        weatherManager.onWeatherUpdate = { [weak self] weather in
            guard let self = self else { return }
            self.onWeatherUpdate?(weather)
        }
        weatherManager.onError = { [weak self] error in
            self?.onError?(error)
        }
    }
    func fetchWeather(cityName: String) {
        weatherManager.fetchWeather(cityName: cityName)
    }
    func fetchWeather(latitude: Double, longitude: Double) {
        weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
    }
}
extension WeatherViewModel: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        delegate?.didUpdateWeather(self, weather: weather)
    }
    func didFailWithError(_ weatherManager: WeatherManager, error: Error) {
        delegate?.didFailWithError(self, error: error)
    }
}
