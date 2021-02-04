# GithubHistory
##enviroment
`Xcode verison` : `12.2`

`swift version` : `4.2 or above`

##guideline
###about github api request/response view
![-w200](https://raw.githubusercontent.com/hh404/images/master/20210205002309.jpg)

###about history
**current response**
![-w200](https://raw.githubusercontent.com/hh404/images/master/20210205003131.jpg)
**other response**
![-w200](https://raw.githubusercontent.com/hh404/images/master/20210205003301.jpg)
##about request
- request support queue requests,data parse in background thread
- response will backstore in sandbox,it can be found in memory,if no will get from disk,if no will get from github remote server.
- API response model **GithubAPIResponse** is business layer data model, **GithubAPI** is view layer data model,**GithubAPI** for UI.

## next step
- refactor with **VIPER**
- add more comments
- add more unit test