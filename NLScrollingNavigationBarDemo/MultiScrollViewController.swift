//
//  MultiScrollViewController.swift
//  NLScrollingNavigationBarDemo
//
//  Created by songhailiang on 15/06/2017.
//  Copyright © 2017 hailiang.song. All rights reserved.
//

import UIKit
import NLScrollingNavigationBar

class MultiScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var leftTable: UITableView!
    @IBOutlet weak var rightTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        leftTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        rightTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.title = "Multi ScrollView Demo"
        navigationController?.navigationBar.isTranslucent = false
        
        scrollToIndex(0)
    }

    func scrollToIndex(_ index: Int) {
        if index == 0 {
            navigationController?.nl_followScrollView(leftTable, followers: [], delegate: self)
        } else {
            navigationController?.nl_followScrollView(rightTable, followers: [], delegate: self)
        }
    }
}

extension MultiScrollViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTable {
            return 50
        }
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let table = tableView == leftTable ? "Left" : "Right"
        cell.textLabel?.text = "\(table): Row \(indexPath.row)"
        return cell
    }
}

extension MultiScrollViewController: UITableViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let dIndex = scrollView.contentOffset.x / scrollView.bounds.size.width
            let index = Int(dIndex+0.5)
            
            scrollToIndex(index)
        }
    }
}

extension MultiScrollViewController: NLNavigationBarScrollingDelegate {
    
    func navigationBarDidChangeFrame(delta: CGFloat) {
//        print("navigationBarDidChangeFrame1: \(self.scrollView.frame.size.height)")
//        self.scrollView.frame.size.height -= 2 * delta
//        print("navigationBarDidChangeFrame: \(delta)")
//        print("navigationBarDidChangeFrame2: \(self.scrollView.frame.size.height)")
//        self.scrollView.setNeedsLayout()
//        self.scrollView.layoutIfNeeded()
    }
}
