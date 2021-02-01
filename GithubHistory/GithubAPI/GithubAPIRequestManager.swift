//
//  GithubAPIRequestManager.swift
//  GithubHistory
//
//  Created by huangjianwu on 2021/1/31.
//

import Foundation
import Schedule
import Alamofire

class GithubAPIRequestManager {
    private var receiptArray: [RequestReceipt] = []
    
    func start() {
        Plan.every(5.second).do(queue: .global()) {
            let dateString = DateFormatter.localizedString(
                from: Date(),
                dateStyle: .medium,
                timeStyle: .medium)
            let receipt = APIRequestQueueManager.default.requestGitAPI(URLRequest(url: URL(string: "https://api.github.com/")!), cacheKey: "", receiptID: "") { (response) in
                print(response)
                switch response.result {
                case .success(let model):
                    break
                case .failure(let error):
                    break
                }
            }
            var api = GithubAPI(requestTimes: 1, requestDate: dateString, items: [])
            let dd = AF.request("https://api.github.com/").responseJSON {[weak self] response in
                do {
                    if let data = response.data {
                        let student = try JSONDecoder().decode(GithubAPIResponse.self,from: data)
                        //                        if let items = (self?.build(response: student)) {
                        //                            api.items = items
                        //                            self?.githubAPI = api
                        //                            self?.tableView.reloadData()
                        //                        }
                    }
                }
                catch {
                    
                }
            }
        }
    }
    
}
