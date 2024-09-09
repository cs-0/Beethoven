@testable import Beethoven
import Quick
import Nimble

final class EstimatorSpec: QuickSpec {
    func spec() {
        Self.describe("Estimator") {
            var estimator: Estimator!
            
            Self.beforeEach {
                estimator = HPSEstimator()
            }
            
            Self.describe("#maxBufferIndex") {
                Self.it("returns the index of the max element in the array") {
                    let array: [Float] = [0.1, 0.3, 0.2]
                    let result = try! estimator.maxBufferIndex(from: array)
                    
                    expect(result).to(equal(1))
                }
            }
            
            Self.describe("#sanitize") {
                Self.it("returns the passed location if Self.it doesn't extend array bounds") {
                    let array: [Float] = [0.1, 0.3, 0.2]
                    let result = estimator.sanitize(location: 1, reserveLocation: 0, elements: array)
                    
                    expect(result).to(equal(1))
                }
                
                Self.it("returns the reserve location if the passed location extends array bounds") {
                    let array: [Float] = [0.1, 0.3, 0.2]
                    let result = estimator.sanitize(location: 4, reserveLocation: 0, elements: array)
                    
                    expect(result).to(equal(0))
                }
            }
        }
    }
}
