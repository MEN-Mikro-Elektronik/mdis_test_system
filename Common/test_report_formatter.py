from cgitb import reset
from enum import Enum
from abc import ABC, abstractmethod
import sys
from typing import Any, List
from junit_xml import TestSuite, TestCase

class TestType(Enum):
    UNKNOWN = 0
    TEST_LEVEL_1 = 1
    TEST_LEVEL_2 = 2

class TestResult(Enum):
    UNKNOWN = 0
    PASS = 1
    FAIL = 2

class TestProperty:
    def __init__(self, key: str, value: str):
        self.__key = key
        self.__value = value

    def getKey(self) -> str:
        return self.__key

    def getValue(self) -> str:
        return self.__value

    def __repr__(self):
        return "("+self.__key+" -> "+self.__value+")"

class InstanceTestProperty(TestProperty):
    def __init__(self, value: str):
        TestProperty.__init__(self, "instance", value)

class OsTestProperty(TestProperty):
    def __init__(self, value: str):
        TestProperty.__init__(self, "Operating System", value)

class SetupTestProperty(TestProperty):
    def __init__(self, value: str):
        TestProperty.__init__(self, "Setup", value)

class TestIdProperty(TestProperty):
    def __init__(self, value: str):
        TestProperty.__init__(self, "Test ID", value)

class Test:
    def __init__(self, testId: str, name: str, testType: TestType):
        self.__testId = testId
        self.__name = name
        self.__testType = testType
        self.__result = TestResult.FAIL
        self.__properties = []
        self.__subtests = []

    def setTestId(self, testId: str):
        self.__testId = testId

    def getTestId(self) -> str:
        return self.__testId

    def setTestName(self, testName: str):
        self.__name = testName

    def getTestName(self) -> str:
        return self.__name

    def setTestType(self, testType: TestType):
        self.__testType = testType

    def getTestType(self) -> TestType:
        return self.__testType

    def setTestResult(self, result: TestResult):
        self.__result = result

    def getTestResult(self) -> TestResult:
        return self.__result

    def addTest(self, newTest: Any):
        self.__subtests.append(newTest)

    def getTests(self) -> List[Any]:
        return self.__subtests

    def addProperty(self, newProperty: TestProperty):
        self.__properties.append(newProperty)

    def getProperties(self) -> TestProperty:
        return self.__properties

    def __repr__(self):
        dump = ">> TestId: "+self.__testId+" Name: "+self.__name+" type: "+str(self.__testType)+" result: "+str(self.__result)+" properties: "+str(self.__properties)

        for test in self.__subtests:
            dump += "\n\t"+test.__repr__()    
        return dump

class BoardTest(Test):
    def __init__(self, testId: str, name: str):
        Test.__init__(self, testId, name, TestType.TEST_LEVEL_1)

class CarrierBoardTest(Test):
    def __init__(self, testId: str, name: str):
        Test.__init__(self, testId, name, TestType.TEST_LEVEL_1)

class CompilationTest(Test):
    def __init__(self, testId: str):
        Test.__init__(self, testId, "Compilation of Kernel: "+testId, TestType.TEST_LEVEL_1)

class IpCoreTest(Test):
    def __init__(self, testId: str, name: str):
        Test.__init__(self, testId, name, TestType.TEST_LEVEL_2)

class MModuleTest(Test):
    def __init__(self, testId: str, name: str):
        Test.__init__(self, testId, name, TestType.TEST_LEVEL_2)

class CompilationModeTest(Test):
    def __init__(self, testId: str, mode: str):
        Test.__init__(self, testId, "Compiling Kernel in mode: "+mode, TestType.TEST_LEVEL_2)

class TestReportProcessor:
    def __init__(self):
        self._testList = []

    @abstractmethod
    def processLine(self, line: str):
        pass

    def getTests(self) -> List[Test]:
        return self._testList

    def processTests(self) -> int:
        testL1Dic = {}

        for test in self._testList:
            if test.getTestType() == TestType.TEST_LEVEL_1:
                testL1Dic[test.getTestId()] = test

        for test in self._testList:
            if test.getTestType() == TestType.TEST_LEVEL_2:
                testL1Dic.get(test.getTestId()).addTest(test)

        self._testList = testL1Dic.values()

        return len(self._testList)

class MdisCompilationTestReportProcessor(TestReportProcessor):
    def __init__(self):
        TestReportProcessor.__init__(self)
        self.__currentTest = None
        self.__oldKernelVersion = ""

    def processLine(self, line: str):
        kernelVersion = self.__findKernelVersion(line)
        compilationMode = self.__findCompilationMode(line)
        compilationResult = self.__findCompilationResult(line)

        if self.__oldKernelVersion != kernelVersion:
            self.__oldKernelVersion = kernelVersion
            self._testList.append(CompilationTest(kernelVersion))
        
        test = CompilationModeTest(kernelVersion, compilationMode)

        test.setTestResult(compilationResult)

        self._testList.append(test)

    def __findKernelVersion(self, line: str) -> str:
        delimiterPos = line.find("_")

        return line[:delimiterPos]

    def __findCompilationMode(self, line: str) -> str:
        lowDelimiterPos = line.find("_")
        highdelimiterPos = line.find(" ")

        mode = line[lowDelimiterPos+1:highdelimiterPos]
        
        match mode:
            case "dbg":
                return "Debug"
            case "nodbg":
                return "No Debug"
            case _:
                return "Undefined"

    def __findCompilationResult(self, line: str) -> TestResult:
        delimiterPos = line.find(" ")
        result = line[delimiterPos+1:].strip()

        match result:
            case "PASSED":
                return TestResult.PASS
            case "FAILED":
                return TestResult.FAIL
            case _:
                return TestResult.UNKNOWN

class MdisTestReportProcessor(TestReportProcessor):
    def __init__(self):
        TestReportProcessor.__init__(self)
        self.__currentTest = None

    def processLine(self, line: str):
        testEntry = self.__findTestEntry(line)

        if testEntry is not None:
            if self.__currentTest is not None:
                self._testList.append(self.__currentTest)

            self.__currentTest = testEntry

        testResult = self.__findTestResult(line)

        if testResult != TestResult.UNKNOWN:
            self.__currentTest.setTestResult(self.__getTestResult(line))

        property = self.__findProperty(line)

        if property is not None:
            self.__currentTest.addProperty(property)

    def processTests(self) -> int:
        # Append the last processed test.
        self._testList.append(self.__currentTest)

        return TestReportProcessor.processTests(self)

    def __findTestId(self, line: str) -> str:
        testId = "0"
        lowerOffset = line.find("[")
        higherOffset = line.find("]")

        if lowerOffset >= 0 & higherOffset >= 0:
            testId = line[lowerOffset+1:higherOffset]

        return testId

    def __findTestname(self, line: str) -> str:
        return self.__trimTestIdFromLine(line)

    def __findTestEntry(self, line: str) -> Test:
        testName = ""
        testId = ""

        if "Carrier board with M-Module test:" in line:
            testName = self.__findTestname(line)
            testId = self.__findTestId(line)
            return CarrierBoardTest(testId, testName)
        if "Board test:" in line:
            testName = self.__findTestname(line)
            testId = self.__findTestId(line)
            return BoardTest(testId, testName)
        if "M-Module test:" in line:
            testName = self.__findTestname(line)
            testId = self.__findTestId(line)
            return MModuleTest(testId, testName)
        if "Ip Core test:" in line:
            testName = self.__findTestname(line)
            testId = self.__findTestId(line)
            return IpCoreTest(testId, testName)

        return None

    def __findTestResult(self, line: str) -> TestResult:
        if "Test_Result:" in line:
            return self.__getTestResult(line)
        
        return TestResult.UNKNOWN

    def __getTestResult(self, line: str) -> TestResult:
        if "SUCCESS" in line:
            return TestResult.PASS

        return TestResult.FAIL

    def __trimTestIdFromLine(self, line: str) -> str:
        endTestIdPos = line.find("]")
        lineWithoutTstId = line[endTestIdPos+1:]

        return lineWithoutTstId.strip()

    def __findProperty(self, line: str) -> TestProperty:
        if "Test_Setup:" in line:
            return SetupTestProperty(self.__getPropertyValue(line))
        if "Test_Os:" in line:
            return OsTestProperty(self.__getPropertyValue(line))
        if "Test_Instance:" in line:
            return InstanceTestProperty(self.__getPropertyValue(line))
        if "Test_ID:" in line:
            return TestIdProperty(self.__getPropertyValue(line))

        return None

    def __getPropertyValue(self, line: str) -> str:
        index = line.find(":")
        value = line[index+1:]

        return value.strip()

class TestFormatter:
    def __init__(self, filename: str):
        self.__filename = self.__replaceFileExtension(filename)

    def __replaceFileExtension(self, filename: str) -> str:
        newFileName = ""

        dotPosition = filename.rfind(".")
        newFileName = filename[:dotPosition]

        return newFileName+".xml"

    def _getTestProperties(self, test: Test) -> dict:
        keys = []
        values = []
        for property in test.getProperties():
            keys.append(property.getKey())
            values.append(property.getValue())

        return dict(zip(keys, values))

    def _getFileName(self) -> str:
        return self.__filename

    @abstractmethod
    def printFormattedTests(self):
        pass

    @abstractmethod
    def saveToFile(self):
        pass

class JUnitTestFormatter(TestFormatter):
    def __init__(self, filename: str):
        TestFormatter.__init__(self, filename)
        self.__testSuiteList = []

    def format(self, tests):
        self.__testSuiteList = []

        for test in tests:
            testCaseList = []
            for subtest in test.getTests():
                testCaseList.append(self.__createTestCase(subtest))

            if len(testCaseList) == 0:
                testCaseList.append(self.__createTestCase(test))

            self.__testSuiteList.append(self.__createTestSuite(test, testCaseList))

    def saveToFile(self):
        with open(self._getFileName(), "w") as f:
            TestSuite.to_file(f, self.__testSuiteList)

    def printFormattedTests(self):
        print("\n-----------------\n")
        print(TestSuite.to_xml_string(self.__testSuiteList))

    def __createTestCase(self, test) -> TestCase:
        testCase = TestCase(test.getTestName())

        if (test.getTestResult() is TestResult.FAIL):
            testCase.add_failure_info("Test failed")

        return testCase

    def __createTestSuite(self, test, testCaseList) -> TestSuite:     
        return TestSuite(test.getTestName(), testCaseList, id=test.getTestId(), properties=self._getTestProperties(test))

def main(selectedInput: str, selectedFile: str, silent: int):
    formatter = JUnitTestFormatter(selectedFile)
    loadedFile = []

    match selectedInput:
        case "mdis":
            processor = MdisTestReportProcessor()
        case "mdis_compilation":
            processor = MdisCompilationTestReportProcessor()
        case _:
            processor = MdisTestReportProcessor()

    with open(selectedFile, "r") as f:
            loadedFile = f.readlines()

    for line in loadedFile:
        processor.processLine(line)

    numTestsProcessed = processor.processTests()

    formatter.format(processor.getTests())

    formatter.saveToFile()

    if silent == 0:
        print(">> "+str(numTestsProcessed)+" test(s) processed")
        formatter.printFormattedTests()

def usage():
    print("test_report_formatter.py - tool to format the MDIS test reports to a standard format")
    print("")
    print("USAGE")
    print("    test_report_formatter.py -h")
    print("    test_report_formatter.py -m mode -f file [-s]")
    print("")
    print("OPTIONS")
    print("    -i input")
    print("        input format. Currently only supports modes:")
    print("        * mdis -> mdis funtional test results")
    print("        * mdis_compilation -> mdis compilation test results")
    print("")
    print("    -f file")
    print("        File where the test results are located")
    print("")
    print("    -s")
    print("        Optional. Run the script silently")
    print("")
    print("    -h, --help")
    print("        Print this help")

if __name__ == "__main__":
    input = 0
    file = 0
    silent = 0
    selectedInput = ""
    selectedFile = ""

    for i, arg in enumerate(sys.argv):
        if "-i" in arg:
            input = 1
            continue

        if "-f" in arg:
            file = 1
            continue

        if "-s" in arg:
            silent = 1
            continue

        if "-h" in arg:
            usage()
            exit(0)

        if input == 1:
            selectedInput = arg
            input = 0

        if file == 1:
            selectedFile = arg
            file = 0

    if selectedInput == "":
        print(">> Error. No Input format found. Abort")
        exit(1)

    if selectedFile == "":
        print(">> Error. No file found. Abort")
        exit(1)

    main(selectedInput, selectedFile, silent)
