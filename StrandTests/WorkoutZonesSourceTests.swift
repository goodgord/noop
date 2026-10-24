import XCTest
import WhoopStore
@testable import Strand

/// Apple Health workouts now carry a stored zone split worked out from their HealthKit heart rate, so the
/// Workouts summary counts how many of its sessions are Apple Health ones. The card's label is chosen from
/// that count and must not call an Apple Health split a WHOOP import.
final class WorkoutZonesSourceTests: XCTestCase {

    private func row(_ start: Int, source: String, zones: String?) -> WorkoutRow {
        WorkoutRow(startTs: start, endTs: start + 1800, sport: "Running", source: source,
                   durationS: 1800, energyKcal: nil, avgHr: nil, maxHr: nil, strain: nil,
                   distanceM: nil, zonesJSON: zones, notes: nil, steps: nil)
    }

    func testSummaryCountsAppleHealthSessions() {
        let s = WorkoutZones.summary(from: [
            row(0, source: "whoop", zones: #"{"z1":100}"#),
            row(10_000, source: "apple-health", zones: #"{"z2":50.0,"z4":25.0}"#),
            row(20_000, source: "apple_health", zones: #"{"z3":100}"#),   // legacy spelling
            row(30_000, source: "apple-health", zones: nil),               // no split, not counted
        ])
        XCTAssertEqual(s?.sessionsWithZones, 3)
        XCTAssertEqual(s?.appleHealthSessions, 2)
    }

    func testWhoopOnlySummaryHasNoAppleHealthSessions() {
        let s = WorkoutZones.summary(from: [row(0, source: "whoop", zones: #"{"z5":100}"#)])
        XCTAssertEqual(s?.appleHealthSessions, 0)
    }
}
