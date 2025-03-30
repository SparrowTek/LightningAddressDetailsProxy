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
import HTTPTypes


let runtime = LambdaRuntime { (event: APIGatewayV2Request, context: LambdaContext) -> APIGatewayV2Response in
    let (statusCode, responseBody) = await generateInvoiceHandler(queryParams: event.queryStringParameters)
    return APIGatewayV2Response(statusCode: HTTPResponse.Status(code: statusCode), body: responseBody)
}

try await runtime.run()

enum NetworkError: Error {
    case invalidResponse
    case invalidFormat(String)
}

struct GIResponse: Codable {
    var invoice: String?
}

private func encodeResponse(_ response: GIResponse) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let data = try? encoder.encode(response), let jsonString = String(data: data, encoding: .utf8) else { return "{}" }
    return jsonString
}

func generateInvoiceHandler(queryParams: [String: String]) async -> (statusCode: Int, responseBody: String) {
    var responseBody = GIResponse(invoice: nil)
    guard let ln = queryParams["ln"] else { return (400, encodeResponse(responseBody)) }
    
    let lnurlpUrl: String
    do {
        lnurlpUrl = try lnurlpWellKnown(identifier: ln)
    } catch {
        return (400, encodeResponse(responseBody))
    }
    
    let lnurlpJson: String
    do {
        lnurlpJson = try await getJSON(for: lnurlpUrl)
    } catch {
        print("Failed to fetch lnurlp response for lightning address \(ln) from \(lnurlpUrl): \(error)")
        return (400, encodeResponse(responseBody))
    }
    
    guard let lnurlpData = lnurlpJson.data(using: .utf8),
          let lnurlpDict = try? JSONSerialization.jsonObject(with: lnurlpData, options: []) as? [String: Any],
          let callbackUrlString = lnurlpDict["callback"] as? String else {
        return (400, encodeResponse(responseBody))
    }
    
    var invoiceParams = queryParams
    invoiceParams.removeValue(forKey: "ln")
    
    guard var invoiceUrlComponents = URLComponents(string: callbackUrlString) else {
        print("Failed to parse callback URL: \(callbackUrlString) for lightning address \(ln)")
        return (400, encodeResponse(responseBody))
    }
    
    var queryItems = invoiceUrlComponents.queryItems ?? []
    for (key, value) in invoiceParams {
        queryItems.append(URLQueryItem(name: key, value: value))
    }
    invoiceUrlComponents.queryItems = queryItems
    
    guard let finalInvoiceUrl = invoiceUrlComponents.url?.absoluteString else {
        return (400, encodeResponse(responseBody))
    }
    
    let invoiceJson: String
    do {
        invoiceJson = try await getJSON(for: finalInvoiceUrl)
    } catch {
        print("Failed to fetch invoice for lightning address \(ln) from \(finalInvoiceUrl): \(error)")
        return (400, encodeResponse(responseBody))
    }
    
    responseBody.invoice = invoiceJson
    return (200, encodeResponse(responseBody))
}

private func getJSON(for url: String) async throws -> String {
    var url = url
    updateURLForAlby(&url)
    let request = HTTPClientRequest(url: url)
    let response = try await HTTPClient.shared.execute(request, timeout: .seconds(30))
    
    switch response.status {
    case .ok:
        let buffer = try await response.body.collect(upTo: 1024 * 1024)
        return String(buffer: buffer)
    default: throw NetworkError.invalidResponse
    }
}

private func updateURLForAlby(_ url: inout String) {
   let urlPrefix = "https://getalby.com"
   let replacement = "http://alby-mainnet-getalbycom"
   url.replace(urlPrefix, with: replacement, maxReplacements: 1)
}

func lnurlpWellKnown(identifier: String) throws -> String {
    let parts = identifier.split(separator: "@")
    guard parts.count == 2 else { throw NetworkError.invalidFormat(identifier) }
    let username = parts[0]
    let domain = parts[1]
    return "https://\(domain)/.well-known/lnurlp/\(username)"
}
