//
//  Tumbleweed.swift
//  NRK
//
//  Created by Johan Sørensen on 06/04/2017.
//  Copyright © 2017 NRK. All rights reserved.
//

import Foundation

/// An object that is capable of collection metrics based on a given set of URLSessionTaskMetrics
@available(iOS 10.0, macOS 10.12, tvOS 10.0, *)
@objc public class SessionMetrics: NSObject {
    public let task: URLSessionTask
    public let metrics: [Metric]
    public let redirectCount: Int
    public let taskInterval: DateInterval

    public init(source sessionTaskMetrics: URLSessionTaskMetrics, task: URLSessionTask) {
        self.task = task
        self.redirectCount = sessionTaskMetrics.redirectCount
        self.taskInterval = sessionTaskMetrics.taskInterval
        self.metrics = sessionTaskMetrics.transactionMetrics.map(Metric.init(transactionMetrics:))
    }

    public func render(with renderer: Renderer) {
        renderer.render(with: self)
    }
}

/// Convenience object that can be used as the delegate for a URLSession
/// eg let session = URLSession(configuration: .default, delegate: SessionMetricsLogger(), delegateQueue: nil)
@available(iOS 10.0, macOS 10.12, tvOS 10.0, *)
public final class SessionMetricsLogger: NSObject, URLSessionTaskDelegate {
    let renderer = ConsoleRenderer()
    var enabled = true

    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard enabled else { return }

        let gatherer = SessionMetrics(source: metrics, task: task)
        renderer.render(with: gatherer)
    }
}
