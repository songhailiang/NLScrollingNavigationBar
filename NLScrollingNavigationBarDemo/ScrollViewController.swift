//
//  ScrollViewController.swift
//  NLScrollingNavigationBarDemo
//
//  Created by songhailiang on 09/06/2017.
//  Copyright © 2017 hailiang.song. All rights reserved.
//

import UIKit
import NLScrollingNavigationBar

class ScrollViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        label.text = "It's all in motion\nNo stoppin' now\nI've got nothin' to lose\nAnd only one way up\n\nI'm burning bridges\nI destroy the mirage\nOh, visions of collisions\nFuckin 'bon voyage\n\nIt's all smooth sailing\nFrom here on out\n\nI got bruises and hickies\nStitches and scars\nGot my own theme music\nIt plays wherever I are\n\nFear is the hand \nThat pulls your strings\nA useless toy\nPitiful plaything\n\nI'm inflagranti\nIn every way\n\nIt's all smooth sailing\nFrom here on out\nI'm gon' do the damage\nThat needs gettin' done\n\nGod only knows\nWhere love vacations\nIf reason is priceless\nThere's no reason to pay for it\n\nIt's so easy to see\nAnd so hard to find\nMake a mountain of a mole hill\nIf the mole hill is mine\n\nI hypnotize you\nAnd no one can find you\nI blow my load\nOver the status quo\nHere we go\n\nI'm a little bit nonchalant \nBut I dance\nI'm risking it always\nNo second chance\n\nIt's gonna be smooth sailing\nFrom here on out\nI'm gon' do the damage\n'Til the damage is done yeah\n\nGod only knows\nSo mind your behavior\nFollow prescriptions\nOf your lord and savior\n\nEvery temple is gold\nEvery hook is designed\nHell is but the temple\nOf the closed mind\nClosed mind\nClosed mind\nClosed mind\n\nIt's all smooth sailing\nFrom here on out\n\nShut up\n"
        
        navigationItem.title = "ScrollView Demo"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.nl_followScrollView(self.scrollView)
        
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        navigationController?.nl_showNavigationBar()
        return true
    }

    deinit {
        print("\(self.classForCoder) \(#function)")
    }

}
