//
//  ViewController.swift
//  Weather
//
//  Created by Dmitry Moretz on 30.03.2020.
//  Copyright © 2020 Dmitry Moretz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var isAlamofire: UISwitch!
    @IBOutlet weak var firstTable: UITableView!
    var weather: [Weather] = []
    var w: WeatherLoader?
    var timer: Timer?
    var cities: [String] = ["Moscow"]
    override func viewDidLoad() {
        super.viewDidLoad()
        w = WeatherLoader()
        
        let cache = Persistance.shared.getCache()
        
        if cache.count > 0 {
            cities.removeAll()
            for c in cache{
                cities.append(c.city)
                self.weather.append(c)
            }
            firstTable.reloadData()
        }
        reData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewController1 {
            vc.delegate = self
        }
    }
    func reData() {
        //Вставил дилей что бы успеть посмотреть кэшированные данные
        if timer == nil {
          timer = Timer.scheduledTimer(timeInterval: 10.0,
                                       target: self,
                                       selector: #selector(reData1),
                                       userInfo: nil,
                                       repeats: false)
        }
    }
    @IBAction func onAlamofireChanged(_ sender: Any) {
        reData()
    }
    
    @objc func reData1() {
        Persistance.shared.deleteAll()
        weather.removeAll()
        for city in cities {
            w!.loadWeather(isAlamofire.isOn,city: city,completition: { weather in
                
                self.weather.append(weather)
                self.firstTable.reloadData()
                DispatchQueue.main.async {
                     Persistance.shared.save(data: weather)
                }
            })
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == firstTable {
            if let header = tableView.dequeueReusableCell(withIdentifier: "header" ) as? TableViewCell{
                header.city.text = weather[section].city
                header.country.text = weather[section].country
                header.backgroundColor = .red
                return header
            }
        } else {
            if let header = tableView.dequeueReusableCell(withIdentifier: "insideCell") as? TableViewCell2{
                guard let table = tableView as? Table else {
                    return header
                }
                if (table.weatherIndex == 0) {
                    header.text1.text = "Сейчас"
                    header.text2.text = ""
                    header.backgroundColor = .green
                } else {
                    header.text1.text = ""
                    header.text2.text = weather[table.cityIndex!].forecastWeather[table.weatherIndex! - 1].date.toString()
                    header.backgroundColor = .yellow
                }

                return header
            }
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 20
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == firstTable {
            return weather[section].forecastWeather.count + 1
        } else {
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == firstTable {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableCellWithTable,
                let table = cell.table{
                table.cityIndex = indexPath.section
                table.weatherIndex = indexPath.row
                return cell
            }
        }
        else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "insideCell", for: indexPath) as? TableViewCell2,
                let table = tableView as? Table {
                if table.weatherIndex == 0 {
                    cell.text1.text = weather[table.cityIndex!].currentWeather.getKeyByIndex(indexPath.row)
                    cell.text2.text = weather[table.cityIndex!].currentWeather.getValueByIndex(indexPath.row)
                } else {
                    cell.text1.text = weather[table.cityIndex!].forecastWeather[table.weatherIndex! - 1].getKeyByIndex(indexPath.row)
                    cell.text2.text = weather[table.cityIndex!].forecastWeather[table.weatherIndex! - 1].getValueByIndex(indexPath.row)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == firstTable {
            return weather.count
        }
        else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == firstTable {
            return 9 * 20
        } else {
            return 20
        }
    }
    
}

extension ViewController: ViewController1Delegate {
    func selectedData(data: [String]) {
        cities = data
        reData()
    }
}
