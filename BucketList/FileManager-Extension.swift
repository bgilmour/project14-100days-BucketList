//
//  FileManager-Extension.swift
//  BucketList
//
//  Created by Bruce Gilmour on 2021-07-29.
//

import Foundation

extension FileManager {
    static func getUserDirectory(in directory: SearchPathDirectory = .documentDirectory) -> URL {
        // find all possible documents directories for this user
        let paths = Self.default.urls(for: directory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

    static func getUserFile(in directory: SearchPathDirectory = .documentDirectory, _ file: String) -> URL {
        return getUserDirectory(in: directory).appendingPathComponent(file)
    }

    static func decode<T: Codable>(in directory: SearchPathDirectory = .documentDirectory, _ file: String) -> T {
        let url = getUserFile(in: directory, file)

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)

        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }

        return loaded
    }
}
