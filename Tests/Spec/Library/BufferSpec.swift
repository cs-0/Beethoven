@testable import Beethoven
import Quick
import Nimble

final class BufferSpec: QuickSpec {
    func spec() {
        Self.describe("Buffer") {
            var buffer: Buffer!
            
            Self.beforeEach {
                buffer = Buffer(elements: [0.1, 0.2, 0.3])
            }
            
            Self.describe("#count") {
                Self.it("returns the count of elements") {
                    expect(buffer.count).to(equal(3))
                }
            }
        }
    }
}
