import Foundation
import CoreLocation

protocol WeatherManagerDelegate: AnyObject {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ weatherManager: WeatherManager, error: Error)
}

class WeatherManager {
    private let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=7002bf0f519521d322ba56723041355b&units=metric"
    weak var delegate: WeatherManagerDelegate?
    var onWeatherUpdate: ((WeatherModel) -> Void)?
    var onError: ((Error) -> Void)?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { [weak self] (data, response, error) in
                if let error = error {
                    self?.onError?(error)
                    
                    self?.delegate?.didFailWithError(self!, error: error)
                    
                    return
                }
                if let safeData = data {
                    if let weather = self?.parseJSON(safeData) {
                        self?.onWeatherUpdate?(weather)
                        
                        self?.delegate?.didUpdateWeather(self!, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            onError?(error)
            
            delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
}
