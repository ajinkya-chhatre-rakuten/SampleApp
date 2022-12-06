//
//  SampleAppTests.swift
//  SampleAppTests
//
//  Created by Chhatre, Ajinkya | RIEPL on 01/12/22.
//

import XCTest
@testable import SampleApp
import Quick
import Nimble


final class SampleAppTests: XCTestCase {

    func testExample() throws {
        
    }
}


class SampleAppScenarioTests: QuickSpec
{
    override func spec()
    {
        describe("SampleAppTestScenario")
        {
            context("Initialize all SDKs successfully",
            {

                it("should Initialize all SDKs successfully")
                {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    {
                        appDelegate.createSampleInstance()
                        expect(appDelegate.allSDKInitialized).to(equal(true))
                    }
                }
            })
        }
    }
}

