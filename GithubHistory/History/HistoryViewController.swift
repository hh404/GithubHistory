//
//  HistoryViewController.swift
//  GithubHistory
//
//  Created by huangjianwu on 2021/2/2.
//

import UIKit
import SnapKit

class HistoryViewController: UIViewController {
    private var tableView = UITableView(frame: .zero, style: .plain)
    private var githubAPI: GithubAPI?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.register(GithubAPITCell.self, forCellReuseIdentifier: "GithubAPITCell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(64)
        }
        self.title = "History"
    }
}

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return githubAPI?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GithubAPITCell = tableView.dequeueReusableCell(withIdentifier: "GithubAPITCell") as? GithubAPITCell ?? GithubAPITCell()
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
        return String(format: "%@_(%d)", githubAPI?.dateString() ?? "", githubAPI?.requestTimes ?? 1)
    }
}
