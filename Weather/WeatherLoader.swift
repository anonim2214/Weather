import Foundation
import Alamofire
struct CurentWeather {
    init?(_ json:NSDictionary) {
        guard let temp = json["temp_c"] as? Double,
        let condition = json["condition"] as? NSDictionary,
        let condition_text = condition["text"] as? String,
        let wind_kph = json["wind_kph"] as? Double,
        let wind_dir = json["wind_dir"] as? String,
        let vis_km = json["vis_km"] as? Double,
        let feelslike = json["feelslike_c"] as? Double,
        let cloud = json["cloud"] as? Double,
        let humidity = json["humidity"] as? Double else {
                return nil
        }
        self.temp = temp
        self.condition = condition_text
        self.wind_dir = wind_dir
        self.wind_kph = wind_kph
        self.vis_km = vis_km
        self.feelslike = feelslike
        self.cloud = cloud
        self.humidity = humidity
    }
    init(t: Double, c: String, wk: Double, wd: String, vk: Double, f:Double, cl: Double, h: Double) {
        temp = t
        condition = c
        wind_dir = wd
        wind_kph = wk
        vis_km = vk
        feelslike = f
        cloud = cl
        humidity = h
    }
    
    func getKeyByIndex(_ index: Int) -> String {
        switch index {
        case 0: return "Температура"
        case 1: return "Состояние"
        case 2: return "Скорость ветра"
        case 3: return "Направление ветра"
        case 4: return "Видимость"
        case 5: return "Ощущается"
        case 6: return "Облачность"
        case 7: return "Влажность"
        default: return ""
        }
    }
    
    func getValueByIndex(_ index: Int) -> String {
        switch index {
        case 0: return "\(temp) C"
        case 1: return condition
        case 2: return "\(wind_kph) км/ч"
        case 3: return wind_dir
        case 4: return "\(vis_km) км"
        case 5: return "\(feelslike) C"
        case 6: return "\(cloud) %"
        case 7: return "\(humidity) %"
        default: return ""
        }
    }
    let temp: Double
    let condition: String
    let wind_kph: Double
    let wind_dir: String
    let vis_km: Double
    let feelslike: Double
    let cloud: Double
    let humidity: Double
}

struct ForecastWeather {
    init?(_ json:NSDictionary) {
        guard let date = json["date"] as? String,
            let day = json["day"] as? NSDictionary,
            let maxTemp = day["maxtemp_c"] as? Double,
            let minTemp = day["mintemp_c"] as? Double,
            let avgTemp = day["avgtemp_c"] as? Double,
            let condition = day["condition"] as? NSDictionary,
            let condition_text = condition["text"] as? String,
            let maxWind_kph = day["maxwind_kph"] as? Double,
            let avgVis_km = day["avgvis_km"] as? Double,
            let astro = json["astro"] as? NSDictionary,
            let sunrise = astro["sunrise"] as? String,
            let sunset = astro["sunset"] as? String else {
                return nil
        }
        
        self.date = date.toDate()!
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.avgTemp = avgTemp
        self.condition = condition_text
        self.maxWind_kph = maxWind_kph
        self.avgVis_km = avgVis_km
        self.sunrise = sunrise
        self.sunset = sunset
    }
    init(d: Date, max: Double, min: Double, avg:Double, c: String, maxW: Double, avgV: Double, sr: String, ss: String) {
        date = d
        maxTemp = max
        minTemp = min
        avgTemp = avg
        condition = c
        maxWind_kph = maxW
        avgVis_km = avgV
        sunrise = sr
        sunset = ss
        
    }
    func getKeyByIndex(_ index: Int) -> String {
        switch index {
        case 0: return "Макс температура"
        case 1: return "Мин температура"
        case 2: return "Средняя температура"
        case 3: return "Состояние"
        case 4: return "Макc скорость ветра"
        case 5: return "Среднаяя видимость"
        case 6: return "Восход солнца"
        case 7: return "Заход солнца"
        case 8: return "Дата"
        default: return ""
        }
    }
    
    func getValueByIndex(_ index: Int) -> String {
        switch index {
        case 0: return "\(maxTemp) C"
        case 1: return "\(minTemp) C"
        case 2: return "\(avgTemp) C"
        case 3: return condition
        case 4: return "\(maxWind_kph) км/ч"
        case 5: return "\(avgVis_km) км"
        case 6: return sunrise
        case 7: return sunset
        case 8: return "\(date.toString())"
        default: return ""
        }
    }
    
    let date:Date
    let maxTemp: Double
    let minTemp: Double
    let avgTemp: Double
    let condition: String
    let maxWind_kph: Double
    let avgVis_km: Double
    let sunrise: String
    let sunset: String
}

struct Weather {
    init? (_ json: NSDictionary) {
        guard let location = json["location"] as? NSDictionary,
            let city = location["name"] as? String,
            let country = location["country"] as? String,
            let forecast = json["forecast"] as? NSDictionary,
            let forecastday = forecast["forecastday"] as? [NSDictionary],
            let currentWeather = json["current"] as? NSDictionary else {
                return nil
        }
        guard let cW = CurentWeather(currentWeather) else {
            return nil
        }
        self.forecastWeather = []
        for f in forecastday {
            guard let cf = ForecastWeather(f) else {
                return nil
            }
            self.forecastWeather.append(cf)
        }
        self.city = city
        self.country = country
        self.currentWeather = cW
    }
    init(ci: String, co: String, cur: CurentWeather, f: [ForecastWeather]) {
        city = ci
        country = co
        currentWeather = cur
        forecastWeather = f
    }
    let city: String
    let country: String
    let currentWeather: CurentWeather
    var forecastWeather: [ForecastWeather]
    
}

class WeatherLoader {
    func loadWeather(_ isAlamofire: Bool, city: String, completition: @escaping (Weather) -> Void) {
        if(isAlamofire) {
            loadWeather2(city: city, completition: completition)
        } else {
            loadWeather1(city: city, completition: completition)
        }

    }
    func loadWeather1(city: String, completition: @escaping (Weather) -> Void) {
        let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=3200870425f54efcbd965216203103&q=\(city)&days=5&lang=ru")!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let jsonDict = json as? NSDictionary,
                let w = Weather(jsonDict){
                DispatchQueue.main.async {
                        completition(w)
                }
            }
        }
        task.resume()
    }
    func loadWeather2(city: String, completition: @escaping (Weather) -> Void) {
        Alamofire.request("https://api.weatherapi.com/v1/forecast.json?key=3200870425f54efcbd965216203103&q=\(city)&days=5&lang=ru").responseJSON(completionHandler:
            { response in
                if let json = response.result.value,
                    let jsonDict = json as? NSDictionary,
                    let w = Weather(jsonDict){
                    DispatchQueue.main.async {
                        completition(w)
                    }
                }
                
        })
    }
}

extension String {

    func toDate(withFormat format: String = "yyyy-MM-dd")-> Date?{

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.locale = Locale(identifier: "ru-RU")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)

        return date

    }
}
extension Date {

    func toString(withFormat format: String = "yyyy.MM.dd") -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru-RU")
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)

        return str
    }
}
