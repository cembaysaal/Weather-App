import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var viewModel = WeatherViewModel()
    let locationManager = CLLocationManager()
    let weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        viewModel.onWeatherUpdate = { [weak self] weather in
            DispatchQueue.main.async {
                self?.updateUI(with: weather)
            }
        }
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.handleError(error)
            }
        }
        searchTextField.delegate = self
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            viewModel.fetchWeather(cityName: city)
        }
        searchTextField.text = ""
    }
    // MARK: - UI Updates
    private func updateUI(with weather: WeatherModel) {
        temperatureLabel.text = weather.temperatureString
        conditionImageView.image = UIImage(systemName: weather.conditionName)
        cityLabel.text = weather.cityName
    }
    
    private func handleError(_ error: Error) {
        print(error)
    }
}
extension WeatherViewController: UITextFieldDelegate {
}
extension WeatherViewController: CLLocationManagerDelegate {
    
     @IBAction func locationPressed(_ sender: UIButton) {
         locationManager.requestLocation()
     }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon) 
        }
    }
    
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print(error)
     }
}
