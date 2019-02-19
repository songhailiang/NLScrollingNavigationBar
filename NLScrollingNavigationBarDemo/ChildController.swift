//
//  ChildController.swift
//  NLScrollingNavigationBarDemo
//
//  Created by songhailiang on 10/08/2017.
//  Copyright © 2017 hailiang.song. All rights reserved.
//

import UIKit

class ChildController: UIViewController {

    var tableController: TableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false

        // Do any additional setup after loading the view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        tableController = sb.instantiateViewController(withIdentifier: "TableViewController") as? TableViewController
        
        view.addSubview(tableController!.view)
        
        tableController?.view.nl_equalTop(toView: self.view)
        tableController?.view.nl_equalLeft(toView: self.view)
        tableController?.view.nl_equalRight(toView: self.view)
        tableController?.view.nl_equalBottom(toView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.nl_followScrollView(tableController!.table)
    }

}
