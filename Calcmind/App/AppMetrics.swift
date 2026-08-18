import Foundation
import MetricKit
import OSLog

/// MetricKit subscriber for TestFlight crash and performance telemetry.
@MainActor
final class AppMetrics: NSObject, MXMetricManagerSubscriber {
    static let shared = AppMetrics()

    private let logger = Logger(subsystem: "com.Calcmind", category: "MetricKit")

    func register() {
        MXMetricManager.shared.add(self)
    }

    nonisolated func didReceive(_ payloads: [MXMetricPayload]) {
        Task { @MainActor in
            for payload in payloads {
                logger.info("Received MetricKit performance payload")
                #if DEBUG
                logger.debug("\(payload.dictionaryRepresentation().description, privacy: .public)")
                #endif
            }
        }
    }

    nonisolated func didReceive(_ payloads: [MXDiagnosticPayload]) {
        Task { @MainActor in
            for payload in payloads {
                if payload.crashDiagnostics?.isEmpty == false {
                    logger.error("Received MetricKit crash diagnostic")
                }
                if payload.hangDiagnostics?.isEmpty == false {
                    logger.warning("Received MetricKit hang diagnostic")
                }
                #if DEBUG
                logger.debug("\(payload.dictionaryRepresentation().description, privacy: .public)")
                #endif
            }
        }
    }
}
