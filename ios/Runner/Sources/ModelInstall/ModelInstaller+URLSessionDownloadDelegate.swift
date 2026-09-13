//
//  ModelInstaller+URLSessionDownloadDelegate.swift
//  Runner
//
//

import Foundation

// URLSessionDownloadDelegate 처리
extension ModelInstaller: URLSessionDownloadDelegate {
    ///
    /// 데이터 조각이 도착할 때마다 호출됨
    ///
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let tag: String = downloadTask.taskDescription, tag != Download.manifestTag else { return }
        receivedBytes[tag] = totalBytesWritten
        emitProgress(force: false)
    }

    ///
    /// 다운로드 완료
    ///
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL // 다운로드 파일 경로 (임시)
    ) {
        // 다운로드 태스크 설명 확인
        guard let tag: String = downloadTask.taskDescription else { return }

        // 200 OK 응답 체크
        guard let response = downloadTask.response as? HTTPURLResponse, response.statusCode == 200 else {
            let statusCode: Int = (downloadTask.response as? HTTPURLResponse)?.statusCode ?? -1
            NSLog("%@", "[ModelInstaller] \(tag) HTTP \(statusCode)")
            // 재시도 등록
            scheduleRetry(for: tag)
            return
        }

        // 임시 디렉토리 생성
        let holding: URL = fileStore.makeIncomingURL()

        do {
            // 다운로드 파일을 임시 디렉토리로 이동
            try FileManager.default.moveItem(at: location, to: holding)

            // manifest 파일인지 체크
            if tag == Download.manifestTag {
                try adoptDownloadedManifest(at: holding)
            } else {
                try verifyAndStage(holding, entryPath: tag)
            }
        } catch {
            NSLog("%@", "[ModelInstaller] \(tag) 처리 실패: \(error)")
            // 실패시 임시 디렉토리 삭제
            try? FileManager.default.removeItem(at: holding)
            
            // 재시도 등록
            scheduleRetry(for: tag)
        }
    }

    ///
    /// 태스크 종료 — 성공 처리는 didFinishDownloadingTo가 끝냈으므로 에러만 본다.
    ///
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error: Error = error, let tag: String = task.taskDescription else { return }
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        NSLog("%@", "[ModelInstaller] \(tag) 전송 실패: \(error.localizedDescription)")
        scheduleRetry(for: tag)
    }

    ///
    /// 백그라운드 이벤트 전달 완료 — 보관해둔 완료 핸들러를 불러줘야 다음에도 앱을 깨워준다.
    ///
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [self] in
            backgroundCompletionHandler?()
            backgroundCompletionHandler = nil
        }
    }
}
