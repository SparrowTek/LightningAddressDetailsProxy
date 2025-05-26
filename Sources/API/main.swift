//
//  Untitled.swift
//  LightningAddressDetailsProxy
//
//  Created by Thomas Rademaker on 3/10/25.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import CloudSDK
import AWSLambdaRuntime
import AWSLambdaEvents
import AsyncHTTPClient
import HTTPTypes


let runtime = LambdaRuntime { (event: APIGatewayV2Request, context: LambdaContext) -> APIGatewayV2Response in
    
    return await handle(event, context: context)
    
    
    // let (statusCode, responseBody) = await generateInvoiceHandler(queryParams: event.queryStringParameters)
    // print("STATUS CODE: \(statusCode)")
    // print("RESPONSE BODY: \(responseBody)")
    // return APIGatewayV2Response(statusCode: HTTPResponse.Status(code: statusCode), body: responseBody)

    
    
    
//    let body = event.queryStringParameters
//    .map { "\($0.key) : \($0.value)" }
//    .joined(separator: ", ")
//
//    return APIGatewayV2Response(statusCode: HTTPResponse.Status(code: 200), body: body)
}

try await runtime.run()

//enum NetworkError: Error {
//    case invalidResponse
//    case invalidFormat(String)
//}
//
//struct GIResponse: Codable {
//    var invoice: String?
//}

//private func encodeResponse(_ response: GIResponse) -> String {
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//    guard let data = try? encoder.encode(response), let jsonString = String(data: data, encoding: .utf8) else { return "{}" }
//    return jsonString
//}

//func generateInvoiceHandler(queryParams: [String: String]) async -> (statusCode: Int, responseBody: String) {
//    print("QUERY PARAMS: \(queryParams)")
//    var responseBody = GIResponse(invoice: nil)
//    guard let ln = queryParams["ln"] else { return (400, encodeResponse(responseBody)) }
//    
//    let lnurlpUrl: String
//    do {
//        lnurlpUrl = try lnurlpWellKnown(identifier: ln)
//    } catch {
//        return (400, encodeResponse(responseBody))
//    }
//    
//    let lnurlpJson: String
//    do {
//        lnurlpJson = try await getJSON(for: lnurlpUrl)
//    } catch {
//        print("Failed to fetch lnurlp response for lightning address \(ln) from \(lnurlpUrl): \(error)")
//        return (400, encodeResponse(responseBody))
//    }
//    
//    guard let lnurlpData = lnurlpJson.data(using: .utf8),
//          let lnurlpDict = try? JSONSerialization.jsonObject(with: lnurlpData, options: []) as? [String: Any],
//          let callbackUrlString = lnurlpDict["callback"] as? String else {
//        return (400, encodeResponse(responseBody))
//    }
//    
//    var invoiceParams = queryParams
//    invoiceParams.removeValue(forKey: "ln")
//    
//    guard var invoiceUrlComponents = URLComponents(string: callbackUrlString) else {
//        print("Failed to parse callback URL: \(callbackUrlString) for lightning address \(ln)")
//        return (400, encodeResponse(responseBody))
//    }
//    
//    var queryItems = invoiceUrlComponents.queryItems ?? []
//    for (key, value) in invoiceParams {
//        queryItems.append(URLQueryItem(name: key, value: value))
//    }
//    invoiceUrlComponents.queryItems = queryItems
//    
//    guard let finalInvoiceUrl = invoiceUrlComponents.url?.absoluteString else {
//        return (400, encodeResponse(responseBody))
//    }
//    
//    let invoiceJson: String
//    do {
//        invoiceJson = try await getJSON(for: finalInvoiceUrl)
//    } catch {
//        print("Failed to fetch invoice for lightning address \(ln) from \(finalInvoiceUrl): \(error)")
//        return (400, encodeResponse(responseBody))
//    }
//    
//    responseBody.invoice = invoiceJson
//    return (200, encodeResponse(responseBody))
//}

//private func getJSON(for url: String) async throws -> String {
//    var url = url
//    updateURLForAlby(&url)
//    let request = HTTPClientRequest(url: url)
//    let response = try await HTTPClient.shared.execute(request, timeout: .seconds(30))
//    
//    switch response.status {
//    case .ok:
//        let buffer = try await response.body.collect(upTo: 1024 * 1024)
//        return String(buffer: buffer)
//    default: throw NetworkError.invalidResponse
//    }
//}

//private func updateURLForAlby(_ url: inout String) {
//   let urlPrefix = "https://getalby.com"
//   let replacement = "http://alby-mainnet-getalbycom"
//   url.replace(urlPrefix, with: replacement, maxReplacements: 1)
//}
//
//func lnurlpWellKnown(identifier: String) throws -> String {
//    let parts = identifier.split(separator: "@")
//    guard parts.count == 2 else { throw NetworkError.invalidFormat(identifier) }
//    let username = parts[0]
//    let domain = parts[1]
//    return "https://\(domain)/.well-known/lnurlp/\(username)"
//}

//struct GenerateInvoiceRequest: Codable {
//    let queryStringParameters: [String: String]?
//}
//
//struct GenerateInvoiceResponse: Codable {
//    let statusCode: Int
//    let headers: [String: String]
//    let body: String
//}
//
struct LNURLpResponse: Codable {
    let callback: String
}

//struct InvoiceResponse: Codable {
//    let invoice: [String: Any]?
//}

func toUrl(identifier: String) throws -> (lnurlpUrl: String, keysendUrl: String, nostrUrl: String) {
    let parts = identifier.split(separator: "@")
    guard parts.count == 2 else {
        throw NSError(domain: "InvalidLightningAddress", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid lightning address"])
    }
    
    let domain = String(parts[1])
    let username = String(parts[0])
    
    let lnurlpUrl = "https://\(domain)/.well-known/lnurlp/\(username)"
    let keysendUrl = "https://\(domain)/.well-known/keysend/\(username)"
    let nostrUrl = "https://\(domain)/.well-known/nostr.json?name=\(username)"
    
    return (lnurlpUrl, keysendUrl, nostrUrl)
}

func getJSON(url: String) async throws -> (data: Data, response: HTTPURLResponse) {
    guard let url = URL(string: url) else {
        throw NSError(domain: "InvalidURL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NSError(domain: "InvalidResponse", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
    }
    
    return (data, httpResponse)
}

//struct GenerateInvoiceHandler: LambdaHandler {
//    typealias Event = APIGatewayV2Request
//    typealias Output = APIGatewayV2Response
    
    func handle(_ event: APIGatewayV2Request, context: LambdaContext) async -> APIGatewayV2Response {
        guard let ln = event.queryStringParameters["ln"] else {
            return APIGatewayV2Response(statusCode: .badRequest, body: "Missing lightning address parameter")
        }
        
        do {
            let (lnurlpUrl, _, _) = try toUrl(identifier: ln)
            
            // Get LNURLp data
            let (lnurlpData, lnurlpResponse) = try await getJSON(url: lnurlpUrl)
            
            guard lnurlpResponse.statusCode < 300 else {
                return APIGatewayV2Response(statusCode: .init(code: lnurlpResponse.statusCode))
            }
            
            // Decode LNURLp response
            let lnurlp = try JSONDecoder().decode(LNURLpResponse.self, from: lnurlpData)
            
            // Construct invoice URL with query parameters
            guard let callbackUrl = URL(string: lnurlp.callback) else {
                return APIGatewayV2Response(statusCode: .badRequest, body: "Invalid callback URL")
            }
            
            var components = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: true)!
            components.queryItems = event.queryStringParameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
            
            guard let invoiceUrl = components.url else {
                return APIGatewayV2Response(statusCode: .badRequest, body: "Failed to construct invoice URL")
            }
            
            // Get invoice
            let (invoiceData, invoiceResponse) = try await getJSON(url: invoiceUrl.absoluteString)
            
            guard invoiceResponse.statusCode < 300 else {
                return APIGatewayV2Response(statusCode: .init(code: invoiceResponse.statusCode))
            }
            
            // Return invoice response
            return APIGatewayV2Response(
                statusCode: .ok,
                headers: ["Content-Type": "application/json"],
                body: String(data: invoiceData, encoding: .utf8) ?? "{}"
            )
            
        } catch {
            return APIGatewayV2Response(
                statusCode: .badRequest,
                body: "Error: \(error.localizedDescription)"
            )
        }
    }
//}
