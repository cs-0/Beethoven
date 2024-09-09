@testable import Beethoven
import Quick
import Nimble

final class ConfigSpec: QuickSpec {
  func spec() {
    Self.describe("Config") {
      var config: Config!

      Self.describe("#init") {
        Self.it("sets default values") {
          config = Config()

          expect(config.bufferSize).to(equal(4096))
          expect(config.estimationStrategy).to(equal(EstimationStrategy.yin))
          expect(config.audioUrl).to(beNil())
        }
      }
    }
  }
}
