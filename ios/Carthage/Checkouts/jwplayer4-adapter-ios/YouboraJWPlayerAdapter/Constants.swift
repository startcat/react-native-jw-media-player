//
//  Constants.swift
//  YouboraJWPlayerAdapter
//
//  Created by Elisabet Massó on 27/1/22.
//  Copyright © 2022 NPAW. All rights reserved.
//

final class Constants {
    
    static private var jwPlayerAdapterVersion = "6.6.0"
    
    static func getAdapterName() -> String {
        return "\(getName())-\(getPlatform())"
    }
    
    static func getAdapterVersion() -> String {
        return "\(getVersion())-\(getAdapterName())"
    }
    
    static func getAdsAdapterName() -> String {
        return "\(getName())-Ads-\(getPlatform())"
    }
    
    static func getAdsAdapterVersion() -> String {
        return "\(getVersion())-\(getAdsAdapterName())"
    }
    
    static func getName(version: Bool = true) -> String {
        return version ? "JWPlayer4" : "JWPlayer"
    }
    
    static func getPlatform() -> String {
        #if os(tvOS)
            return "tvOS"
        #else
            return "iOS"
        #endif
    }
    
    static func getVersion() -> String {
        return jwPlayerAdapterVersion
    }
    
}
