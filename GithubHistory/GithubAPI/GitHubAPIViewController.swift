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

struct GithubAPI {
    var requestTimes: Int = 0
    var requestDate: String = ""
    var items: [GithubAPIItem] = []
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


class GitHubAPIViewController: UIViewController {
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
        self.request()
        self.title = "History"
    }
    
    private func request() {
        let dateString = DateFormatter.localizedString(
            from: Date(),
          dateStyle: .medium,
          timeStyle: .medium)
        var api = GithubAPI(requestTimes: 1, requestDate: dateString, items: [])
        AF.request("https://api.github.com/").responseJSON {[weak self] response in
            do {
                if let data = response.data {
                    let student = try JSONDecoder().decode(GithubAPIResponse.self,from: data)
                    if let items = (self?.build(response: student)) {
                        api.items = items
                        self?.githubAPI = api
                        self?.tableView.reloadData()
                    }
                }
            }
            catch {
                
            }
        }
    }

    private func build(response: GithubAPIResponse) -> [GithubAPIItem] {
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

extension GitHubAPIViewController: UITableViewDataSource {
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
        return String(format: "%@_(%d)", githubAPI?.requestDate ?? "", githubAPI?.requestTimes ?? 1)
    }
}
