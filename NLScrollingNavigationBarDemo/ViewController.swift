//
//  ViewController.swift
//  NLScrollingNavigationBarDemo
//
//  Created by songhailiang on 09/06/2017.
//  Copyright © 2017 hailiang.song. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    
    let demos = ["ScrollView", "MultiScrollView"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.title = "NLScrollingNavigationBar"
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = demos[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let demo = demos[indexPath.row]
        
        performSegue(withIdentifier: demo, sender: nil)
    }
}

