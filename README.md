# neutrospec/homebrew-tap

[canopy](https://github.com/neutrospec/canopy) — 마크다운 LLM 위키를 위한 로컬 지식
관리 도구(스키마 검증·하이브리드 검색·웹 UI·재발견 루프) — 를 Homebrew로 설치하는
탭입니다.

## 설치

```bash
brew install neutrospec/tap/canopy
```

`brew tap neutrospec/tap && brew install canopy` 와 같습니다.

포뮬러는 **소스에서 빌드**합니다 — Homebrew의 `onnxruntime`과 tokenizer 라이브러리에
직접 링크하기 위해서입니다(프리빌트 바이너리보다 견고). 최초 빌드에 Go 툴체인과
Xcode Command Line Tools가 필요하며, `brew`가 의존성으로 알아서 처리합니다.

지원 플랫폼: macOS(Apple Silicon·Intel), Linux(arm64·x86_64).

### 시맨틱 검색 모델 (선택, 최초 1회)

의미 기반 검색을 쓰려면 설치 후 임베딩 모델을 한 번 내려받습니다:

```bash
canopy model pull      # bge-m3 ONNX, ~2.3GB
```

모델 없이도 **keyword 검색·웹 UI·쓰기·sync** 등 나머지 기능은 모두 동작합니다.

## 빠른 시작

```bash
mkdir -p ~/.config/canopy
echo 'default_wiki = "/path/to/your/wiki"' > ~/.config/canopy/config.toml

canopy init            # 위키 채택: canopy.toml 생성 + 인덱싱
canopy search "무엇이든"
canopy serve           # → http://localhost:8737
```

15분 튜토리얼: [canopy getting-started](https://github.com/neutrospec/canopy/blob/main/docs/getting-started.md)

## 업그레이드 · 제거

```bash
brew upgrade canopy
brew uninstall canopy
brew untap neutrospec/tap
```

canopy는 새 버전 첫 실행 시 필요한 데이터 마이그레이션을 **자동으로** 수행합니다
(`canopy migrate status`로 확인). 업그레이드 후 사용자가 할 일은 없습니다. 설계:
[docs/versioning.md](https://github.com/neutrospec/canopy/blob/main/docs/versioning.md).

## 최신(main) 빌드

릴리스 전 최신 코드를 시험하려면:

```bash
brew install --HEAD neutrospec/tap/canopy
```

## 문제 해결

- **`libonnxruntime not found`** — `onnxruntime`은 포뮬러 의존성이라 보통 자동
  설치됩니다. 그래도 못 찾으면 위치를 알려주세요:
  ```bash
  export CANOPY_ONNXRUNTIME_DIR="$(brew --prefix onnxruntime)/lib"
  ```
- **`canopy: command not found`** — `$(brew --prefix)/bin`이 PATH에 있는지 확인하세요.
- 그 외: [canopy troubleshooting](https://github.com/neutrospec/canopy/blob/main/docs/troubleshooting.md)

## 이 탭에 대하여

이 저장소는 canopy의 Homebrew 포뮬러(`Formula/canopy.rb`)만 담습니다. 포뮬러의
원본(source of truth)은 canopy 저장소의
[`packaging/homebrew/canopy.rb`](https://github.com/neutrospec/canopy/blob/main/packaging/homebrew/canopy.rb)이며,
릴리스 워크플로우가 매 릴리스마다 여기로 동기화합니다 — `Formula/canopy.rb`를 손으로
고치지 마세요(다음 릴리스가 덮어씁니다). 릴리스·유지보수 방법은
[canopy의 Homebrew 가이드](https://github.com/neutrospec/canopy/blob/main/docs/homebrew-guide.md)에 있습니다.

canopy와 이 포뮬러의 코드 대부분은 **AI 지원 코딩**(Claude Code)으로 작성되었습니다 —
방향과 판단은 사람이, 구현·검증은 AI가 맡는 방식입니다. 자세한 배경은 canopy 저장소의
"개발 방식에 대하여"를 참고하세요.

## 라이선스

[MIT](LICENSE) (canopy 본체와 동일).
