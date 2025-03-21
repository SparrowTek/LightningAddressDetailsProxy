//
//  Untitled.swift
//  LightningAddressDetailsProxy
//
//  Created by Thomas Rademaker on 3/10/25.
//

import Foundation
import CloudSDK
import AWSLambdaRuntime
import AWSLambdaEvents
import AsyncHTTPClient


let runtime = LambdaRuntime { (event: APIGatewayV2Request, context: LambdaContext) -> APIGatewayV2Response in
    let response = try await getJSON(for: event.rawQueryString)
    return APIGatewayV2Response(
        statusCode: .ok,
        body: response
    )
}

try await runtime.run()

public struct InvoiceResponse: Decodable {
    let invoice: Invoice
}

public struct Invoice: Decodable {
    let pr: String
//    let routes: []
    let status: String?
    let successAction: InvoiceSuccessAction?
    let verify: String
}

public struct InvoiceSuccessAction: Decodable {
    let message: String?
    let tag: String?
}

//private func getJSON<T: Decodable>(for url: String) async throws -> T {
private func getJSON(for url: String) async throws -> String {
    var url = url
    updateURLForAlby(&url)
    let request = HTTPClientRequest(url: url)
    let response = try await HTTPClient.shared.execute(request, timeout: .seconds(30))
    
    switch response.status {
    case .ok:
        let contentType = response.headers.first(name: "content-type")
        let buffer = try await response.body.collect(upTo: 1024 * 1024)
        return String(buffer: buffer)
//        let buffer = try await response.body.collect(upTo: 1024 * 1024)
//        return try JSONDecoder().decode(T.self, from: buffer)
    default: throw NetworkError.invalidResponse
    }
}

enum NetworkError: Error {
    case badBuffer
    case invalidResponse
//    case invalidURL
//    case httpError(statusCode: Int, message: String)
//    case jsonDecodingError(Error)
}


private func updateURLForAlby(_ url: inout String) {
   let urlPrefix = "https://getalby.com"
   let replacement = "http://alby-mainnet-getalbycom"
   url.replace(urlPrefix, with: replacement, maxReplacements: 1)
}


//
//private func get(_ url: String) async throws {
//    let request = HTTPClientRequest(url: url)
//    let response = try await HTTPClient.shared.execute(request, timeout: .seconds(30))
//    print("HTTP head", response)
//    if response.status == .ok {
//        let body = try await response.body.collect(upTo: 1024 * 1024) // 1 MB
//        // handle body
//    } else {
//        // handle remote error
//    }
//}

//try await execute()

//struct GetJSONParams {
//    let url: String
////    wg  *sync.WaitGroup
//}


//func GetJSON(p GetJSONParams) (interface{}, *http.Response, error) {
//    if p.wg != nil {
//        defer p.wg.Done()
//    }
//
//    urlPrefix := "https://getalby.com"
//    replacement := "http://alby-mainnet-getalbycom"
//
//    url := strings.Replace(p.url, urlPrefix, replacement, 1)
//
//    response, err := http.Get(url)
//    if err != nil || response.StatusCode > 300 {
//        return nil, response, fmt.Errorf("no details: %s - %v", p.url, err)
//    } else {
//        defer response.Body.Close()
//        var j interface{}
//        err = json.NewDecoder(response.Body).Decode(&j)
//        if err != nil {
//            return nil, response, fmt.Errorf("invalid JSON: %v", err)
//        } else {
//            return j, response, nil
//        }
//    }
//}
