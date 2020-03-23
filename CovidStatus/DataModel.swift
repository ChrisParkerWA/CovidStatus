//
//  DataModel.swift
//  CovidStatus
//
//  Created by Chris Parker on 16/3/20.
//  Copyright © 2020 Chris Parker. All rights reserved.
//


import Foundation

struct CovidCases: Codable {
    struct Entry: Codable, Hashable, Identifiable, Comparable {
        static func < (lhs: CovidCases.Entry, rhs: CovidCases.Entry) -> Bool {
            lhs.country < lhs.country
        }
        
        let id = UUID()
        let country: String
        let cases: String
        let deaths: String
        let recovered: String
        let lastupdated: String?
        let comments: String?
    }

    let entries: [Entry]
    
    // Data URL: https://interactive-static.scmp.com/sheet/wuhan/viruscases.json
}

struct BingCases: Codable {
    
    struct Area: Codable, Hashable, Identifiable, Comparable {
        static func < (lhs: BingCases.Area, rhs: BingCases.Area) -> Bool {
            lhs.displayName < rhs.displayName
        }
        
        let id: String
        let displayName: String // country
        let totalConfirmed: Int // cases
        let totalDeaths: Int    // deaths
        let totalRecovered: Int  // recovered
        
    }
    
    let areas: [Area]
    
    // Data URL: https://www.bing.com/covid/data
}









