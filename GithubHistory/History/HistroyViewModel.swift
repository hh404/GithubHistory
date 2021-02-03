//
//  HistroyViewModel.swift
//  GithubHistory
//
//  Created by huangjianwu on 2021/2/3.
//

import Foundation
import Cache

protocol HistoryViewModelDelegate: ViewModelDelegate {
    func didReceiveNewAPI()
}


enum HistoryViewItem {
    case tableView
    
    func accessbilityID() -> String {
        switch self {
        case .tableView:
            return "git.api.history.tableview"
        }
    }
}

class HistroyViewModel: NSObject {
    private(set) var githubAPIs: [GithubAPI] = []
    private var historyKeys: [String] = []
    private let storage = try! Storage<GithubAPIResponse>(
        diskConfig: DiskConfig(name: "Hans"),
        memoryConfig: MemoryConfig(),
        transformer: TransformerFactory.forCodable(ofType: GithubAPIResponse.self))
    weak var delegate: HistoryViewModelDelegate?
    private let dataHandleQueue: DispatchQueue = {
        let name = String(format: "git.api.history")
        return DispatchQueue(label: name)
    }()
    
    init(historys: [String]) {
        super.init()
        self.historyKeys = historys
        NotificationCenter.default.addObserver(self, selector: #selector(apiDidRequestSuccess(no:)), name: NSNotification.Name.DidRequestSuccess, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DidRequestSuccess, object: nil)
    }
    
    @objc func apiDidRequestSuccess(no: Notification) {
        print("🀄️🀄️🀄️apiDidRequestSuccess")
        let keys: [String] = no.object as! [String]
        dataHandleQueue.async {
            do {
                self.githubAPIs.removeAll()
                for (index,item) in keys.enumerated() {
                    let apiResponse = try self.storage.object(forKey: item)
                    let apiItems = GithubAPIRequestViewModel.build(response: apiResponse)
                    let api = GithubAPI(requestTimes: index, requestDate: Date(), items: apiItems)
                    self.githubAPIs.append(api)
                    DispatchQueue.main.async {
                        print("🀄️🀄️🀄️🀄️apiDidRequestSuccess")
                        self.delegate?.didReceiveNewAPI()
                    }
                }
            }
            catch {
                print(error)
            }
        }
    }
}


extension HistroyViewModel: viewEventHandle {
    
    func onViewReady() {
        
    }
    
    func onViewRemoved() {
        
    }
    
    func onViewWillAppear() {
        dataHandleQueue.async {
            do {
                for (index,item) in self.historyKeys.enumerated() {
                    let apiResponse = try self.storage.object(forKey: item)
                    let apiItems = GithubAPIRequestViewModel.build(response: apiResponse)
                    let api = GithubAPI(requestTimes: index, requestDate: Date(), items: apiItems)
                    self.githubAPIs.append(api)
                    DispatchQueue.main.async {
                        self.delegate?.modelDidLoad(with: nil)
                    }
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func onViewDidAppear() {
        
    }
    
    func onViewWillDisAppear() {
        
    }
    
    func onViewDidDisAppear() {
        
    }
}
