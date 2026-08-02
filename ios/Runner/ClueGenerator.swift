//
//  ClueGenerator.swift
//  Runner
//
//  Created by 엄지호 on 7/26/26.
//

import CoreML
import StableDiffusion
import UIKit

struct ClueGenerator {
    /// 생성 실패 원인
    enum GeneratorError: Error {
        case imageNotProduced
        case pngEncodingFailed
    }

    /// 최초 1회만 만들어 재사용하는 파이프라인 — 로드 비용이 크다
    private static var loadedPipeline: StableDiffusionPipeline?

    ///
    /// [prompt]로 클루 이미지 한 장을 생성해 PNG로 저장하고 파일 경로를 돌려준다.
    ///
    static func generate(prompt: String, seed: UInt32) throws -> URL {
        let startedAt: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        let pipeline: StableDiffusionPipeline = try sharedPipeline()
        let images: [CGImage?] = try pipeline.generateImages(
            configuration: makeRequest(prompt: prompt, seed: seed)
        )
        guard let image: CGImage = images.first ?? nil else {
            throw GeneratorError.imageNotProduced
        }
        let url: URL = try savePNG(image, seed: seed)
        let elapsed: String = String(format: "%.1f", CFAbsoluteTimeGetCurrent() - startedAt)
        NativeLog.write("[ClueGenerator] 생성 완료 \(elapsed)초")
        return url
    }

    ///
    /// 파이프라인을 만들어 리소스를 올린다. 두 번째 호출부터는 만들어둔 것을 그대로 쓴다.
    ///
    private static func sharedPipeline() throws -> StableDiffusionPipeline {
        if let loadedPipeline: StableDiffusionPipeline = loadedPipeline {
            return loadedPipeline
        }
        let startedAt: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        let pipeline: StableDiffusionPipeline = try makePipeline()
        try pipeline.loadResources()
        let elapsed: String = String(format: "%.1f", CFAbsoluteTimeGetCurrent() - startedAt)
        NativeLog.write("[ClueGenerator] 파이프라인 준비 \(elapsed)초")
        loadedPipeline = pipeline
        return pipeline
    }

    ///
    /// 다운로드해 설치한 CoreML 리소스로 파이프라인을 만든다.
    ///
    private static func makePipeline() throws -> StableDiffusionPipeline {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuAndNeuralEngine
        return try StableDiffusionPipeline(
            resourcesAt: ModelInstaller.shared.modelDirectory,
            controlNet: [],
            configuration: configuration,
            disableSafety: true,
            reduceMemory: true
        )
    }

    ///
    /// 확정된 생성 파라미터로 요청 설정을 만든다.
    ///
    private static func makeRequest(prompt: String, seed: UInt32) -> StableDiffusionPipeline.Configuration {
        var request = StableDiffusionPipeline.Configuration(prompt: prompt)
        request.stepCount = 4
        request.guidanceScale = 0.0
        request.seed = seed
        request.imageCount = 1
        request.schedulerType = .lcmScheduler
        request.disableSafety = true
        return request
    }

    ///
    /// [image]를 임시 디렉터리에 PNG로 저장하고 파일 URL을 돌려준다.
    ///
    private static func savePNG(_ image: CGImage, seed: UInt32) throws -> URL {
        guard let data: Data = UIImage(cgImage: image).pngData() else {
            throw GeneratorError.pngEncodingFailed
        }
        let url: URL = FileManager.default.temporaryDirectory
            .appending(path: "clue-\(seed).png")
        try data.write(to: url)
        return url
    }
}
