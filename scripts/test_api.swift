#!/usr/bin/env swift
// 验证 PATH API 可连通性 + JSON 解析逻辑
// 运行: swift scripts/test_api.swift

import Foundation

struct RidePathResponse: Decodable {
    let results: [StationResult]
}
struct StationResult: Decodable {
    let consideredStation: String
    let destinations: [DestinationResult]
}
struct DestinationResult: Decodable {
    let label: String
    let messages: [MessageResult]
}
struct MessageResult: Decodable {
    let target: String
    let secondsToArrival: String
    let lineColor: String
    let headSign: String
    let lastUpdated: String
}

let timestamp = Int(Date().timeIntervalSince1970 * 1000)
let url = URL(string: "https://www.panynj.gov/bin/portauthority/ridepath.json?timeStamp=\(timestamp)")!

let semaphore = DispatchSemaphore(value: 0)

URLSession.shared.dataTask(with: url) { data, response, error in
    defer { semaphore.signal() }

    if let error = error {
        print("❌ 网络错误: \(error.localizedDescription)")
        return
    }
    guard let data = data else { print("❌ 无数据"); return }

    do {
        let decoded = try JSONDecoder().decode(RidePathResponse.self, from: data)
        print("✅ 成功解析 \(decoded.results.count) 个站台\n")

        for station in decoded.results {
            print("📍 \(station.consideredStation)")
            for dest in station.destinations {
                for msg in dest.messages.prefix(1) {
                    let secs = Int(msg.secondsToArrival) ?? 0
                    print("   \(dest.label)  →  \(msg.headSign)  [\(secs/60) min]  #\(msg.lineColor)")
                }
            }
        }
    } catch {
        print("❌ JSON 解析失败: \(error)")
        if let str = String(data: data, encoding: .utf8) {
            print("原始响应前300字符: \(str.prefix(300))")
        }
    }
}.resume()

semaphore.wait()
