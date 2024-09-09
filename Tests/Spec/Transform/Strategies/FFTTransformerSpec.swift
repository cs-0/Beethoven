@testable import Beethoven
import Quick
import Nimble
import Accelerate

final class FFTTransformerSpec: QuickSpec {
    func spec() {
        Self.describe("FFTTransformer") {
            var transformer: FFTTransformer!
            
            Self.beforeEach {
                transformer = FFTTransformer()
            }
            
            Self.describe("#sqrtq") {
                Self.it("returns the array's square") {
                    let array: [Float] = [0.1, 0.2, 0.3]
                    var expected = [Float](repeating: 0.0, count: array.count)
                    vvsqrtf(&expected, array, [Int32(array.count)])
                    
                    expect(transformer.sqrtq(array)).to(equal(expected))
                }
            }
        }
    }
}
