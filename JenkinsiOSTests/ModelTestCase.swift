//
//  ModelTestCase.swift
//  JenkinsiOS
//
//  Created by Robert on 27.10.16.
//  Copyright © 2016 MobiLab Solutions. All rights reserved.
//

import XCTest

class ModelTestCase: XCTestCase {
    
    func jsonForResource(name: String, extension fileExtension: String?, type: AnyClass) -> Any?{
        guard let url = Bundle(for: type).url(forResource: name, withExtension: fileExtension)
            else { XCTFail("Bundle URL could not be found"); return nil }
        guard let data = try? Data(contentsOf: url)
            else { XCTFail("Could not get data for resource file"); return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            else { XCTFail("Could not get json in correct format"); return nil }
        return json
    }
    
}
