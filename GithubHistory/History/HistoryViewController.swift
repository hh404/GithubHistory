//
//  HistoryViewController.swift
//  GithubHistory
//
//  Created by huangjianwu on 2021/2/2.
//

import UIKit
import SnapKit
import ESPullToRefresh

class HistoryViewController: UIViewController {
    private var tableView = UITableView(frame: .zero, style: .plain)
    var viewModel: HistroyViewModel?
    weak var eventHander: viewEventHandle?
    private var indicatorItem: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.accessibilityIdentifier = HistoryViewItem.tableView.accessbilityID()
        tableView.register(GithubAPITCell.self, forCellReuseIdentifier: "GithubAPITCell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(64)
        }
        self.title = "History"
        viewModel?.delegate = self
        self.eventHander = viewModel
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        indicatorItem = UIBarButtonItem(customView: view)
        self.navigationItem.rightBarButtonItems = [indicatorItem!]
        
        self.tableView.es.addPullToRefresh { [weak self] in
            let v = self?.indicatorItem?.customView
            v?.backgroundColor = .clear
            self?.eventHander?.onViewWillAppear()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.eventHander?.onViewWillAppear()
    }
}

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.githubAPIs.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = self.viewModel?.githubAPIs[section]
        return item?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GithubAPITCell = tableView.dequeueReusableCell(withIdentifier: "GithubAPITCell") as? GithubAPITCell ?? GithubAPITCell()
        let githubAPI = self.viewModel?.githubAPIs[indexPath.section]
        let item = githubAPI?.items[indexPath.row]
        if let tItem = item {
            switch tItem {
            case .listItem(let key, let value):
                cell.setModel(key: key, value: value)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let githubAPI = self.viewModel?.githubAPIs[section]
        var title = String(format: "%@_(%d)", githubAPI?.dateString() ?? "", githubAPI?.requestTimes ?? 1)
        if section == 0 {
            title = String(format: "❤️❤️❤️❤️%@_(%d)❤️❤️❤️", githubAPI?.dateString() ?? "", githubAPI?.requestTimes ?? 1)
        }
        return title
    }
}


extension HistoryViewController: HistoryViewModelDelegate {
    func didReceiveNewAPI() {
        print("♦️♦️")
        let v = indicatorItem?.customView
        v?.backgroundColor = .red
    }
    
    func requestDidStart(with model: Any?) {
        
    }
    
    func requestDidFinishSuccess(with model: Any?) {
        
    }
    
    func requestDidFinishError(with error: Error) {
        
    }
    
    func modelDidLoad(with model: Any?) {
        self.tableView.reloadData()
        self.tableView.es.stopPullToRefresh()
    }
    
    
}
