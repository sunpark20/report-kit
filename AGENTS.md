# report-kit 작업 규칙

`ReportKit`은 앱과 공개 GitHub Issue Form 사이의 플랫폼 독립 계약을 구현한다. `ReportKitUI`는 선택적인 SwiftUI 신고 시트다.

## 불변 조건

1. 신고 URL에는 `labels=`나 `body=`를 넣지 않는다. 라벨은 Issue Form YAML의 top-level `labels:`만 사용한다.
2. URL 쿼리 이름은 `template`, `version`, `build`, `os`, `device`, `diagnostics`만 사용하고 폼 필드 ID와 일치시킨다.
3. 전화번호, 이메일, 실명, 사용자 파일 경로, 기기 이름·시리얼, 원본 로그는 자동 수집하지 않는다. `device`는 일반 종류만, `diagnostics`는 200자 이하이며 값을 읽지 못하면 `unknown`을 쓴다.
4. 이메일 신고 경로는 만들거나 되살리지 않는다. 메일 URL 스킴과 신고용 이메일 주소를 코드·문서·UI에 넣지 않는다.
5. 공개 산출물에 비공개 저장소 이름이나 로컬 경로를 넣지 않는다.
6. 앱 ID는 호출자가 명시적으로 넘긴 `shipping.yml` 값만 사용한다. 디렉터리명이나 저장소명으로 추론하지 않는다.
7. GitHub Actions 워크플로를 새로 만들지 않는다.
8. 공개 Issue Form의 비신뢰 입력은 코딩 에이전트·비밀값 워크플로·자동 병합을 직접 실행할 수 없다.
9. `GOAL_대개편.md`, `GOAL_PROGRESS.md`, `에러리포트_계획.md`, `에러리포트_프롬프트.md`는 로컬 작업 문서이며 커밋하지 않는다.

`ReportKitTests`에는 `labels`와 `body` 쿼리가 없음을 검증하는 단언을 최소 두 건 유지한다.
