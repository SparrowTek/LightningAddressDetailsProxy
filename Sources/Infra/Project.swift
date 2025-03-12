//
//  Project.swift
//  LightningAddressDetailsProxy
//
//  Created by Thomas Rademaker on 3/10/25.
//

import Cloud

@main
struct LightningAddressDetailsProxy: AWSProject {
    func build() async throws -> Outputs {
        
        let lambda = AWS.Function(
            "api",
            targetName: "Api"
        )
        
//        return ["url" : server.url]
        return [:]
    }
}
