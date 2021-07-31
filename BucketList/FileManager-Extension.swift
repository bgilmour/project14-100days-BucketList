//
//  FileManager-Extension.swift
//  BucketList
//
//  Created by Bruce Gilmour on 2021-07-29.
//

import Foundation

extension FileManager {
    func getUserDirectory(in directory: SearchPathDirectory = .documentDirectory) -> URL {
        // find all possible documents directories for this user
        let paths = self.urls(for: directory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

    func getUserFile(in directory: SearchPathDirectory = .documentDirectory, with file: String) -> URL {
        return getUserDirectory(in: directory).appendingPathComponent(file)
    }
}

extension FileManager {
    func decode<T: Codable>(in directory: SearchPathDirectory = .documentDirectory, from file: String) -> T? {
        do {
            let filename = getUserFile(in: directory, with: file)
            let data = try Data(contentsOf: filename)
            let loaded = try JSONDecoder().decode(T.self, from: data)
            return loaded
        } catch {
            print("Failed to decode data from \(file).")
        }
        return nil
    }

    func encode<T: Codable>(contents: T, in directory: SearchPathDirectory = .documentDirectory, to file: String) {
        do {
            let filename = getUserFile(in: directory, with: file)
            let data = try JSONEncoder().encode(contents)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Failed to encode data to \(file).")
        }
    }
}
