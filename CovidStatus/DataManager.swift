//
//  DataManager.swift
//  CovidStatus
//
//  Created by Chris Parker on 16/3/20.
//  Copyright © 2020 Chris Parker. All rights reserved.
//


import Foundation

extension FileManager {
    func getDocumentsDirectory() -> URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func writeData<T: Codable>(contents: T, filename: String) -> Bool {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(contents) {
            let success = FileManager.default.createFile(atPath: url.path, contents: encoded, attributes: nil)
            if !success {
                return false
            }
        } else {
            fatalError("Unable to endode Data from: \(filename)")
        }
        return true
    }

}

class DataManager {
    
    func fetchData<T: Codable>(urlString: String) -> T? {
        let url = URL(string: urlString)
        guard let data = try? Data(contentsOf: url!) else {
            print("Unable to retrieve data from: \(urlString)")
            return nil
        }
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(T.self, from: data) else {
            print("Unable to decode data from: \(urlString)")
            return nil
        }
        return decodedData
    }
    
    func getJSON<T: Decodable>(urlString: String, completion: @escaping (T?) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            guard let data = data else {
                completion(nil)
                return
            }
            let decoder = JSONDecoder()
            guard let decodedData = try? decoder.decode(T.self, from: data) else {
                completion(nil)
                return
            }
            
            completion(decodedData)
        }.resume()        
    }
    
}
