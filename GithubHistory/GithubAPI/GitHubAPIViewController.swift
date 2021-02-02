//
//  GitHubAPIViewController.swift
//  GithubHistory
//
//  Created by huangjianwu on 2021/1/31.
//

import UIKit
import Localize_Swift
import Alamofire
import SnapKit
import SwiftDate
import RandomColorSwift
import NVActivityIndicatorView

class GitHubAPIViewController: UIViewController {
    private var textView = UITextView(frame: .zero)
    private var viewModel = GithubAPIRequestViewModel()
    weak var eventHandle: GitAPIViewEventHandle?
    private var loadingView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 34, height: 34), type: .ballBeat, color: randomColor(), padding: 0)
    private var requestTimeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 36))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Request"
        self.view.addSubview(textView)
        viewModel.delegate = self
        self.eventHandle = viewModel
        viewModel.start()
        textView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(64)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-64)
        }
        
        self.view.addSubview(requestTimeLabel)
        requestTimeLabel.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.7803921569, blue: 0.3490196078, alpha: 0.1918282215)
        requestTimeLabel.textColor = .blue
        requestTimeLabel.font = UIFont.systemFont(ofSize: 12)
        
        let history = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(historyBtnClicked))
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveBtnClicked))
        let loading = UIBarButtonItem(customView: loadingView)
        loadingView.startAnimating()
        self.navigationItem.rightBarButtonItems = [done,history,loading]
        let times = UIBarButtonItem(customView: requestTimeLabel)
        self.navigationItem.leftBarButtonItems = [times]
    }
    
    @objc func historyBtnClicked() {
        eventHandle?.historyBtnClicked()
    }
    
    @objc func saveBtnClicked() {
        self.loadingView.stopAnimating()
        eventHandle?.saveBtnClicked()
    }
}


extension GitHubAPIViewController: ViewModelDelegate {
    func requestDidStart(with model: Any?) {
        let count: Int = model as? Int ?? 0
        requestTimeLabel.text = String(format: "request %d times", count)
    }
    
    func requestDidFinishSuccess(with model: Any?) {
        let data: Data? = model as? Data
        let string = String(data: data ?? Data(), encoding: .utf8)
        textView.text = string
        textView.textColor = randomColor()
    }
    
    func requestDidFinishError(with error: Error) {
        
    }
    
    func modelDidLoad(with model: Any?) {
        let count: Int = model as? Int ?? 0
        requestTimeLabel.text = String(format: "request %d times", count)
    }
}
