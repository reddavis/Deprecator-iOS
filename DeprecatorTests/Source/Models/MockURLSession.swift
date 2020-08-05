//
//  MockURLSession.swift
//  Red Davis
//
//  Created by Red Davis on 04/08/2017.
//  Copyright © 2017 Red Davis. All rights reserved.
//

import Foundation


internal class MockURLSession: URLSession
{
    // Internal
    internal var mockResponses = [Response]()
    
    // Private
    private var urlRequests = [URLRequest]()
    
    // MARK: Initialization
    
    internal override init() { }
    
    // MARK: Test helpers
    
    internal func numberOfRequests(matching pattern: String) -> Int
    {
        let count = self.urlRequests.filter { (urlRequest) -> Bool in
            let urlString = urlRequest.url?.absoluteString ?? ""
            return urlString.range(of: pattern, options: .regularExpression) != nil
        }.count
        
        return count
    }
    
    // MARK: URLSession
    
    override func dataTask(with request: URLRequest) -> URLSessionDataTask
    {
        return super.dataTask(with: request)
    }
    
    override func dataTask(with url: URL) -> URLSessionDataTask
    {
        return super.dataTask(with: url)
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    {
        return self.dataTask(with: URLRequest(url: url), completionHandler: completionHandler)
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    {
        self.urlRequests.append(request)
        
        // Find mock response
        let matchedResponse = self.mockResponses.first { (response) -> Bool in
            let urlString = request.url?.absoluteString ?? ""
            return urlString.range(of: response.urlPattern, options: .regularExpression) != nil
        }
        
        guard let unwrappedMockResponse = matchedResponse else
        {
            return EmptyTask()
        }

        return Task(request: request, response: unwrappedMockResponse, completionHandler: completionHandler)
    }
}


// MARK: Response

internal extension MockURLSession
{
    struct Response
    {
        // Internal
        internal let urlPattern: String
        internal let data: Data?
        internal let statusCode: Int
        internal let headers: [String : String]?
        
        // MARK: Initialization
        
        internal init(urlPattern: String, data: Data?, statusCode: Int, headers: [String : String]? = nil)
        {
            self.urlPattern = urlPattern
            self.data = data
            self.statusCode = statusCode
            self.headers = headers
        }
        
        internal init(urlPattern: String, params: [String : Any], statusCode: Int, headers: [String : String]? = nil) throws
        {
            self.urlPattern = urlPattern
            self.data = try JSONSerialization.data(withJSONObject: params, options: [])
            self.statusCode = statusCode
            self.headers = headers
        }
    }
}


// MARK: Task

internal extension MockURLSession
{
    class Task: URLSessionDataTask
    {
        // Private
        private let request: URLRequest
        private let mockedResponse: Response
        private let completionHandler: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
        
        // MARK: Initialization
        
        internal init(request: URLRequest, response: Response, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)
        {
            self.request = request
            self.mockedResponse = response
            self.completionHandler = completionHandler
        }
        
        // MARK: URLSessionDataTask
        
        override func resume()
        {
            guard let url = self.request.url else
            {
                return
            }
            
            let urlResponse = HTTPURLResponse(url: url, statusCode: self.mockedResponse.statusCode, httpVersion: nil, headerFields: self.mockedResponse.headers)
            self.completionHandler(self.mockedResponse.data, urlResponse, nil)
        }
    }
    
    class EmptyTask: URLSessionDataTask
    {
        internal override init() { }
        internal override func resume() { }
    }
}
