//
//  ViewController1.swift
//  Weather
//
//  Created by Dmitry Moretz on 01.04.2020.
//  Copyright © 2020 Dmitry Moretz. All rights reserved.
//

import UIKit
protocol ViewController1Delegate {
    func selectedData(data: [String])
}

class ViewController1: UIViewController {
    @IBOutlet weak var table: UITableView!
    var cities: [String] = ["Moscow", "Saint_Petersburg", "Voronezh", "Krasnodar", "Sochi"]
    var delegate: ViewController1Delegate?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var retV: [String] = []
        for cell in table.visibleCells as! [TableViewCell3] {
            if cell.accessoryType == .checkmark {
                retV.append(cell.title.text!)
            }
        }
        delegate?.selectedData(data: retV)
    }
}

extension ViewController1: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell3
        cell.title.text = cities[indexPath.row]
        return cell
        
    }
    
    
}
