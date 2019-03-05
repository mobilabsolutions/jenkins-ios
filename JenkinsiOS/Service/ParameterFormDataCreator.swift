//
//  ParameterFormDataCreator.swift
//  JenkinsiOS
//
//  Created by Robert on 04.03.19.
//  Copyright © 2019 MobiLab Solutions. All rights reserved.
//

import Foundation

fileprivate protocol FormDataProvider {
    var formDataPart: Data? { get }
}

class ParameterFormDataCreator {
    private struct JsonEnabledParameterValue: Encodable {
        let name: String
        let valueOrFile: String?
        let parameterType: ParameterType

        private enum CodingKeys: String, CodingKey {
            case name
            case value
            case file
            case runId
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)

            switch parameterType {
            case .file:
                try container.encode(valueOrFile, forKey: .file)
            case .run:
                try container.encode(valueOrFile, forKey: .runId)
            default:
                try container.encode(valueOrFile, forKey: .value)
            }
        }
    }

    private struct JsonEnabledParameters: Encodable {
        let parameter: [JsonEnabledParameterValue]
    }

    private struct FileFormDataProvider: FormDataProvider {
        let filePath: String
        let name: String

        var formDataPart: Data? {
            let fileUrl = URL(fileURLWithPath: filePath)
            guard let fileContent = try? Data(contentsOf: fileUrl),
                let fileComponent = URL(string: filePath)?.lastPathComponent
            else { return nil }
            var data = "Content-Type: application/octet-stream\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileComponent)\"\r\n\r\n".data(using: .utf8)
            data?.append(fileContent)

            return data
        }
    }

    private struct ValueFormDataProvider: FormDataProvider {
        let name: String
        let value: String

        var formDataPart: Data? {
            return "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)".data(using: .utf8)
        }
    }

    func formData(for parameterValues: [ParameterValue]) -> (boundary: String, data: Data?) {
        let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"

        guard let json = createJson(for: parameterValues), let jsonString = String(data: json, encoding: .utf8),
            let boundaryData = "--\(boundary)".data(using: .utf8),
            let separatorData = "\r\n".data(using: .utf8),
            let endSeparatorData = "--".data(using: .utf8)
        else { return (boundary: boundary, data: nil) }

        let formDataProviders: [FormDataProvider] = parameterValues
            .filter { $0.parameter.type == .file && $0.value != nil }
            .enumerated()
            .map { FileFormDataProvider(filePath: $0.element.value!, name: "file\($0.offset)") }
            + [ValueFormDataProvider(name: "json", value: jsonString)]

        var data = Data()

        for provider in formDataProviders {
            if let providedData = provider.formDataPart {
                data.append(boundaryData)
                data.append(separatorData)
                data.append(providedData)
                data.append(separatorData)
            }
        }

        data.append(boundaryData)
        data.append(endSeparatorData)

        return (boundary: boundary, data: data)
    }

    private func createJson(for parameterValues: [ParameterValue]) -> Data? {
        let encoder = JSONEncoder()
        var currentFile = 0
        let parameters = parameterValues.map { param -> ParameterFormDataCreator.JsonEnabledParameterValue in
            if param.parameter.type == .file {
                let ret = JsonEnabledParameterValue(name: param.parameter.name, valueOrFile: "file\(currentFile)", parameterType: param.parameter.type)
                currentFile += 1
                return ret
            } else {
                return JsonEnabledParameterValue(name: param.parameter.name, valueOrFile: param.value, parameterType: param.parameter.type)
            }
        }

        return try? encoder.encode(JsonEnabledParameters(parameter: parameters))
    }
}
