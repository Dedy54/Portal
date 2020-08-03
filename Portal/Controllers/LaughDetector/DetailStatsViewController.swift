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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setData()
        getAllLaugh()
        
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
            
            DispatchQueue.main.async {
                self.setChartData(valuesin: self.values)
            }
        }) { (error) in
            print(error)
        }
        
    }
    
    func getData(){
        if !laughList.isEmpty{
            laughList = laughList.filter { $0.postId == post!.id?.recordName }
            laughList.sort { (a, b) -> Bool in
                a.second! < b.second!
            }
     let isIndexValid = self.laughList.indices.contains(0)
          if isIndexValid {
              for i in 0...Int(self.laughList[0].totalDuration ?? 0.0) {
                  let isIndexValid = self.laughList.indices.contains(i)
                  if isIndexValid {
                    self.values.append(ChartDataEntry(x: Double(self.laughList[i].second ?? Int(0.0)), y: Double(self.laughList[i].isLaugh ?? Int(0.0))))
                  } else {
                      self.values.append(ChartDataEntry(x: Double(i), y: 0.0))
                  }
              }
          }
        } else {
            print("list empty")
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
