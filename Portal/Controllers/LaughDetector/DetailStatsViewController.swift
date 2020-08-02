//
//  DetailStatsViewController.swift
//  Portal
//
//  Created by Azam Mukhtar on 02/08/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit

class DetailStatsViewController: UIViewController {
    @IBOutlet weak var labelViewer: UILabel!
    
    @IBOutlet weak var labelLaugh: UILabel!
    var post: Post?
    var laughList : [Laugh] = []
    var empty : [Laugh] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setData()
    }
    
    
    func getAllLaugh(){
        Laugh.all(result: { (laughs) in
            self.laughList = laughs ?? self.empty
        }) { (error) in
            print(error)
        }
        
    }
    
    func getData(){
        if !laughList.isEmpty{
            laughList = laughList.filter { $0.postId == "\(post!.id!)" }
        } else {
            
        }
    }
    func setData(){
        labelViewer.text = "\(post?.viewer ?? 0)"
        labelLaugh.text = "\(post?.lpm ?? 0)"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
