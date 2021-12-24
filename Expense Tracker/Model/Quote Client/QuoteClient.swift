//
//  QuoteClient.swift
//  Expense Tracker
//
//  Created by Han Hlaing Moe on 24/12/2021.
//

import Foundation

class QuoteClient {
    
    // MARK: - Endpoints
    enum Endpoints {
        
        static let base = "https://api.quotable.io/random"
        
        case getQuote
        
        var urlString: String {
            
            switch self {
            case .getQuote : return Endpoints.base
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    // MARK: - Reusable Requests and Responses
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask{
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    // Get quote
    class func getQuote(completion: @escaping (Quote?, Error?) -> Void){
        
        let url = Endpoints.getQuote.url
        
        taskForGETRequest(url: url, responseType: Quote.self){ response, error in
            
            if let response = response {
                completion(response ,nil)
            } else {
                completion(nil,error)
            }
        }
    }
    
}
