# StarBucksRxSwift

스타벅스 앱의 홈, 메뉴 경험을 RxSwift 기반으로 재구성한 iOS 프로젝트입니다.  
단순히 화면만 비슷하게 만드는 것보다, 기존 실무 코드베이스에서 자주 보이는 `RxSwift + UIKit + MVVM` 흐름을 직접 구현하고 읽어보는 데 목적을 두었습니다.

## 구현 목적

- RxSwift 기반 코드의 데이터 흐름을 직접 설계하고 읽어보기
- `UIKit + MVVM + RxSwift` 조합으로 화면 입력과 출력을 분리해보기
- 네트워크 요청을 `Single`, 화면 바인딩을 `Driver` / `Signal`로 나누는 이유를 코드로 확인해보기
- 캐시, 중복 요청 방지, 화면 이벤트 전달 같은 실무형 문제를 Rx로 다뤄보기
- 모던 컨커런시 이전 문맥에 가까운 환경을 가정하고 `SerialQueue` 기반 상태 보호를 적용해보기

## 주요 화면

<img width="301" height="656" alt="simulator_screenshot_4574E57D-52C4-4312-A643-F8C5E0098496" src="https://github.com/user-attachments/assets/168027f0-2bfc-461f-af28-9bcc952e6fe4" />

<img width="301" height="656" alt="simulator_screenshot_776800AE-5CA8-46D2-979B-D7554741FEF2" src="https://github.com/user-attachments/assets/0c66d659-b9f3-4e03-adad-05e63de5b81f" />

<img width="301" height="656" alt="simulator_screenshot_846ADCF3-FE3C-4BEC-A71B-EB9F5E226856" src="https://github.com/user-attachments/assets/a0ad3e7c-858a-4bf9-9e3a-29ddeca5f974" />

### Home

- 시즌 배너 영역
- 대표 메뉴 가로 스크롤 프리뷰
- 진행 중 프로모션 / 이벤트 프리뷰
- 메뉴 카드 탭 시 상세 화면 이동
- 데이터 로드 실패 시 토스트 메시지 표시

### Menu

- 4개 카테고리 기반 메뉴 조회
  - `Cold Brew`
  - `Espresso`
  - `Blended`
  - `Tea`
- 카테고리 변경 시 메뉴 목록 갱신
- 같은 카테고리 재선택 방지
- 카테고리 변경 후 목록 상단으로 스크롤
- 데이터 로드 실패 시 토스트 메시지 표시

### Detail

- 메뉴 상세 화면 이동
- 홈 / 메뉴 화면에서 동일한 상세 진입 흐름 사용

## 기술 스택

- `UIKit`
- `RxSwift`
- `RxCocoa`
- `SnapKit`
- `URLSession`
- `JSONDecoder`

## 아키텍처

프로젝트는 크게 아래 흐름으로 구성되어 있습니다.

`ViewController -> ViewModel -> Repository -> NetworkService / Store`

### ViewController

- 사용자 이벤트를 `Input`으로 전달
- ViewModel의 `Output`을 받아 화면을 그리는 역할만 담당
- UI 이벤트성 값은 `Signal`
- 화면 상태 값은 `Driver`

예시:

- `HomeViewController`
- `MenuViewController`

### ViewModel

- 화면 입력을 받아 필요한 데이터 흐름으로 변환
- `Input / Output` 구조로 화면 의도를 명확하게 표현
- 네트워크 결과를 바로 UI에 넘기지 않고 화면 단위 데이터로 가공

예시:

- `HomeViewModel`
- `MenuViewModel`

### Repository

- API 호출과 캐시 사용 여부를 결정
- 이미 가져온 데이터가 있으면 `Store` 값을 반환
- 동일 요청이 진행 중이면 `inFlightRequest`를 재사용
- 필요한 경우에만 실제 네트워크 호출 수행

예시:

- `HomeBannerRepository`
- `MenuRepository`
- `EventRepository`

### Store

- 메모리 캐시 역할
- 화면 단위가 아니라 데이터 단위로 현재 값을 보관
- `DispatchQueue(label:)` 기반 `SerialQueue`로 읽기 / 쓰기 보호

예시:

- `HomeBannerStore`
- `MenuStore`
- `EventStore`

## RxSwift 설계 포인트

### 1. 네트워크는 `Single`

네트워크 요청은 보통 한 번 성공하거나 한 번 실패합니다.  
그래서 Repository / Network 계층에서는 `Observable`보다 `Single`을 사용했습니다.

예시:

```swift
func fetchAPI<T: Decodable>(api: BaseAPI) -> Single<T>
```

```swift
private func fetchMenuStream(by menu: GoodsCategory) -> Single<[MenuItemDTO]>
```

### 2. 화면 상태는 `Driver`

배너 목록, 메뉴 목록, 이벤트 목록처럼 UI를 그리기 위한 값은 `Driver`로 변환했습니다.

이유:

- 메인 스레드 보장
- 에러 방출 방지
- 최신 값 공유

예시:

```swift
struct Output {
    var HomeBanners: Driver<[HomeBannerItemDTO]>
    var menus: Driver<[MenuItemDTO]>
    var event: Driver<[StoreEventItemDTO]>
}
```

### 3. 일회성 UI 이벤트는 `Signal`

토스트 메시지처럼 상태라기보다 이벤트에 가까운 값은 `Signal`을 사용했습니다.

예시:

```swift
struct Output {
    var errorMessage: Signal<String>
}
```

### 4. 중복 요청 방지를 위한 `share(replay: 1)`

캐시가 비어 있는 순간 동일 요청이 동시에 들어오면 네트워크가 여러 번 호출될 수 있습니다.  
이를 막기 위해 Repository 내부에 `inFlightRequest`를 두고, 요청 공유 시 `share(replay: 1)`를 사용했습니다.

예시:

```swift
let request = fetchMenuStream(by: menu)
    .do(
        onSuccess: { [weak self] menus in
            self?.store.setMenus(by: menu, menus: menus)
            self?.clearInFlightRequest(by: menu)
        },
        onError: { [weak self] _ in
            self?.clearInFlightRequest(by: menu)
        }
    )
    .asObservable()
    .share(replay: 1)
    .asSingle()
```

### 5. `Actor` 대신 `SerialQueue`

이 프로젝트에서는 일부러 `Actor` 대신 `DispatchQueue(label:)` 기반 `SerialQueue`를 사용했습니다.

이유는 RxSwift 자체가 모던 컨커런시 이전부터 많이 사용되던 기술이고, 실제 RxSwift 코드베이스도 `actor`, `Task`, `MainActor` 중심으로 짜여 있지 않은 경우가 많기 때문입니다.  
이번 구현에서는 RxSwift가 주로 쓰이던 환경과 비슷한 맥락에서 상태 보호와 요청 직렬화를 경험해보는 데 더 의미를 뒀습니다.

## 사용 API

### 홈 배너

- `POST /banner/getBannerList.do`

요청 파라미터:

```text
MENU_CD=STB3136
```

### 진행 중 프로모션 / 이벤트

- `POST /whats_new/getIngList.do`

요청 파라미터:

```text
MENU_CD=all
APP_XPSR_YN=Y
```

### 메뉴

- `GET /upload/json/menu/{categoryCode}.js`

예시:

- `cold_brew`
- `espresso`
- `blended`
- `tea`

## 이미지 처리 방식

- 홈 배너 이미지는 `/upload/banner/` 절대 경로 조합으로 로드
- 이벤트 이미지는 모바일 썸네일 우선, 없으면 웹 썸네일 fallback
- 메뉴 이미지는 API 응답의 이미지 경로를 사용
- 원격 이미지 로드는 `URLSession` 기반 비동기 처리
- 메모리 캐시는 `NSCache<NSURL, UIImage>` 사용

## 현재 구현 범위

- 홈 탭
- 메뉴 탭
- 메뉴 상세
- 홈 내 배너 / 메뉴 / 이벤트 프리뷰
- 메뉴 카테고리 전환
- Repository + Store 기반 메모리 캐시
- 요청 중복 방지
- 토스트 기반 에러 피드백

## 실행 방법

1. Xcode에서 `StarBucksRxSwift.xcodeproj` 열기
2. `StarBucksRxSwift` 스킴 선택
3. iOS Simulator 대상으로 빌드 및 실행

## 빌드 확인

프로젝트는 아래 명령으로 빌드 확인했습니다.

```bash
xcodebuild -project StarBucksRxSwift.xcodeproj \
  -scheme StarBucksRxSwift \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/StarBucksRxSwiftDerived \
  CODE_SIGNING_ALLOWED=NO build
```

## 정리

이 프로젝트는 “RxSwift 문법을 외우는 연습”보다, 실제 Rx 기반 코드에서 데이터가 어떻게 흐르고 어떤 의도로 작성되는지를 읽고 구현해보는 데 초점을 맞췄습니다.  
특히 `Single`, `Driver`, `Signal`, `share(replay: 1)`, `SerialQueue` 같은 선택이 왜 필요한지 코드 레벨에서 직접 확인해보는 데 의미를 둔 프로젝트입니다.
