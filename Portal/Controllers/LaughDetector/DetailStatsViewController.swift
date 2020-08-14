//
//  DetailStatsViewController.swift
//  Portal
//
//  Created by Azam Mukhtar on 02/08/20.
//  Copyright © 2020 Dedy Yuristiawan. All rights reserved.
//

import UIKit
import Charts

class DetailStatsViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var labelViewer: UILabel!
    
    @IBOutlet weak var labelLaugh: UILabel!
    var post: Post?
    var laughList : [Laugh] = []
    var empty : [Laugh] = []
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var labelResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setData()
        getAllLaugh()
        labelResult.isHidden = true
        chartView.delegate = self
        chartView.chartDescription?.enabled = true
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setChartData(valuesin : [ChartDataEntry]){
        let set = LineChartDataSet(entries: valuesin, label: "Laugh")
        let data = LineChartData(dataSet: set)
        chartView.data = data
    }
    
    var values : [ChartDataEntry] = []
    
    func getAllLaugh(){
        Laugh.all(result: { (laughs) in
            self.laughList = laughs ?? self.empty
            self.getData()
            
        }) { (error) in
            print(error)
        }
        
    }
    
    func getData(){
        if !laughList.isEmpty{
            laughList = laughList.filter { $0.postId == post!.id?.recordName }
            empty = laughList
            laughList.sort { (a, b) -> Bool in
                a.second! < b.second!
            }
     let isIndexValid = self.laughList.indices.contains(0)
          if isIndexValid {
              for i in 0...Int(self.laughList[0].totalDuration ?? 0.0) {
                  let isIndexValid = self.laughList.indices.contains(i)
                  if isIndexValid {
                    print("BBB \(self.laughList[i].second)")
                    print("BBBi \(i)")
//                    if self.laughList[i].second == i {
                        empty = laughList.filter { $0.second == i }
                        print("sss \(empty.count)")
                    self.values.append(ChartDataEntry(x: Double(i), y: Double(empty.count)))
                        empty = laughList
//                    }
                  } else {
                      self.values.append(ChartDataEntry(x: Double(i), y:0.0))
                  }
              }
            DispatchQueue.main.async {
                self.setChartData(valuesin: self.values)
                self.setLabel()
            }
          }
        } else {
            print("list empty")
        }
    }
    
    func setLabel(){
        let info = "X value = Show second \r\nY value = Show how many laugh you get at that time\r\n"
        labelResult.isHidden = false
        if Int(post?.lpm ?? 0.0) < post?.viewer ?? 0 {
            labelResult.text = "\(info)\r\nConclusion : Not bad, but you can't make everyone laugh :("
        } else if Int(post?.lpm ?? 0.0) > post?.viewer ?? 0 {
            labelResult.text = "\(info)\r\nConclusion : Very good, your jokes works !"
        } else if Int(post?.lpm ?? 0.0) == post?.viewer ?? 0 {
            labelResult.text = "\(info)\r\nConclusion : You are doing great, keep going !"
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
