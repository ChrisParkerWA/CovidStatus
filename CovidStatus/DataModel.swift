//
//  DataModel.swift
//  CovidStatus
//
//  Created by Chris Parker on 16/3/20.
//  Copyright © 2020 Chris Parker. All rights reserved.
//


import Foundation

struct SCMPCases: Codable {
    
    let last_updated: String
    
    struct Entry: Codable, Hashable, Comparable {
        static func < (lhs: SCMPCases.Entry, rhs: SCMPCases.Entry) -> Bool {
            lhs.country < lhs.country
        }
        
        let continent: String
        let country: String
        let cases: String
        let deaths: String
        let recovered: String
        let lastupdated: String?
    }

    let entries: [Entry]
    
    // Data URL: https://interactive-static.scmp.com/sheet/wuhan/viruscases.json
}

struct BingCases: Codable {
    
    let lastUpdated: String
    
    struct Area: Codable, Hashable, Comparable {
        static func < (lhs: BingCases.Area, rhs: BingCases.Area) -> Bool {
            lhs.displayName < rhs.displayName
        }
        
        let displayName: String // country
        let totalConfirmed: Int // cases
        let totalDeaths: Int?    // deaths
        let totalRecovered: Int?  // recovered
        let lastUpdated: String?
        
    }
    
    let areas: [Area]
    
    // Data URL: https://www.bing.com/covid/data
}

struct Country: Codable, Hashable, Identifiable, Comparable {
    static func < (lhs: Country, rhs: Country) -> Bool {
        lhs.country < rhs.country
    }
    let id = UUID()
    let country: String
    let cases: Double
    let deaths: Double
    let recovered: Double
}







