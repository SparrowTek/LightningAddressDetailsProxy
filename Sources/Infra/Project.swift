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
            "lightning-address-details",
            targetName: "API",
            url: .enabled(cors: true),
        )
        
        return [
            "lightning-address_details-proxy-function-name" : lambda.name,
            "URL" : lambda.url,
        ]
    }
}
