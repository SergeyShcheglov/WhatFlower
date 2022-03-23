//
//  WikipediaData.swift
//  WhatFlower
//
//  Created by Sergey Shcheglov on 02.01.2022.
//

import Foundation

struct WikipediaData: Codable {
    let lead: Lead
}

struct Lead: Codable {
    let sections: Sections
}

struct Sections: Codable {
    let text: String
}
