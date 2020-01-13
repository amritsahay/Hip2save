////
////  XMLParser.swift
////  Hip2Save
////
////  Created by Shashwat B on 01/10/19.
////  Copyright © 2019 Hip Happenings. All rights reserved.
////
//
//import Foundation
//import XMLMapper
//
//class CommentParser: XMLMappable{
//    var nodeName: String!
//    var item: [Items]?
//    required init?(map: XMLMap) {
//
//    }
//    func mapping(map: XMLMap) {
//        item <- map["Items"]
//    }
//
//
//}
//
//class Items: XMLMappable {
//    required init?(map: XMLMap) {
//        <#code#>
//    }
//
//    var nodeName: String!
//
//    var title: String
//    var link: String
//    var creator: String
//    var pubDate: String
//    var guid: String
//    //    var guidisPermaLink: String
//    //    var guidtext: String
//    var description: String
//    var encoded: String
//    var commentID: String
//    var commentParent: String
//    var commentAdmin: String
//
//    func mapping(map: XMLMap) {
//        title <- map["title"]
//        link <- map["link"]
//        creator <- map["creator"]
//        pubDate <- map["pubDate"]
//        guid <- map["guid"]
//        //    var guidisPermaLink: String
//        //    var guidtext: String
//        description <- map["description"]
//        encoded <- map["encoded"]
//        commentID <- map["commentID"]
//        commentParent <- map["commentParent"]
//        commentAdmin <- map["commentAdmin"]
//    }
//
//
//
//
//}
