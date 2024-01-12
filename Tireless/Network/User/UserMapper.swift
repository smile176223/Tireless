//
//  UserMapper.swift
//  Tireless
//
//  Created by Hao on 2023/11/28.
//

import Foundation

public struct UserItem: Hashable, Codable {
    public let id: String
    public let email: String
    public let name: String
    public let picture: String?
    
    public init(id: String, email: String, name: String, picture: String?) {
        self.id = id
        self.email = email
        self.name = name
        self.picture = picture
    }
}

public final class UserMapper {
    private struct RemoteUser: Decodable {
        let userId: String
        let email: String
        let name: String
        let picture: String?
        
        var item: UserItem {
            UserItem(id: userId, email: email, name: name, picture: picture)
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data) throws -> UserItem {
        guard let data = try? JSONDecoder().decode(RemoteUser.self, from: data) else {
            throw Error.invalidData
        }
        return data.item
    }
}
