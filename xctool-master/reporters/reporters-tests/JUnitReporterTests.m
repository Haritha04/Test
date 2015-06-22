
#import <SenTestingKit/SenTestingKit.h>

#import "JUnitReporter.h"
#import "Reporter+Testing.h"

@interface JUnitReporterTests : SenTestCase
@end

@implementation JUnitReporterTests

- (void)testTestResults {
  [self raiseAfterFailure];
  NSError *error = nil;

  // The actual XML file generated by outputDataWithEventsFromFile:
  NSData *outputData =
    [JUnitReporter outputDataWithEventsFromFile:TEST_DATA @"JSONStreamReporter-runtests.txt"];
  NSXMLDocument *resultingXML = [[NSXMLDocument alloc] initWithData:outputData options:0 error:&error];
  STAssertNil(error, @"Error parsing the actual JUnit reporter output XML:\n%@", error);

  // The expected XML that should be generated by outputDataWithEventsFromFile:
  NSString *expectedFilePath = TEST_DATA @"JSONStreamReporter-expected.xml";
  NSXMLDocument *expectedXML = [[NSXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:expectedFilePath] options:0 error:&error];
  STAssertNil(error, @"Error opening file %@ the expected XML for this unit test:\n%@", expectedFilePath, error);

  // The XMLs need to be massaged for a proper semantic equality check.
  for (NSXMLDocument *doc in @[expectedXML, resultingXML]) {

    // Remove the "timestamp" attribute values.
    NSString *attributeName = @"timestamp";
    NSString *xpath = [NSString stringWithFormat:@"//*[@%@]", attributeName];
    NSArray *elementsWithTimeAttr = [doc nodesForXPath:xpath error:&error];
    STAssertNil(error, @"Error while searching for time-related nodes using XPath.");

    for (NSXMLElement *element in elementsWithTimeAttr) {
      [element removeAttributeForName:attributeName];
      [element addAttribute:[NSXMLNode attributeWithName:attributeName stringValue:@""]];
    }
  }

  // When this assertion fails, figuring out which part of the XML is different is a bitch.
  // If we can find a good xml treediff of some sort, the failure output would be much more readable.
  STAssertEqualObjects(expectedXML, resultingXML, @"The XML generated by the JUnit Reporter differs from the one expected by this test.");
}

- (void)testJUnitReporterTestingXMLTreeMinification {
  [self raiseAfterFailure];
  NSError *error = nil;

  // The actual XML file generated by outputDataWithEventsFromFile:
  NSData *outputData =
    [JUnitReporter outputDataWithEventsFromFile:TEST_DATA @"JSONJUnitReporter-XMLTreeMinification.txt"];
  NSXMLDocument *resultingXML = [[NSXMLDocument alloc] initWithData:outputData options:0 error:&error];
  STAssertNil(error, @"Error parsing the actual JUnit reporter output XML:\n%@", error);

  // The expected XML that should be generated by outputDataWithEventsFromFile:
  NSString *expectedFilePath = TEST_DATA @"JSONJUnitReporter-XMLTreeMinification-expected.txt";
  NSXMLDocument *expectedXML = [[NSXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:expectedFilePath] options:0 error:&error];
  STAssertNil(error, @"Error opening file %@ the expected XML for this unit test:\n%@", expectedFilePath, error);

  // The XMLs need to be massaged for a proper semantic equality check.
  for (NSXMLDocument *doc in @[expectedXML, resultingXML]) {

    // Remove the "timestamp" attribute values.
    NSString *attributeName = @"timestamp";
    NSString *xpath = [NSString stringWithFormat:@"//*[@%@]", attributeName];
    NSArray *elementsWithTimeAttr = [doc nodesForXPath:xpath error:&error];
    STAssertNil(error, @"Error while searching for time-related nodes using XPath.");

    for (NSXMLElement *element in elementsWithTimeAttr) {
      STAssertNotNil([element attributeForName:attributeName], @"This is the timestamp attribute, shouldn't be nil");
      [element removeAttributeForName:attributeName];
      [element addAttribute:[NSXMLNode attributeWithName:attributeName stringValue:@""]];
    }
  }

  STAssertEqualObjects(expectedXML, resultingXML, @"The XML generated by the JUnit Reporter differs from the one expected by this test.");
}

@end
