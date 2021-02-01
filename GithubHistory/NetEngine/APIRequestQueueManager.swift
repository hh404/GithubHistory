//
//  APIRequestQueueManager.swift
//  GithubHistory
//
//  Created by huangjianwu on 2021/2/2.
//

import Foundation
import Alamofire
import Cache

class APIRequestQueueManager {
    typealias CompletionHandler = (AFIDataResponse<GithubAPIResponse>) -> Void
    
    class ResponseHandler {
        let requestID: String
        let handlerID: String
        let request: DataRequest
        var operations: [(receiptID: String, completion: CompletionHandler?)]
        
        init(request: DataRequest,
             handlerID: String,
             receiptID: String,
             completion: CompletionHandler?) {
            self.request = request
            requestID = APIRequestQueueManager.requestIdentifier(for: request)
            self.handlerID = handlerID
            operations = [(receiptID: receiptID, completion: completion)]
        }
    }
    
    // MARK: Properties
    
    private var storage: Storage<GithubAPIResponse>!
    
    public var imageResponseSerializer = JSONResponseSerializer()
    
    /// The underlying Alamofire `Session` instance used to handle all  requests.
    public let session: Session
    
    let maximumActiveRequests: Int
    
    var activeRequestCount = 0
    var queuedRequests: [Request] = []
    var responseHandlers: [String: ResponseHandler] = [:]
    
    private let synchronizationQueue: DispatchQueue = {
        let name = String(format: "git.api.synchronizationqueue", arc4random(), arc4random())
        return DispatchQueue(label: name)
    }()
    
    private let responseQueue: DispatchQueue = {
        let name = String(format: "git.api.responsequeue", arc4random(), arc4random())
        return DispatchQueue(label: name, attributes: .concurrent)
    }()
    
    // MARK: Initialization
    
    /// The default instance of `APIRequestQueueManager` initialized with default values.
    public static let `default` = APIRequestQueueManager()
    
    /// Creates a default `URLSessionConfiguration` with common usage parameter values.
    ///
    /// - returns: The default `URLSessionConfiguration` instance.
    open class func defaultURLSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        
        configuration.headers = .default
        configuration.httpShouldSetCookies = true
        configuration.httpShouldUsePipelining = false
        
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForRequest = 60
        
        return configuration
    }
    
    
    /// Initializes the `APIRequestQueueManager` instance with the given configuration, maximum active
    ///
    /// - parameter configuration:          The `URLSessionConfiguration` to use to create the underlying Alamofire
    ///                                     `SessionManager` instance.
    /// - parameter maximumActiveRequests: The maximum number of active requests allowed at any given time.
    ///
    /// - returns: The new `APIRequestQueueManager` instance.
    public init(configuration: URLSessionConfiguration = APIRequestQueueManager.defaultURLSessionConfiguration(),
                maximumActiveRequests: Int = 10) {
        session = Session(configuration: configuration, startRequestsImmediately: false)
        self.maximumActiveRequests = maximumActiveRequests
        do {
            storage = try! Storage<GithubAPIResponse>(
                diskConfig: DiskConfig(name: "Hans"),
                memoryConfig: MemoryConfig(),
                transformer: TransformerFactory.forCodable(ofType: GithubAPIResponse.self)
            )
        }
    }
    
    /// Initializes the `APIRequestQueueManager` instance with the given session manager, request prioritization, maximum
    /// active download count and  cache.
    ///
    /// - parameter session:                The Alamofire `Session` instance to handle all  requests.
    /// - parameter maximumActiveRequests: The maximum number of active reuqest allowed at any given time.
    ///
    /// - returns: The new `APIRequestQueueManager` instance.
    public init(session: Session,
                maximumActiveRequests: Int = 10) {
        precondition(!session.startRequestsImmediately, "Session must set `startRequestsImmediately` to `false`.")
        
        self.session = session
        self.maximumActiveRequests = maximumActiveRequests
    }
    
    
    
    // MARK: requestGitAPI
    
    @discardableResult
    func requestGitAPI(_ urlRequest: URLRequestConvertible,
                       cacheKey: String? = nil,
                       receiptID: String = UUID().uuidString,
                       completion: CompletionHandler? = nil)
    -> RequestReceipt? {
        var queuedRequest: DataRequest?
        
        synchronizationQueue.sync {
            
            if let nonNilURLRequest = urlRequest.urlRequest {
                switch nonNilURLRequest.cachePolicy {
                case .useProtocolCachePolicy, .returnCacheDataElseLoad, .returnCacheDataDontLoad:
                    var cachedAPI: GithubAPIResponse?
                    
                    if let cacheKey = cacheKey {
                        self.storage.async.object(forKey: cacheKey) { result in
                            switch result {
                            case .value(let api):
                                cachedAPI = api
                            case .error(_):
                                break
                            }
                        }
                    }
                    
                    if let api = cachedAPI {
                        DispatchQueue.main.async {
                            let response = AFIDataResponse<GithubAPIResponse>(request: urlRequest.urlRequest,
                                                                              response: nil,
                                                                              data: nil,
                                                                              metrics: nil,
                                                                              serializationDuration: 0.0,
                                                                              result: .success(api))
                            
                            completion?(response)
                        }
                        return
                    }
                default:
                    break
                }
            }
            
            let request = self.session.request(urlRequest)
            queuedRequest = request
            request.validate()
            
            // create a unique handler id
            let handlerID = UUID().uuidString
            
            request.response(queue: self.responseQueue,
                             responseSerializer: imageResponseSerializer,
                             completionHandler: {[weak self] response in
                                defer {
                                    self?.safelyDecrementActiveRequestCount()
                                    self?.safelyStartNextRequestIfNecessary()
                                }
                                
                                // Early out if the request has changed out from under us
                                guard
                                    let handler = self?.safelyFetchResponseHandler(withrequestIdentifier: receiptID),
                                    handler.handlerID == handlerID,
                                    let responseHandler = self?.safelyRemoveResponseHandler(withrequestIdentifier: receiptID)
                                else {
                                    return
                                }
                                
                                switch response.result {
                                case .success(_):
                                    for (_, completion) in responseHandler.operations {
                                        do {
                                            if let data = response.data {
                                                let githubAPIResponse = try JSONDecoder().decode(GithubAPIResponse.self,from: data)
                                                if let cacheKey = cacheKey {
                                                    self?.storage.async.setObject(githubAPIResponse, forKey: cacheKey) { (storageResult) in
                                                    }
                                                }
                                                
                                                DispatchQueue.main.async {
                                                    let response = AFIDataResponse<GithubAPIResponse>(request: response.request,
                                                                                                      response: response.response,
                                                                                                      data: response.data,
                                                                                                      metrics: response.metrics,
                                                                                                      serializationDuration: response.serializationDuration,
                                                                                                      result: .success(githubAPIResponse))
                                                    completion?(response)
                                                }
                                            }
                                        }
                                        catch {
                                            DispatchQueue.main.async {
                                                let fail = AFIDataResponse<GithubAPIResponse>(request: response.request,
                                                                                              response: response.response,
                                                                                              data: response.data,
                                                                                              metrics: response.metrics,
                                                                                              serializationDuration: response.serializationDuration,
                                                                                              result: .failure(response.error ?? AFError.responseValidationFailed(reason: .customValidationFailed(error: NSError()))))
                                                completion?(fail)
                                            }
                                        }
                                        
                                    }
                                case .failure:
                                    for (_, completion) in responseHandler.operations {
                                        DispatchQueue.main.async {
                                            let fail = AFIDataResponse<GithubAPIResponse>(request: response.request,
                                                                                          response: response.response,
                                                                                          data: response.data,
                                                                                          metrics: response.metrics,
                                                                                          serializationDuration: response.serializationDuration,
                                                                                          result: .failure(response.error ?? AFError.responseValidationFailed(reason: .customValidationFailed(error: NSError()))))
                                            completion?(fail)
                                        }
                                    }
                                }
                             })
            
            // 4) Store the response handler for use when the request completes
            let responseHandler = ResponseHandler(request: request,
                                                  handlerID: handlerID,
                                                  receiptID: receiptID,
                                                  completion: completion)
            
            self.responseHandlers[receiptID] = responseHandler
            
            // 5) Either start the request or enqueue it depending on the current active request count
            if self.isActiveRequestCountBelowMaximumLimit() {
                self.start(request)
            } else {
                self.enqueue(request)
            }
        }
        
        if let request = queuedRequest {
            return RequestReceipt(request: request, receiptID: receiptID)
        }
        
        return nil
    }
    
    
    // MARK: Internal - Thread-Safe Request Methods
    
    func safelyFetchResponseHandler(withrequestIdentifier requestIdentifier: String) -> ResponseHandler? {
        var responseHandler: ResponseHandler?
        
        synchronizationQueue.sync {
            responseHandler = self.responseHandlers[requestIdentifier]
        }
        
        return responseHandler
    }
    
    func safelyRemoveResponseHandler(withrequestIdentifier identifier: String) -> ResponseHandler? {
        var responseHandler: ResponseHandler?
        
        synchronizationQueue.sync {
            responseHandler = self.responseHandlers.removeValue(forKey: identifier)
        }
        
        return responseHandler
    }
    
    func safelyStartNextRequestIfNecessary() {
        synchronizationQueue.sync {
            guard self.isActiveRequestCountBelowMaximumLimit() else { return }
            
            guard let request = self.dequeue() else { return }
            
            self.start(request)
        }
    }
    
    func safelyDecrementActiveRequestCount() {
        synchronizationQueue.sync {
            self.activeRequestCount -= 1
        }
    }
    
    // MARK: Internal - Non Thread-Safe Request Methods
    
    func start(_ request: Request) {
        request.resume()
        activeRequestCount += 1
    }
    
    func enqueue(_ request: Request) {
        queuedRequests.append(request)
    }
    
    @discardableResult
    func dequeue() -> Request? {
        var request: Request?
        
        if !queuedRequests.isEmpty {
            request = queuedRequests.removeFirst()
        }
        
        return request
    }
    
    func isActiveRequestCountBelowMaximumLimit() -> Bool {
        activeRequestCount < maximumActiveRequests
    }
    
    
    static func requestIdentifier(for urlRequest: Request) -> String {
        return urlRequest.id.uuidString
    }
}


public typealias AFIDataResponse<T> = DataResponse<T, AFError>
open class RequestReceipt {
    public let request: DataRequest

    /// The unique identifier
    public let receiptID: String

    init(request: DataRequest, receiptID: String) {
        self.request = request
        self.receiptID = receiptID
    }
}
