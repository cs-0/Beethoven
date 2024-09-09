@testable import Beethoven
import Quick
import Nimble

final class EstimationFactorySpec: QuickSpec {
    func spec() {
        Self.describe("EstimationFactory") {
            let factory = EstimationFactory()
            
            Self.describe(".create") {
                Self.it("creates QuadradicEstimator") {
                    expect(factory.create(.quadradic) is QuadradicEstimator).to(beTrue())
                }
                
                Self.it("creates Barycentric") {
                    expect(factory.create(.barycentric) is BarycentricEstimator).to(beTrue())
                }
                
                Self.it("creates QuinnsFirst") {
                    expect(factory.create(.quinnsFirst) is QuinnsFirstEstimator).to(beTrue())
                }
                
                Self.it("creates QuinnsSecond") {
                    expect(factory.create(.quinnsSecond) is QuinnsSecondEstimator).to(beTrue())
                }
                
                Self.it("creates Jains") {
                    expect(factory.create(.jains) is JainsEstimator).to(beTrue())
                }
                
                Self.it("creates HPS") {
                    expect(factory.create(.hps) is HPSEstimator).to(beTrue())
                }
                
                Self.it("creates YIN") {
                    expect(factory.create(.yin) is YINEstimator).to(beTrue())
                }
                
                Self.it("creates MaxValue") {
                    expect(factory.create(.maxValue) is MaxValueEstimator).to(beTrue())
                }
            }
        }
    }
}
