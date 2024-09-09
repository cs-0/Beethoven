@testable import Beethoven
import Quick
import Nimble

final class ArrayExtensionsSpec: QuickSpec {
    func spec() {
        Self.describe("Array+Extensions") {
            
            Self.describe(".fromUnsafePointer") {
                Self.it("returns the array created from unsafe pointer") {
                    var array = [0.1, 0.3, 0.2]
                    let result = Array.fromUnsafePointer(&array, count: 3)
                    
                    expect(result).to(equal(array))
                }
            }
            
            Self.describe("#maxIndex") {
                Self.it("returns the index of the max element in the array") {
                    let array = [0.1, 0.3, 0.2]
                    expect(array.maxIndex).to(equal(1))
                }
            }
        }
    }
}
