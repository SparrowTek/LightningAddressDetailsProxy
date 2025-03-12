//
//  Untitled.swift
//  LightningAddressDetailsProxy
//
//  Created by Thomas Rademaker on 3/10/25.
//

import SotoLambda
import AsyncHTTPClient

let client = AWSClient(credentialProvider: .default)
//Lambda(client: client).invoke(<#T##input: Lambda.InvocationRequest##Lambda.InvocationRequest#>)

private func execute() async throws {
    
}


private func getJSON(for url: String) async throws {
    var url = url
    updateURLForAlby(&url)
    
}

private func updateURLForAlby(_ url: inout String) {
    let urlPrefix = "https://getalby.com"
    let replacement = "http://alby-mainnet-getalbycom"
    url.replace(urlPrefix, with: replacement, maxReplacements: 1)
}

private func get(_ url: String) async throws {
    let request = HTTPClientRequest(url: url)
    let response = try await HTTPClient.shared.execute(request, timeout: .seconds(30))
    print("HTTP head", response)
    if response.status == .ok {
        let body = try await response.body.collect(upTo: 1024 * 1024) // 1 MB
        // handle body
    } else {
        // handle remote error
    }
}

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
