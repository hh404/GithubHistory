//
//  GithubAPIRequestViewModel.swift
//  GithubHistory
//
//  Created by huangjianwu on 2021/1/31.
//

import Foundation
import Schedule
import Alamofire
import Repeat
import Cache

struct GithubAPI {
    var requestTimes: Int = 0
    var requestDate: Date = Date()
    var items: [GithubAPIItem] = []
    
    func dateIntervalKey() -> String {
        return String(format: "%f", requestDate.timeIntervalSince1970)
    }
    
    func dateString() -> String {
        let dateString = DateFormatter.localizedString(
            from: self.requestDate,
            dateStyle: .medium,
            timeStyle: .medium)
        return dateString
    }
}

struct APICacheKey: Codable {
    let keys : [String]?

    enum CodingKeys: String, CodingKey {
        case keys = "keys"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        keys = try values.decodeIfPresent([String].self, forKey: .keys)
    }


}

enum GithubAPIItem {
    case listItem(apiKey: String, apiValue: String)
}

extension GithubAPIResponse.CodingKeys {
    func keyCopy() -> String {
        switch self {
        case .authorizationsUrl:
            return "git.api.authorizations.url".localized()
        case .codeSearchUrl:
            return "git.api.code.search.url".localized()
        case .commitSearchUrl:
            return "git.api.commit.search.url".localized()
        case .currentUserAuthorizationsHtmlUrl:
            return "git.api.current.user.authorizations.html.url".localized()
        case .currentUserRepositoriesUrl:
            return "git.api.current.user.repositories.url".localized()
        case .currentUserUrl:
            return "git.api.current.user.url".localized()
        case .emailsUrl:
            return "git.api.emails.url".localized()
        case .emojisUrl:
            return "git.api.emojis.url".localized()
        case .eventsUrl:
            return "git.api.events.url".localized()
        case .feedsUrl:
            return "git.api.feeds.url".localized()
        case .followersUrl:
            return "git.api.followers.url".localized()
        case .followingUrl:
            return "git.api.following.url".localized()
        case .gistsUrl:
            return "git.api.gists.url".localized()
        case .hubUrl:
            return "git.api.hub.url".localized()
        case .issueSearchUrl:
            return "git.api.issue.search.url".localized()
        case .issuesUrl:
            return "git.api.issues.url".localized()
        case .keysUrl:
            return "git.api.keys.url".localized()
        case .labelSearchUrl:
            return "git.api.label.search.url".localized()
        case .notificationsUrl:
            return "git.api.notifications.url".localized()
        case .organizationRepositoriesUrl:
            return "git.api.organization.repositories.url".localized()
        case .organizationTeamsUrl:
            return "git.api.organization.teams.url".localized()
        case .organizationUrl:
            return "git.api.organization.url".localized()
        case .publicGistsUrl:
            return "git.api.public.gists.url".localized()
        case .rateLimitUrl:
            return "git.api.rate.limit.url".localized()
        case .repositorySearchUrl:
            return "git.api.repository.search.url".localized()
        case .repositoryUrl:
            return "git.api.repository.url".localized()
        case .starredGistsUrl:
            return "git.api.starred.gists.url".localized()
        case .starredUrl:
            return "git.api.starred.url".localized()
        case .userOrganizationsUrl:
            return "git.api.user.organizations.url".localized()
        case .userRepositoriesUrl:
            return "git.api.user.repositories.url".localized()
        case .userSearchUrl:
            return "git.api.user.search.url".localized()
        case .userUrl:
            return "git.api.user.url".localized()
        }
    }
}

protocol viewEventHandle: class {
    func onViewReady() -> Void
    func onViewRemoved() -> Void
    func onViewWillAppear() -> Void
    func onViewDidAppear() -> Void
    func onViewWillDisAppear() -> Void
    func onViewDidDisAppear() -> Void
}

protocol ViewModelDelegate: class {
    func requestDidStart(with model: Any?)
    func requestDidFinishSuccess(with model: Any?)
    func requestDidFinishError(with error: Error)
    func modelDidLoad(with model: Any?)
}


protocol GitAPIViewEventHandle: viewEventHandle{
    func saveBtnClicked()
    func historyBtnClicked(view: UIViewController)
}

extension Notification.Name {
    static let DidRequestSuccess = Notification.Name("GitAPIDidRequestSuccess")
}

enum GithubAPIRequestViewItem {
    case requestTimeLabel
    case loadingIndicator
    case gotoHistoryBtn
    case saveResponseBtn
    case responseTextView
    
    func accessbilityID() -> String {
        switch self {
        case .requestTimeLabel:
            return "git.api.request.time.label"
        case .loadingIndicator:
            return "git.api.loading.indicator"
        case .gotoHistoryBtn:
            return "git.api.goto.history.btn"
        case .saveResponseBtn:
            return "git.api.save.response.btn"
        case .responseTextView:
            return "git.api.response.text.view"
        }
    }
}

class GithubAPIRequestViewModel {
    private var receiptArray: [RequestReceipt] = []
    private let scheduleQueue: DispatchQueue = {
        let name = String(format: "com.hans.scheduleQueue.synchronizationqueue")
        return DispatchQueue(label: name)
    }()
    private var githubAPIs: [GithubAPI] = []
    private var requestTimes: Int = 0
    private var cacheKeyArray: [String] = []
    weak var delegate: ViewModelDelegate?
    private var timer: Repeater?
    let storage = try! Storage<[String]>(
        diskConfig: DiskConfig(name: "Hans_key"),
        memoryConfig: MemoryConfig(),
        transformer: TransformerFactory.forCodable(ofType: [String].self))
    init() {
        storage.async.object(forKey: "cacheKey") { (result) in
            switch result {
            case .value(let keys):
                self.cacheKeyArray = keys
                DispatchQueue.main.async {
                    if self.delegate != nil {
                        self.delegate?.modelDidLoad(with: self.cacheKeyArray.count)
                    }
                }
            case .error(_):
                break
            }
        }
    }
    
    func start() {
        if timer == nil {
            self.timer = Repeater.every(.seconds(5)) { timer in
                // do something
                self.requestTimes += 1
                var githubAPI: GithubAPI = GithubAPI.init(requestTimes: self.requestTimes, requestDate: Date(), items: [])
                self.cacheKeyArray.append(githubAPI.dateIntervalKey())
                DispatchQueue.main.async {
                    if self.delegate != nil {
                        self.delegate?.requestDidStart(with: self.requestTimes)
                    }
                }
                let receipt = APIRequestQueueManager.default.requestGitAPI(URLRequest(url: URL(string: "https://api.github.com/")!), cacheKey: githubAPI.dateIntervalKey(), receiptID: UUID().uuidString) {[weak self] (response) in
                    switch response.result {
                    case .success(let model):
                        let items = (GithubAPIRequestViewModel.build(response: model))
                        githubAPI.items = items
                        self?.githubAPIs.append(githubAPI)
                        DispatchQueue.main.async {
                            print("🀄️🀄️Requet post")
                            NotificationCenter.default.post(name: NSNotification.Name.DidRequestSuccess, object: self?.cacheKeyArray, userInfo: nil)
                            if self?.delegate != nil {
                                self?.delegate?.requestDidFinishSuccess(with: response.data)
                            }
                        }
                    case .failure(_):
                        break
                    }
                }
                if let receipt = receipt {
                    self.receiptArray.append(receipt)
                }
            }
        }
        self.timer?.start()
    }
    
    class func build(response: GithubAPIResponse) -> [GithubAPIItem] {
        var items: [GithubAPIItem] = []
        let authorizationsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.authorizationsUrl.keyCopy(), apiValue: response.authorizationsUrl ?? "")
        items.append(authorizationsUrlItem)
        let codeSearchUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.codeSearchUrl.keyCopy(), apiValue: response.codeSearchUrl ?? "")
        items.append(codeSearchUrlItem)
        let commitSearchUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.commitSearchUrl.keyCopy(), apiValue: response.commitSearchUrl ?? "")
        items.append(commitSearchUrlItem)
        let currentUserAuthorizationsHtmlUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.currentUserAuthorizationsHtmlUrl.keyCopy(), apiValue: response.currentUserAuthorizationsHtmlUrl ?? "")
        items.append(currentUserAuthorizationsHtmlUrlItem)
        let currentUserRepositoriesUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.currentUserRepositoriesUrl.keyCopy(), apiValue: response.currentUserRepositoriesUrl ?? "")
        items.append(currentUserRepositoriesUrlItem)
        let currentUserUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.currentUserUrl.keyCopy(), apiValue: response.currentUserUrl ?? "")
        items.append(currentUserUrlItem)
        let emailsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.emailsUrl.keyCopy(), apiValue: response.emailsUrl ?? "")
        items.append(emailsUrlItem)
        let emojisUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.emojisUrl.keyCopy(), apiValue: response.emojisUrl ?? "")
        items.append(emojisUrlItem)
        let eventsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.eventsUrl.keyCopy(), apiValue: response.eventsUrl ?? "")
        items.append(eventsUrlItem)
        let feedsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.feedsUrl.keyCopy(), apiValue: response.feedsUrl ?? "")
        items.append(feedsUrlItem)
        let followersUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.followersUrl.keyCopy(), apiValue: response.followersUrl ?? "")
        items.append(followersUrlItem)
        let followingUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.followingUrl.keyCopy(), apiValue: response.followingUrl ?? "")
        items.append(followingUrlItem)
        let gistsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.gistsUrl.keyCopy(), apiValue: response.gistsUrl ?? "")
        items.append(gistsUrlItem)
        let hubUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.hubUrl.keyCopy(), apiValue: response.hubUrl ?? "")
        items.append(hubUrlItem)
        let issueSearchUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.issueSearchUrl.keyCopy(), apiValue: response.issueSearchUrl ?? "")
        items.append(issueSearchUrlItem)
        let issuesUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.issuesUrl.keyCopy(), apiValue: response.issuesUrl ?? "")
        items.append(issuesUrlItem)
        let keysUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.keysUrl.keyCopy(), apiValue: response.keysUrl ?? "")
        items.append(keysUrlItem)
        let labelSearchUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.labelSearchUrl.keyCopy(), apiValue: response.labelSearchUrl ?? "")
        items.append(labelSearchUrlItem)
        let notificationsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.notificationsUrl.keyCopy(), apiValue: response.notificationsUrl ?? "")
        items.append(notificationsUrlItem)
        let organizationRepositoriesUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.organizationRepositoriesUrl.keyCopy(), apiValue: response.organizationRepositoriesUrl ?? "")
        items.append(organizationRepositoriesUrlItem)
        let organizationTeamsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.organizationTeamsUrl.keyCopy(), apiValue: response.organizationTeamsUrl ?? "")
        items.append(organizationTeamsUrlItem)
        let organizationUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.organizationUrl.keyCopy(), apiValue: response.organizationUrl ?? "")
        items.append(organizationUrlItem)
        let publicGistsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.publicGistsUrl.keyCopy(), apiValue: response.publicGistsUrl ?? "")
        items.append(publicGistsUrlItem)
        let rateLimitUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.rateLimitUrl.keyCopy(), apiValue: response.rateLimitUrl ?? "")
        items.append(rateLimitUrlItem)
        let repositorySearchUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.repositorySearchUrl.keyCopy(), apiValue: response.repositorySearchUrl ?? "")
        items.append(repositorySearchUrlItem)
        let repositoryUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.repositoryUrl.keyCopy(), apiValue: response.repositoryUrl ?? "")
        items.append(repositoryUrlItem)
        let starredGistsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.starredGistsUrl.keyCopy(), apiValue: response.starredGistsUrl ?? "")
        items.append(starredGistsUrlItem)
        let starredUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.starredUrl.keyCopy(), apiValue: response.starredUrl ?? "")
        items.append(starredUrlItem)
        let userOrganizationsUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.userOrganizationsUrl.keyCopy(), apiValue: response.userOrganizationsUrl ?? "")
        items.append(userOrganizationsUrlItem)
        let userRepositoriesUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.userRepositoriesUrl.keyCopy(), apiValue: response.userRepositoriesUrl ?? "")
        items.append(userRepositoriesUrlItem)
        let userSearchUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.userSearchUrl.keyCopy(), apiValue: response.userSearchUrl ?? "")
        items.append(userSearchUrlItem)
        let userUrlItem =  GithubAPIItem.listItem(apiKey: GithubAPIResponse.CodingKeys.userUrl.keyCopy(), apiValue: response.userUrl ?? "")
        items.append(userUrlItem)
        return items
    }
}


extension GithubAPIRequestViewModel: GitAPIViewEventHandle {
    func onViewReady() {
        
    }
    
    func onViewRemoved() {
        
    }
    
    func onViewWillAppear() {
        
    }
    
    func onViewDidAppear() {
        
    }
    
    func onViewWillDisAppear() {
        
    }
    
    func onViewDidDisAppear() {
        
    }
    
    func saveBtnClicked() {
        print("🇧🇾")
        self.timer?.pause()
        storage.async.setObject(cacheKeyArray, forKey: "cacheKey") { (storageResult) in
            switch storageResult {
            case .value(()):
                print("scu♥️")
                break
            case .error(let error):
                print("♣️♣️\(error)")
                break
            }
        }
    }
    
    func historyBtnClicked(view: UIViewController) {
        let vc = HistoryViewController()
        let vm = HistroyViewModel(historys: self.cacheKeyArray)
        vc.viewModel = vm
        view.navigationController?.pushViewController(vc, animated: true)
    }
}
