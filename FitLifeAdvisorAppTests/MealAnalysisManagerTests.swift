import XCTest
@testable import FitLifeAdvisorApp

final class MealAnalysisManagerTests: XCTestCase {
    func testParseNutritionFromLabelText() {
    let sample = "Calories 250 kcal\nProtein 20 g\nCarbs 30 g\nFat 10 g\nFiber 5 g\nSodium 200 mg"
    let result = NutritionLabelParser.parse(from: sample)
        XCTAssertNotNil(result)
        XCTAssertEqual(Int(result!.calories), 250)
        XCTAssertEqual(Int(result!.protein), 20)
        XCTAssertEqual(Int(result!.carbs), 30)
        XCTAssertEqual(Int(result!.fat), 10)
        XCTAssertEqual(Int(result!.fiber), 5)
    }

    func testEstimateMealNutritionFallback() {
    // Use deterministic estimator for testing plausibility
    let info = NutritionEstimator.defaultEstimate()
        XCTAssertGreaterThan(info.calories, 0)
        XCTAssertGreaterThan(info.protein + info.carbs + info.fat, 0)
    }
}
