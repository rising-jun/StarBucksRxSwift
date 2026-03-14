# Starbucks Clone API Spec

## 1. 문서 목적

이 문서는 로그인 이전 구간만 구현하는 스타벅스 클론앱을 위한 API 명세입니다.
앱에서는 아래 기능만 지원합니다.

- 홈 화면 진입
- 홈 상단 배너 및 프로모션 섹션 조회
- 이벤트 목록 조회
- 이벤트 상세 조회
- 메뉴 카테고리 조회
- 메뉴 목록 조회
- 메뉴 상세 조회

아래 기능은 이번 범위에서 제외합니다.

- 로그인 / 회원가입
- 개인화 추천
- 장바구니 / 주문 / 결제
- 쿠폰 / 리워드 / 스탬프
- 매장 찾기 / 픽업 주문
- 좋아요 / 최근 본 메뉴 / 알림

## 2. 기본 정보

- Base URL: `https://api.starbucks-clone.example.com`
- API Version: `v1`
- Content-Type: `application/json; charset=utf-8`
- 인증: 없음
- 시간대 기준: `Asia/Seoul`

## 3. 공통 요청 규칙

### Headers

| Header | Required | Description |
| --- | --- | --- |
| `X-App-Version` | No | 앱 버전. 예: `1.0.0` |
| `X-Platform` | No | `iOS` 고정 |
| `Accept-Language` | No | 기본값 `ko-KR` |

### Query Rules

- 페이지네이션은 cursor 기반을 사용합니다.
- `cursor`가 없으면 첫 페이지입니다.
- `limit` 기본값은 `20`, 최대값은 `50`입니다.

## 4. 공통 응답 형식

모든 응답은 아래 포맷을 사용합니다.

```json
{
  "success": true,
  "code": "COMMON-200",
  "message": "OK",
  "data": {}
}
```

### 실패 응답 예시

```json
{
  "success": false,
  "code": "MENU-404",
  "message": "Menu not found.",
  "data": null
}
```

## 5. 공통 에러 코드

| HTTP Status | Code | Description |
| --- | --- | --- |
| `400` | `COMMON-400` | 잘못된 요청 파라미터 |
| `404` | `COMMON-404` | 리소스를 찾을 수 없음 |
| `429` | `COMMON-429` | 요청 횟수 초과 |
| `500` | `COMMON-500` | 서버 내부 오류 |

## 6. 데이터 모델

### 6.1 Image

| Field | Type | Description |
| --- | --- | --- |
| `imageUrl` | String | 원본 이미지 URL |
| `thumbnailUrl` | String | 썸네일 이미지 URL |
| `alt` | String | 접근성용 대체 텍스트 |

### 6.2 HomeSection

| Field | Type | Description |
| --- | --- | --- |
| `sectionId` | String | 섹션 ID |
| `type` | String | `heroBanner`, `featuredMenu`, `eventCarousel`, `promotionBanner` |
| `title` | String | 섹션 제목 |
| `subtitle` | String | 섹션 부제목 |
| `items` | Array | 섹션 아이템 목록 |

### 6.3 EventSummary

| Field | Type | Description |
| --- | --- | --- |
| `eventId` | String | 이벤트 ID |
| `title` | String | 이벤트 제목 |
| `summary` | String | 요약 문구 |
| `thumbnailImageUrl` | String | 썸네일 이미지 |
| `label` | String | 예: `진행중`, `종료예정` |
| `startAt` | String | ISO-8601 |
| `endAt` | String | ISO-8601 |

### 6.4 MenuCategory

| Field | Type | Description |
| --- | --- | --- |
| `categoryId` | String | 카테고리 ID |
| `name` | String | 카테고리명 |
| `displayOrder` | Int | 노출 순서 |
| `imageUrl` | String | 카테고리 대표 이미지 |

### 6.5 MenuItem

| Field | Type | Description |
| --- | --- | --- |
| `menuId` | String | 메뉴 ID |
| `categoryId` | String | 카테고리 ID |
| `name` | String | 메뉴명 |
| `nameEn` | String | 영문명 |
| `description` | String | 짧은 설명 |
| `price` | Int | 기본 가격, 원 단위 |
| `currency` | String | `KRW` |
| `imageUrl` | String | 대표 이미지 |
| `badge` | String | 예: `NEW`, `BEST` |
| `isSoldOut` | Bool | 품절 여부 |
| `temperature` | String | `iced`, `hot`, `both`, `none` |

## 7. API 목록

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/v1/home` | 홈 화면 전체 데이터 조회 |
| `GET` | `/api/v1/events` | 이벤트 목록 조회 |
| `GET` | `/api/v1/events/{eventId}` | 이벤트 상세 조회 |
| `GET` | `/api/v1/menu/categories` | 메뉴 카테고리 조회 |
| `GET` | `/api/v1/menu/items` | 메뉴 목록 조회 |
| `GET` | `/api/v1/menu/items/{menuId}` | 메뉴 상세 조회 |

## 8. 상세 명세

### 8.1 홈 화면 조회

- Method: `GET`
- Path: `/api/v1/home`

#### Query Parameters

없음

#### Response

```json
{
  "success": true,
  "code": "COMMON-200",
  "message": "OK",
  "data": {
    "screenTitle": "Starbucks",
    "sections": [
      {
        "sectionId": "home-hero-001",
        "type": "heroBanner",
        "title": "봄 시즌 한정 음료",
        "subtitle": "지금 가장 인기 있는 시즌 메뉴를 만나보세요",
        "items": [
          {
            "targetType": "menu",
            "targetId": "menu_jeju_matcha_latte",
            "imageUrl": "https://cdn.example.com/home/hero/matcha.jpg",
            "thumbnailUrl": "https://cdn.example.com/home/hero/matcha_thumb.jpg",
            "alt": "제주 말차 라떼 배너",
            "label": "NEW"
          }
        ]
      },
      {
        "sectionId": "home-event-001",
        "type": "eventCarousel",
        "title": "진행 중인 이벤트",
        "subtitle": "스타벅스 소식을 확인해보세요",
        "items": [
          {
            "targetType": "event",
            "targetId": "event_spring_stamp",
            "imageUrl": "https://cdn.example.com/events/spring-stamp.jpg",
            "thumbnailUrl": "https://cdn.example.com/events/spring-stamp-thumb.jpg",
            "alt": "봄 시즌 이벤트",
            "label": "진행중"
          }
        ]
      }
    ]
  }
}
```

#### Notes

- 홈 화면에 필요한 데이터는 한 번에 내려줍니다.
- 각 섹션의 `targetType`은 `menu`, `event`, `external` 중 하나입니다.
- `external`인 경우 앱 외부 브라우저 링크를 위한 `targetUrl`이 추가될 수 있습니다.

### 8.2 이벤트 목록 조회

- Method: `GET`
- Path: `/api/v1/events`

#### Query Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `status` | String | No | `ongoing`, `scheduled`, `ended` |
| `cursor` | String | No | 다음 페이지 조회 커서 |
| `limit` | Int | No | 기본 20, 최대 50 |

#### Response

```json
{
  "success": true,
  "code": "COMMON-200",
  "message": "OK",
  "data": {
    "items": [
      {
        "eventId": "event_spring_stamp",
        "title": "봄 시즌 스탬프 이벤트",
        "summary": "시즌 음료 구매 시 스탬프 적립",
        "thumbnailImageUrl": "https://cdn.example.com/events/spring-stamp-thumb.jpg",
        "label": "진행중",
        "startAt": "2026-03-01T00:00:00+09:00",
        "endAt": "2026-03-31T23:59:59+09:00"
      }
    ],
    "nextCursor": "eyJpZCI6ImV2ZW50XzAwMiJ9",
    "hasNext": true
  }
}
```

### 8.3 이벤트 상세 조회

- Method: `GET`
- Path: `/api/v1/events/{eventId}`

#### Path Parameters

| Name | Type | Description |
| --- | --- | --- |
| `eventId` | String | 이벤트 ID |

#### Response

```json
{
  "success": true,
  "code": "COMMON-200",
  "message": "OK",
  "data": {
    "eventId": "event_spring_stamp",
    "title": "봄 시즌 스탬프 이벤트",
    "summary": "시즌 음료 구매 시 스탬프 적립",
    "description": "대상 음료 구매 시 스탬프를 적립할 수 있는 이벤트입니다.",
    "heroImageUrl": "https://cdn.example.com/events/spring-stamp-detail.jpg",
    "startAt": "2026-03-01T00:00:00+09:00",
    "endAt": "2026-03-31T23:59:59+09:00",
    "contents": [
      {
        "type": "image",
        "value": "https://cdn.example.com/events/spring-stamp-body-1.jpg"
      },
      {
        "type": "text",
        "value": "이벤트 유의사항 및 참여 방법"
      }
    ],
    "button": {
      "title": "메뉴 보러가기",
      "targetType": "menuCategory",
      "targetId": "beverage"
    }
  }
}
```

#### Error Codes

| HTTP Status | Code | Description |
| --- | --- | --- |
| `404` | `EVENT-404` | 이벤트 상세가 존재하지 않음 |

### 8.4 메뉴 카테고리 조회

- Method: `GET`
- Path: `/api/v1/menu/categories`

#### Response

```json
{
  "success": true,
  "code": "COMMON-200",
  "message": "OK",
  "data": {
    "items": [
      {
        "categoryId": "beverage",
        "name": "음료",
        "displayOrder": 1,
        "imageUrl": "https://cdn.example.com/categories/beverage.jpg"
      },
      {
        "categoryId": "food",
        "name": "푸드",
        "displayOrder": 2,
        "imageUrl": "https://cdn.example.com/categories/food.jpg"
      },
      {
        "categoryId": "md",
        "name": "상품",
        "displayOrder": 3,
        "imageUrl": "https://cdn.example.com/categories/md.jpg"
      }
    ]
  }
}
```

### 8.5 메뉴 목록 조회

- Method: `GET`
- Path: `/api/v1/menu/items`

#### Query Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `categoryId` | String | Yes | 카테고리 ID |
| `cursor` | String | No | 다음 페이지 조회 커서 |
| `limit` | Int | No | 기본 20, 최대 50 |
| `badge` | String | No | `NEW`, `BEST`, `SEASONAL` |
| `temperature` | String | No | `iced`, `hot`, `both` |

#### Response

```json
{
  "success": true,
  "code": "COMMON-200",
  "message": "OK",
  "data": {
    "category": {
      "categoryId": "beverage",
      "name": "음료"
    },
    "items": [
      {
        "menuId": "menu_jeju_matcha_latte",
        "categoryId": "beverage",
        "name": "제주 말차 라떼",
        "nameEn": "Jeju Matcha Latte",
        "description": "깊고 진한 말차 풍미의 라떼",
        "price": 6100,
        "currency": "KRW",
        "imageUrl": "https://cdn.example.com/menu/jeju-matcha-latte.jpg",
        "badge": "NEW",
        "isSoldOut": false,
        "temperature": "both"
      }
    ],
    "nextCursor": null,
    "hasNext": false
  }
}
```

#### Error Codes

| HTTP Status | Code | Description |
| --- | --- | --- |
| `400` | `MENU-001` | `categoryId` 누락 |
| `404` | `MENU-404` | 카테고리를 찾을 수 없음 |

### 8.6 메뉴 상세 조회

- Method: `GET`
- Path: `/api/v1/menu/items/{menuId}`

#### Path Parameters

| Name | Type | Description |
| --- | --- | --- |
| `menuId` | String | 메뉴 ID |

#### Response

```json
{
  "success": true,
  "code": "COMMON-200",
  "message": "OK",
  "data": {
    "menuId": "menu_jeju_matcha_latte",
    "categoryId": "beverage",
    "name": "제주 말차 라떼",
    "nameEn": "Jeju Matcha Latte",
    "description": "깊고 진한 말차 풍미의 라떼",
    "price": 6100,
    "currency": "KRW",
    "imageUrl": "https://cdn.example.com/menu/jeju-matcha-latte.jpg",
    "badge": "NEW",
    "isSoldOut": false,
    "temperature": "both",
    "nutrition": {
      "calories": 245,
      "sugar": 31,
      "protein": 8,
      "sodium": 120,
      "caffeine": 85
    },
    "allergens": [
      "milk"
    ],
    "descriptions": [
      "말차와 우유가 조화롭게 어우러진 시즌 음료",
      "HOT / ICED 모두 제공"
    ]
  }
}
```

#### Error Codes

| HTTP Status | Code | Description |
| --- | --- | --- |
| `404` | `MENU-404` | 메뉴 상세가 존재하지 않음 |

## 9. 클라이언트 구현 가이드

### 홈 화면

- 앱 실행 후 첫 진입에서 `/api/v1/home` 호출
- 홈 섹션 탭 시 `targetType`에 따라 메뉴 상세 또는 이벤트 상세로 이동

### 이벤트 화면

- 기본값으로 `/api/v1/events?status=ongoing` 호출
- 무한 스크롤이 필요하면 `nextCursor`를 사용

### 메뉴 화면

- 진입 시 `/api/v1/menu/categories` 호출
- 카테고리 선택 시 `/api/v1/menu/items?categoryId={id}` 호출
- 셀 선택 시 `/api/v1/menu/items/{menuId}` 호출

## 10. 목업 서버용 샘플 리소스 제안

- 카테고리 수: 3개
- 메뉴 수: 카테고리별 8~12개
- 이벤트 수: 5개
- 홈 섹션 수: 3~5개

이 정도면 RxSwift 연습용으로 충분히 화면 전환, 리스트 바인딩, 상세 화면 진입, 로딩/에러 상태 처리를 구현할 수 있습니다.

## 11. 향후 확장 포인트

다음 단계에서 로그인 이후 기능을 추가할 경우 아래 API를 별도 버전으로 확장하면 됩니다.

- `POST /api/v1/auth/login`
- `GET /api/v1/me`
- `POST /api/v1/orders`
- `GET /api/v1/rewards`
- `GET /api/v1/stores`
