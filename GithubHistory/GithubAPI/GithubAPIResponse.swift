//
//	RootClass.swift
//
//	Create by huangjianwu on 31/1/2021
//	Copyright © 2021. All rights reserved.

import Foundation

struct GithubAPIResponse : Codable {
	let authorizationsUrl : String?
	let codeSearchUrl : String?
	let commitSearchUrl : String?
	let currentUserAuthorizationsHtmlUrl : String?
	let currentUserRepositoriesUrl : String?
	let currentUserUrl : String?
	let emailsUrl : String?
	let emojisUrl : String?
	let eventsUrl : String?
	let feedsUrl : String?
	let followersUrl : String?
	let followingUrl : String?
	let gistsUrl : String?
	let hubUrl : String?
	let issueSearchUrl : String?
	let issuesUrl : String?
	let keysUrl : String?
	let labelSearchUrl : String?
	let notificationsUrl : String?
	let organizationRepositoriesUrl : String?
	let organizationTeamsUrl : String?
	let organizationUrl : String?
	let publicGistsUrl : String?
	let rateLimitUrl : String?
	let repositorySearchUrl : String?
	let repositoryUrl : String?
	let starredGistsUrl : String?
	let starredUrl : String?
	let userOrganizationsUrl : String?
	let userRepositoriesUrl : String?
	let userSearchUrl : String?
	let userUrl : String?


	enum CodingKeys: String, CodingKey {
		case authorizationsUrl = "authorizations_url"
		case codeSearchUrl = "code_search_url"
		case commitSearchUrl = "commit_search_url"
		case currentUserAuthorizationsHtmlUrl = "current_user_authorizations_html_url"
		case currentUserRepositoriesUrl = "current_user_repositories_url"
		case currentUserUrl = "current_user_url"
		case emailsUrl = "emails_url"
		case emojisUrl = "emojis_url"
		case eventsUrl = "events_url"
		case feedsUrl = "feeds_url"
		case followersUrl = "followers_url"
		case followingUrl = "following_url"
		case gistsUrl = "gists_url"
		case hubUrl = "hub_url"
		case issueSearchUrl = "issue_search_url"
		case issuesUrl = "issues_url"
		case keysUrl = "keys_url"
		case labelSearchUrl = "label_search_url"
		case notificationsUrl = "notifications_url"
		case organizationRepositoriesUrl = "organization_repositories_url"
		case organizationTeamsUrl = "organization_teams_url"
		case organizationUrl = "organization_url"
		case publicGistsUrl = "public_gists_url"
		case rateLimitUrl = "rate_limit_url"
		case repositorySearchUrl = "repository_search_url"
		case repositoryUrl = "repository_url"
		case starredGistsUrl = "starred_gists_url"
		case starredUrl = "starred_url"
		case userOrganizationsUrl = "user_organizations_url"
		case userRepositoriesUrl = "user_repositories_url"
		case userSearchUrl = "user_search_url"
		case userUrl = "user_url"
	}
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		authorizationsUrl = try values.decodeIfPresent(String.self, forKey: .authorizationsUrl)
		codeSearchUrl = try values.decodeIfPresent(String.self, forKey: .codeSearchUrl)
		commitSearchUrl = try values.decodeIfPresent(String.self, forKey: .commitSearchUrl)
		currentUserAuthorizationsHtmlUrl = try values.decodeIfPresent(String.self, forKey: .currentUserAuthorizationsHtmlUrl)
		currentUserRepositoriesUrl = try values.decodeIfPresent(String.self, forKey: .currentUserRepositoriesUrl)
		currentUserUrl = try values.decodeIfPresent(String.self, forKey: .currentUserUrl)
		emailsUrl = try values.decodeIfPresent(String.self, forKey: .emailsUrl)
		emojisUrl = try values.decodeIfPresent(String.self, forKey: .emojisUrl)
		eventsUrl = try values.decodeIfPresent(String.self, forKey: .eventsUrl)
		feedsUrl = try values.decodeIfPresent(String.self, forKey: .feedsUrl)
		followersUrl = try values.decodeIfPresent(String.self, forKey: .followersUrl)
		followingUrl = try values.decodeIfPresent(String.self, forKey: .followingUrl)
		gistsUrl = try values.decodeIfPresent(String.self, forKey: .gistsUrl)
		hubUrl = try values.decodeIfPresent(String.self, forKey: .hubUrl)
		issueSearchUrl = try values.decodeIfPresent(String.self, forKey: .issueSearchUrl)
		issuesUrl = try values.decodeIfPresent(String.self, forKey: .issuesUrl)
		keysUrl = try values.decodeIfPresent(String.self, forKey: .keysUrl)
		labelSearchUrl = try values.decodeIfPresent(String.self, forKey: .labelSearchUrl)
		notificationsUrl = try values.decodeIfPresent(String.self, forKey: .notificationsUrl)
		organizationRepositoriesUrl = try values.decodeIfPresent(String.self, forKey: .organizationRepositoriesUrl)
		organizationTeamsUrl = try values.decodeIfPresent(String.self, forKey: .organizationTeamsUrl)
		organizationUrl = try values.decodeIfPresent(String.self, forKey: .organizationUrl)
		publicGistsUrl = try values.decodeIfPresent(String.self, forKey: .publicGistsUrl)
		rateLimitUrl = try values.decodeIfPresent(String.self, forKey: .rateLimitUrl)
		repositorySearchUrl = try values.decodeIfPresent(String.self, forKey: .repositorySearchUrl)
		repositoryUrl = try values.decodeIfPresent(String.self, forKey: .repositoryUrl)
		starredGistsUrl = try values.decodeIfPresent(String.self, forKey: .starredGistsUrl)
		starredUrl = try values.decodeIfPresent(String.self, forKey: .starredUrl)
		userOrganizationsUrl = try values.decodeIfPresent(String.self, forKey: .userOrganizationsUrl)
		userRepositoriesUrl = try values.decodeIfPresent(String.self, forKey: .userRepositoriesUrl)
		userSearchUrl = try values.decodeIfPresent(String.self, forKey: .userSearchUrl)
		userUrl = try values.decodeIfPresent(String.self, forKey: .userUrl)
	}
}
