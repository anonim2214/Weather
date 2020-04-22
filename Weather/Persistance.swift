//
//  Persistance.swift
//  Weather
//
//  Created by Dmitry Moretz on 20.04.2020.
//  Copyright © 2020 Dmitry Moretz. All rights reserved.
//

import Foundation
import RealmSwift

class RCurentWeather: Object {
    @objc dynamic var temp: Double = 0
    @objc dynamic var condition: String = ""
    @objc dynamic var wind_kph: Double = 0
    @objc dynamic var wind_dir: String = ""
    @objc dynamic var vis_km: Double = 0
    @objc dynamic var feelslike: Double = 0
    @objc dynamic var cloud: Double = 0
    @objc dynamic var humidity: Double = 0
    
    
    convenience init(w: CurentWeather) {
        self.init()
        self.temp = w.temp
        self.condition = w.condition
        self.wind_kph = w.wind_kph
        self.wind_dir = w.wind_dir
        self.vis_km = w.vis_km
        self.feelslike = w.feelslike
        self.cloud = w.cloud
        self.humidity = w.humidity
    }
    
    func toBasic() -> CurentWeather {
        return CurentWeather(t: temp, c: condition, wk: wind_kph, wd: wind_dir, vk: vis_km, f: feelslike, cl: cloud, h: humidity)
        
    }
}

class RForecastWeather: Object {
    @objc dynamic var date:Date = Date()
    @objc dynamic var maxTemp: Double = 0
    @objc dynamic var minTemp: Double = 0
    @objc dynamic var avgTemp: Double = 0
    @objc dynamic var condition: String = ""
    @objc dynamic var maxWind_kph: Double = 0
    @objc dynamic var avgVis_km: Double = 0
    @objc dynamic var sunrise: String = ""
    @objc dynamic var sunset: String = ""

    convenience init(w: ForecastWeather) {
        self.init()
        self.date = w.date
        self.maxTemp = w.maxTemp
        self.minTemp = w.minTemp
        self.avgTemp = w.avgTemp
        self.condition = w.condition
        self.maxWind_kph = w.maxWind_kph
        self.avgVis_km = w.avgVis_km
        self.sunrise = w.sunrise
        self.sunset = w.sunset
    }
    
    func toBasic() -> ForecastWeather {
        return ForecastWeather(d: date, max: maxTemp, min: minTemp, avg: avgTemp, c: condition, maxW: maxWind_kph, avgV: avgVis_km, sr: sunrise, ss: sunset)
    }
    
}

class RWeather: Object {
    @objc dynamic var city: String = ""
    @objc dynamic var country: String = ""
    @objc dynamic var currentWeather: RCurentWeather?
    let forecastWeather: List<RForecastWeather> = List<RForecastWeather>()
    
    
    convenience init(w: Weather) {
        self.init()
        self.city = w.city
        self.country = w.country
        self.currentWeather = RCurentWeather(w: w.currentWeather)
        for we in w.forecastWeather {
            forecastWeather.append(RForecastWeather(w: we))
        }
    }
    
    func toBasic() -> Weather {
        var fr: [ForecastWeather] = []
        for fw in forecastWeather {
            fr.append(fw.toBasic())
        }
        return Weather(ci: city, co: country, cur: currentWeather!.toBasic(), f: fr)
    }
    
}

class Persistance {
    static let shared  = Persistance()
    private let realm = try! Realm()
    
    func getCache() -> [Weather] {
        let cache = realm.objects(RWeather.self)
        if cache.count == 0 {
            return []
        }
        return cache.map { ($0 as RWeather).toBasic() }
    }
    
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    func save(data: Weather) {
        let w = RWeather(w: data)
        let c = RCurentWeather(w: data.currentWeather)
        for f in data.forecastWeather {
            let f = RForecastWeather(w:f)
            try! realm.write {
                realm.add(f)
            }
        }
        
        try! realm.write {
            realm.add(w)
            realm.add(c)
        }
    }
}
