# ReportKit

Swift Package for opening the public GitHub Issue Form used by Sunguk's apps.

```swift
import ReportKit

let target = ReportTarget(
    appID: "example",
    displayName: "Example",
    template: "example-bug.yml"
)

if let link = target.github(metadata: .current()) {
    ReportOpener.open(link)
}
```

`ReportKitUI` provides a bilingual SwiftUI support sheet with a GitHub-only reporting action and an app-information copy action.
