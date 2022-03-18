/**
 * OrgChartViewController.swift
 * OrgChart
 *
 * Created by Park, Chanick on 1/13/17.
 * Copyright © 2016 Park, Chanick. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

//
// OrgChartViewController Class
//
class OrgChartViewController: UIViewController {

    // OrgChart View Model
    var chartViewModel: OrgChartViewModel!
    
    // OrgChart View
    @IBOutlet var orgChartView: OrgChartView!
    
    
    
    
    
    
    // MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        
        // Error: view is not in the window hierarchy
        // initChartView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initChartView()
    }
    
    // MARK: - Private
    
    private func config() {
        // Create ViewModel
        chartViewModel = OrgChartViewModel()
        
        // Bind Chart Updater
        chartViewModel.bindChartUpdater = { [unowned self] in
            DispatchQueue.main.async {
                self.updateChartView()
            }
        }
    }
    
    private func initChartView() {
        // Fatch OrgChart Data
        chartViewModel.fatchOrgChart()
//        chartViewModel.fatchOrgChart {
//            DispatchQueue.main.async { [unowned self] in
//                self.updateChartView()
//            }
//        }
    }
    
    func updateChartView() {
        // Reset & Create
        orgChartView.loadChart(chartViewModel.chartData)
    }
    
    // MARK: - IBActions
    @IBAction func reloadBtnTapped(_ btn: UIButton) {
        // request again
        chartViewModel.fatchOrgChart()
    }
}
