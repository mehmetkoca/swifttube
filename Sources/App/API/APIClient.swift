//
//  APIClient.swift
//  App
//
//  Created by Ahmet Yalcinkaya on 02/12/2018.
//

import Foundation
import MongoKitten

class APIClient: APIProtocol {
    
    let database: Database?
    
    init(databaseUrl: String?) {
        if let url = databaseUrl {
            database = try? Database(url)
        } else {
            database = nil
            assert(false, "URL can not be nil")
        }
    }
    
    func getVideos() -> Array<Video>? {
        guard let database = database else { return nil }
        
        let lookupConferences = AggregationPipeline.Stage.lookup(from: "conferences", localField: "conferences", foreignField: "_id", as: "conferencesArray")
        let lookupSpeakers = AggregationPipeline.Stage.lookup(from: "users", localField: "users", foreignField: "_id", as: "speakersArray")

        let pipe = AggregationPipeline(arrayLiteral: lookupConferences, lookupSpeakers)
        
        let videos = try? Array(database["videos"].aggregate(pipe).makeIterator()).map({ document in
            return try BSONDecoder().decode(Video.self, from: document)
        })
        
        return videos
    }
    
    func getFeaturedVideos() -> Array<Video>? {
        guard let database = database else { return nil }
        
        let lookupConferences = AggregationPipeline.Stage.lookup(from: "conferences", localField: "conferences", foreignField: "_id", as: "conferencesArray")
        let lookupSpeakers = AggregationPipeline.Stage.lookup(from: "users", localField: "users", foreignField: "_id", as: "speakersArray")
        let matchFeatured = AggregationPipeline.Stage.match("featured" == true)
        
        let pipe = AggregationPipeline(arrayLiteral: matchFeatured, lookupConferences, lookupSpeakers)
        
        let videos = try? Array(database["videos"].aggregate(pipe).makeIterator()).map({ document in
            return try BSONDecoder().decode(Video.self, from: document)
        })
        return videos
    }
    
    func getVideo(shortUrl: String) -> Document? {
        guard let database = database else { return nil }

        guard let video = try? database["videos"].findOne("shortUrl" == shortUrl) else {
            return nil
        }
        return video
    }
    
    //MARK: - Speakers
    
    func getSpeakers() -> Array<Document>? {
        guard let database = database else { return nil }
        
        guard let speakers = try? Array(database["users"].find()) else {
            return nil
        }
        return speakers
    }
    
    func getSpeaker(shortUrl: String) -> Document? {
        guard let database = database else { return nil }
        
        guard let speaker = try? database["users"].findOne("shortname" == shortUrl) else {
            return nil
        }
        return speaker
    }
    
    func getSpeakerVideos(speakerId: Primitive) -> Array<Video>? {
        guard let database = database else { return nil }
        
        let lookupConferences = AggregationPipeline.Stage.lookup(from: "conferences", localField: "conferences", foreignField: "_id", as: "conferencesArray")
        let lookupSpeakers = AggregationPipeline.Stage.lookup(from: "users", localField: "users", foreignField: "_id", as: "speakersArray")
        
        let query: Query = [
            "users": [
                speakerId
            ]
        ]
        let matchQuery = AggregationPipeline.Stage.match(query)
        
        let pipe = AggregationPipeline(arrayLiteral: matchQuery, lookupConferences, lookupSpeakers)
        
        let videos = try? Array(database["videos"].aggregate(pipe).makeIterator()).map({ document in
            return try BSONDecoder().decode(Video.self, from: document)
        })
        return videos
    }
    
    func getConferences() -> Array<Document>? {
        guard let database = database else { return nil }
        
        guard let conferences = try? Array(database["conferences"].find()) else {
            return nil
        }
        return conferences
    }
    
    func getFeaturedConferences() -> Array<Document>? {
        guard let database = database else { return nil }
        
        guard let conferences = try? Array(database["conferences"].find("featured" == true)) else {
            return nil
        }
        return conferences
    }
    
    func getConference(shortUrl: String) -> Document? {
        guard let database = database else { return nil }
        
        guard let conference = try? database["conferences"].findOne("shortname" == shortUrl) else {
            return nil
        }
        return conference
    }
    
    func getConferenceVideos(conferenceId: Primitive) -> Array<Video>? {
        guard let database = database else { return nil }
        
        let lookupConferences = AggregationPipeline.Stage.lookup(from: "conferences", localField: "conferences", foreignField: "_id", as: "conferencesArray")
        let lookupSpeakers = AggregationPipeline.Stage.lookup(from: "users", localField: "users", foreignField: "_id", as: "speakersArray")
        let matchQuery = AggregationPipeline.Stage.match("conferences" == conferenceId)
        
        let pipe = AggregationPipeline(arrayLiteral: matchQuery, lookupConferences, lookupSpeakers)
        
        let videos = try? Array(database["videos"].aggregate(pipe).makeIterator()).map({ document in
            return try BSONDecoder().decode(Video.self, from: document)
        })
        return videos
    }
    
    func getTagVideos(tag: String) -> Array<Video>? {
        guard let database = database else { return nil }
        
        let lookupConferences = AggregationPipeline.Stage.lookup(from: "conferences", localField: "conferences", foreignField: "_id", as: "conferencesArray")
        let lookupSpeakers = AggregationPipeline.Stage.lookup(from: "users", localField: "users", foreignField: "_id", as: "speakersArray")
        
        let query: Query = [
            "tags": [
                tag
            ]
        ]
        let matchQuery = AggregationPipeline.Stage.match(query)
        
        let pipe = AggregationPipeline(arrayLiteral: matchQuery, lookupConferences, lookupSpeakers)
        
        let videos = try? Array(database["videos"].aggregate(pipe).makeIterator()).map({ document in
            return try BSONDecoder().decode(Video.self, from: document)
        })
        return videos
    }
}
