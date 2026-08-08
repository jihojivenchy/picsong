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

    /// 기본 디노이징 스텝 수 — LCM 스케줄러 기준
    private static let defaultStepCount: Int = 4

    /// 최초 1회만 만들어 재사용하는 파이프라인 — 로드 비용이 크다
    private static var loadedPipeline: StableDiffusionPipeline?

    /// 저장 일련번호 — 파일 경로를 매번 다르게 만들어 캐시 충돌을 막는다
    private static var saveCount: Int = 0

    ///
    /// [prompt]로 클루 이미지 한 장을 생성해 PNG로 저장하고 파일 경로를 돌려준다.
    /// [steps]를 주면 기본 스텝 수를 대신 쓴다 — 프롬프트 실험용.
    ///
    static func generate(prompt: String, seed: UInt32, steps: Int? = nil) throws -> URL {
        let startedAt: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        let pipeline: StableDiffusionPipeline = try sharedPipeline()
        let images: [CGImage?] = try pipeline.generateImages(
            configuration: makeRequest(prompt: prompt, seed: seed, steps: steps)
        )
        guard let image: CGImage = images.first ?? nil else {
            throw GeneratorError.imageNotProduced
        }
        let url: URL = try savePNG(image, seed: seed)
        let elapsed: String = String(format: "%.1f", CFAbsoluteTimeGetCurrent() - startedAt)
        NSLog("%@", "[ClueGenerator] 생성 완료 \(elapsed)초")
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
        NSLog("%@", "[ClueGenerator] 파이프라인 준비 \(elapsed)초")
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
    private static func makeRequest(prompt: String, seed: UInt32, steps: Int?) -> StableDiffusionPipeline.Configuration {
        var request = StableDiffusionPipeline.Configuration(prompt: prompt)
        request.stepCount = steps ?? defaultStepCount
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
    /// 파일명에 일련번호를 붙인다 — 같은 시드로 다른 프롬프트를 생성할 때
    /// 경로가 겹치면 Flutter 이미지 캐시가 이전 장을 계속 보여준다.
    ///
    private static func savePNG(_ image: CGImage, seed: UInt32) throws -> URL {
        guard let data: Data = UIImage(cgImage: image).pngData() else {
            throw GeneratorError.pngEncodingFailed
        }
        saveCount += 1
        let url: URL = FileManager.default.temporaryDirectory
            .appending(path: "clue-\(seed)-\(saveCount).png")
        try data.write(to: url)
        return url
    }
}
