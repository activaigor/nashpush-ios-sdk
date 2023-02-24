import XCTest

func XCTAssertThrowsErrorAsync<T, E>(
  _ expression: @autoclosure () async throws -> T,
  _ errorThrown: @autoclosure () -> E,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #filePath,
  line: UInt = #line
) async where E: Error, E: Equatable {
  do {
    let _ = try await expression()
    XCTFail(message(), file: file, line: line)
  } catch {
    XCTAssertEqual(error as? E, errorThrown())
  }
}

func XCTAssertNoThrowAsync<T>(
  _ expression: @autoclosure () async throws -> T,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #filePath,
  line: UInt = #line
) async {
  do {
    let _ = try await expression()
    XCTAssert(true)
  } catch {
    XCTFail(message(), file: file, line: line)
  }
}
