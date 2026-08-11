import ReportKit
import SwiftUI

@MainActor
public struct ReportSupportSheet: View {
    private let target: ReportTarget
    private let diagnostics: String?

    @Environment(\.dismiss) private var dismiss
    @State private var status: ReportOpener.Status?

    public init(target: ReportTarget, diagnostics: String? = nil) {
        self.target = target
        self.diagnostics = diagnostics
    }

    private var metadata: ReportMetadata {
        .current(diagnostics: diagnostics)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("오류 신고는 하나의 공개 GitHub 저장소에서 관리합니다. Bug reports are managed in one public GitHub tracker.")
                    Text("GitHub 계정으로 신고합니다. 실제 전화번호, 이메일, 원본 로그 등 민감정보는 올리지 마세요.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("문제 신고 / Report a problem") {
                    Button(action: openGitHubReport) {
                        Label("GitHub에 신고 / Report on GitHub", systemImage: "ladybug")
                    }
                    Button(action: copyAppInfo) {
                        Label("앱 정보 복사 / Copy app info", systemImage: "doc.on.doc")
                    }
                }

                Section("앱 정보 / App information") {
                    LabeledContent("버전 / Version", value: metadata.version)
                    LabeledContent("빌드 / Build", value: metadata.build)
                    LabeledContent("운영체제 / OS", value: metadata.os)
                    LabeledContent("기기 종류 / Device", value: metadata.device)
                    if let diagnostics, !diagnostics.isEmpty {
                        Text(diagnostics)
                            .font(.caption.monospaced())
                            .textSelection(.enabled)
                    }
                }

                if let message = status?.userMessage {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("앱 정보 및 문제 신고")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료 / Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func openGitHubReport() {
        guard let link = target.github(metadata: metadata) else {
            status = .unavailable
            return
        }
        status = ReportOpener.open(link)
    }

    private func copyAppInfo() {
        status = ReportOpener.copy(appInfoText)
    }

    private var appInfoText: String {
        var lines = [
            "App: \(target.displayName)",
            "Version: \(metadata.version)",
            "Build: \(metadata.build)",
            "OS: \(metadata.os)",
            "Device: \(metadata.device)",
        ]
        if let diagnostics, !diagnostics.isEmpty {
            lines.append("Diagnostics: \(diagnostics)")
        }
        return lines.joined(separator: "\n")
    }
}
