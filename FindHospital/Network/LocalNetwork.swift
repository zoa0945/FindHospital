//
//  LocalNetwork.swift
//  FindHospital
//
//  Created by zoa0945 on 2023/06/21.
//

import RxSwift

class LocalNetwork {
    private let session: URLSession
    let api = LocalAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getLocation(by mapPoint: MTMapPoint) -> Single<Result<LocationData, URLError>> {
        guard let url = api.getLocation(by: mapPoint).url else {
            return .just(.failure(URLError(.badURL)))
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK f5b9c918b323b5cb289b1b1563b262f3", forHTTPHeaderField: "Authorization")
        
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do {
                    let decoder = JSONDecoder()
                    let locationData = try decoder.decode(LocationData.self, from: data)
                    return .success(locationData)
                } catch {
                    return .failure(URLError(.cannotParseResponse))
                }
            }
            .catch({ _ in
                return .just(.failure(URLError(.cannotLoadFromNetwork)))
            })
            .asSingle()
    }
}
