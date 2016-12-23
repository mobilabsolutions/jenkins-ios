//
// Created by Robert on 12.11.16.
// Copyright (c) 2016 MobiLab Solutions. All rights reserved.
//
@testable import JenkinsiOS
import XCTest

class FavoriteTests: ModelTestCase {
    func testInitializesCorrectly(){
        let favorite = Favorite(url: getGenericURL(), type: .job, account: getGenericAccount())

        assureValuesAreExpected(values: [
                (favorite.url, getGenericURL()),
                (favorite.type, Favorite.FavoriteType.job)
        ])
    }

    func testEqualityIsDeterminedCorrectly(){
        let firstFavorite = Favorite(url: getGenericURL().appendingPathComponent("test"), type: .job, account: getGenericAccount())
        let secondFavorite = Favorite(url: getGenericURL().appendingPathComponent("test"), type: .job, account: getGenericAccount())

        XCTAssertTrue(firstFavorite.isEqual(secondFavorite))

        secondFavorite.url.appendPathComponent("tooManyComponents")

        XCTAssertFalse(firstFavorite.isEqual(secondFavorite))

        secondFavorite.url = firstFavorite.url
        secondFavorite.type = .build

        XCTAssertFalse(firstFavorite.isEqual(secondFavorite))
    }

    func testIsProperlyInitializedFromEncodedData(){
        let favorite = Favorite(url: getGenericURL(), type: .job, account: getGenericAccount())
        let data = NSKeyedArchiver.archivedData(withRootObject: favorite)

        guard let unarchived = NSKeyedUnarchiver.unarchiveObject(with: data) as? Favorite
            else { XCTFail("The unarchived data should be a favorite"); return }

        XCTAssertTrue(unarchived.isEqual(favorite))
    }

    private func getGenericAccount() -> Account{
        return Account(baseUrl: getGenericURL(), username: nil, password: nil, port: nil, displayName: nil)
    }

    private func getGenericURL() -> URL{
        return URL(string: "https://www.test.com")!
    }
}
