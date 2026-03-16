# Starbucks Korea API Guide For This App

## 1. 이 앱에서 실제로 구현할 API

이번 프로젝트에서 바로 구현하면 되는 것은 아래뿐입니다.

| ID | 화면 | 역할 | Method | Full URL | Body |
| --- | --- | --- | --- | --- | --- |
| `API-01` | 홈 | 상단 배너 조회 | `POST` | `https://www.starbucks.co.kr/banner/getBannerList.do` | `MENU_CD=STB3136` |
| `API-02` | 메뉴 | 카테고리별 메뉴 목록 조회 | `GET` | `https://www.starbucks.co.kr/upload/json/menu/{CATEGORY_CODE}.js` | 없음 |
| `API-03` | 이벤트 목록 | 이벤트 리스트 조회 | `POST` | `https://www.starbucks.co.kr/whats_new/getLsmEvent.do` | `in_evt_code=&search_sido=&search_gugun=&search_store=&search_date=0&page=1` |
| `API-04` | 이벤트 상세 | 특정 이벤트 1건 조회 | `POST` | `https://www.starbucks.co.kr/whats_new/getLsmEvent.do` | `in_evt_code={evt_code}&search_sido=&search_gugun=&search_store=&search_date=0&page=1` |
| `API-05` | 이벤트 필터 | 시/도 목록 조회 | `POST` | `https://www.starbucks.co.kr/store/getSidoList.do` | 빈 body |
| `API-06` | 이벤트 필터 | 구/군 목록 조회 | `POST` | `https://www.starbucks.co.kr/store/getGugunList.do` | `sido_cd={selectedSidoCode}` |

### 중요한 결론

- 메뉴 상세 화면은 `별도 API 호출 없음`
- 메뉴 상세는 `API-02` 응답의 선택된 아이템을 그대로 사용
- 메뉴 카테고리 목록도 `별도 API 없음`
- 메뉴 카테고리는 앱 내부 상수로 관리

## 2. 공통 호출 규칙

| 항목 | 값 |
| --- | --- |
| Base Host | `https://www.starbucks.co.kr` |
| 인증 | 없음 |
| POST Content-Type | `application/x-www-form-urlencoded; charset=UTF-8` |
| 메뉴 응답 | 정적 JSON 파일 |
| 이벤트/배너 응답 | JSON |

### POST 요청 공통 헤더

```http
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
```

## 3. 화면별 구현 순서

### 홈

1. 화면 진입
2. `API-01` 호출
3. 응답 `list`를 배너 배열로 매핑

### 메뉴

1. 앱 내부 카테고리 상수 준비
2. 사용자가 카테고리 선택
3. `API-02` 호출
4. 응답 `list`를 메뉴 목록으로 사용
5. 메뉴 셀 탭
6. 선택한 아이템 전체를 메뉴 상세 화면으로 전달

### 이벤트

1. 화면 진입
2. `API-03` 호출
3. 이벤트 셀 탭
4. `evt_code`로 `API-04` 호출
5. 지역 필터가 필요하면 `API-05`, `API-06` 호출 후 다시 `API-03` 호출

## 4. API 상세

## API-01 홈 배너 조회

### 언제 호출

- 홈 화면 진입 직후

### 요청

| 항목 | 값 |
| --- | --- |
| Method | `POST` |
| URL | `https://www.starbucks.co.kr/banner/getBannerList.do` |
| Body | `MENU_CD=STB3136` |

### cURL

```bash
curl -L -X POST 'https://www.starbucks.co.kr/banner/getBannerList.do' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  --data 'MENU_CD=STB3136'
```

### 응답에서 실제로 쓸 필드

| 응답 필드 | 설명 | 앱에서 사용 |
| --- | --- | --- |
| `list` | 배너 배열 | 배너 리스트 |
| `title` | 배너 제목 | 타이틀 |
| `alt_MSG` | 접근성 텍스트 | 부제 또는 a11y |
| `img_UPLOAD_PATH` | 이미지 호스트 | 이미지 URL 조합 |
| `img_NM` | 웹 배너 파일명 | 이미지 URL 조합 |
| `m_IMG_NM` | 모바일 배너 파일명 | 이미지 URL 조합 |
| `links` | 연결 URL | 탭 시 웹 링크 |

### URL 조합 방식

```text
desktopImageURL = img_UPLOAD_PATH + "/upload/banner/" + img_NM
mobileImageURL = img_UPLOAD_PATH + "/upload/banner/" + m_IMG_NM
```

### 실제 응답 예시

```json
{
  "list": [
    {
      "title": "Spring1 Ph1 프로모션",
      "img_UPLOAD_PATH": "https://image.istarbucks.co.kr",
      "img_NM": "ViQhCO_20260303161533688.jpg",
      "m_IMG_NM": "HM9HTy_20260227102747832.jpg",
      "links": "https://www.starbucks.co.kr/whats_new/campaign_view.do?pro_seq=3296",
      "alt_MSG": "Spring1 Ph1 프로모션"
    }
  ]
}
```

## API-02 메뉴 목록 조회

### 언제 호출

- 메뉴 탭에서 카테고리 선택 직후

### 요청

| 항목 | 값 |
| --- | --- |
| Method | `GET` |
| URL Pattern | `https://www.starbucks.co.kr/upload/json/menu/{CATEGORY_CODE}.js` |
| Body | 없음 |

### 카테고리 목록은 어떻게 처리하나

카테고리 API는 없습니다.
앱에서 아래 상수를 직접 들고 가야 합니다.

### 음료 카테고리 코드

| 이름 | CATEGORY_CODE |
| --- | --- |
| 콜드 브루 | `W0000171` |
| 브루드 커피 | `W0000060` |
| 에스프레소 | `W0000003` |
| 프라푸치노 | `W0000004` |
| 블렌디드 | `W0000005` |
| 스타벅스 리프레셔 | `W0000422` |
| 스타벅스 피지오 | `W0000061` |
| 티(티바나) | `W0000075` |
| 기타 제조 음료 | `W0000053` |
| 스타벅스 주스(병음료) | `W0000062` |

### 푸드 카테고리 코드

| 이름 | CATEGORY_CODE |
| --- | --- |
| 브레드 | `W0000013` |
| 케이크 | `W0000032` |
| 샌드위치 & 샐러드 | `W0000033` |
| 따뜻한 푸드 | `W0000054` |
| 과일 & 요거트 | `W0000055` |
| 스낵 & 미니 디저트 | `W0000056` |
| 아이스크림 | `W0000064` |

### 실제 URL 예시

| 카테고리 | URL |
| --- | --- |
| 콜드 브루 | `https://www.starbucks.co.kr/upload/json/menu/W0000171.js` |
| 에스프레소 | `https://www.starbucks.co.kr/upload/json/menu/W0000003.js` |
| 브레드 | `https://www.starbucks.co.kr/upload/json/menu/W0000013.js` |

### cURL

```bash
curl -L 'https://www.starbucks.co.kr/upload/json/menu/W0000171.js'
```

### 응답에서 실제로 쓸 필드

| 응답 필드 | 설명 | 앱에서 사용 |
| --- | --- | --- |
| `list` | 메뉴 배열 | 메뉴 리스트 |
| `product_CD` | 메뉴 ID | 상세 식별자 |
| `product_NM` | 메뉴명 | 제목 |
| `content` | 설명 | 서브텍스트 |
| `img_UPLOAD_PATH` | 이미지 호스트 | 이미지 URL 조합 |
| `file_PATH` | 이미지 경로 | 이미지 URL 조합 |
| `cate_NAME` | 카테고리명 | 카테고리 표시 |
| `kcal` | 칼로리 | 영양 정보 |
| `sugars` | 당류 | 영양 정보 |
| `protein` | 단백질 | 영양 정보 |
| `sodium` | 나트륨 | 영양 정보 |
| `caffeine` | 카페인 | 영양 정보 |
| `sat_FAT` | 포화지방 | 영양 정보 |
| `newicon` | 신규 여부 | `NEW` 뱃지 |
| `recomm` | 추천 여부 | 추천 뱃지 |
| `sold_OUT` | 품절 여부 | 품절 상태 |

### URL 조합 방식

```text
imageURL = img_UPLOAD_PATH + file_PATH
```

### 실제 응답 예시

```json
{
  "list": [
    {
      "product_CD": "9200000002487",
      "product_NM": "나이트로 바닐라 크림",
      "content": "부드러운 목넘김의 나이트로 커피와 바닐라 크림의 매력을 한번에 느껴보세요!",
      "file_PATH": "/upload/store/skuimg/2025/06/[9200000002487]_20250626171201110.jpg",
      "img_UPLOAD_PATH": "https://www.istarbucks.co.kr",
      "cate_NAME": "콜드 브루",
      "kcal": "80",
      "sugars": "10",
      "protein": "1",
      "sodium": "40",
      "caffeine": "232",
      "sat_FAT": "2",
      "newicon": "N",
      "recomm": "0",
      "sold_OUT": "N"
    }
  ]
}
```

### 메뉴 상세는 어떻게 처리하나

- 별도 API 호출 없음
- 목록에서 선택한 `MenuItem` 전체를 상세 화면으로 전달

### 왜 이렇게 하는가

- 현재 공개 데이터 기준으로는 이 JSON 안에 상세 화면에 필요한 핵심 정보가 이미 들어 있음
- 가격은 비어 있는 경우가 많아서, 주문 앱 수준의 정밀한 상세는 불가능
- 지금 프로젝트 범위에서는 `목록 API 하나로 상세까지 처리`가 맞음

### 현재 제약

| 항목 | 상태 |
| --- | --- |
| 가격 | 비어 있는 경우 많음 |
| 영문명 | 안정적이지 않음 |
| 주문 옵션 | 없음 |
| 사이즈 정보 | 없음 |

## API-03 이벤트 목록 조회

### 언제 호출

- 이벤트 화면 진입 시
- 필터 변경 시
- 페이지 이동 시

### 요청

| 항목 | 값 |
| --- | --- |
| Method | `POST` |
| URL | `https://www.starbucks.co.kr/whats_new/getLsmEvent.do` |
| Body | `in_evt_code=&search_sido=&search_gugun=&search_store=&search_date=0&page=1` |

### Body 필드 설명

| Key | Required | Example | 설명 |
| --- | --- | --- | --- |
| `in_evt_code` | No | `` | 상세 조회 시만 사용 |
| `search_sido` | No | `01` | 시/도 코드 |
| `search_gugun` | No | `0101` | 구/군 코드 |
| `search_store` | No | `강남역` | 매장명 검색 |
| `search_date` | Yes | `0` | `0=전체`, `1=신규매장`, `2=종료` |
| `page` | Yes | `1` | 페이지 번호 |

### cURL

```bash
curl -L -X POST 'https://www.starbucks.co.kr/whats_new/getLsmEvent.do' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  --data 'in_evt_code=&search_sido=&search_gugun=&search_store=&search_date=0&page=1'
```

### 응답에서 실제로 쓸 필드

| 응답 필드 | 설명 | 앱에서 사용 |
| --- | --- | --- |
| `recordCount` | 총 개수 | 페이지네이션 |
| `pagesize` | 페이지 크기 | 페이지네이션 |
| `page` | 현재 페이지 | 페이지네이션 |
| `list` | 이벤트 배열 | 이벤트 리스트 |
| `evt_code` | 이벤트 ID | 상세 진입 |
| `evt_name` | 이벤트 제목 | 제목 |
| `evt_desc` | 이벤트 설명 | 요약/본문 |
| `evt_memo` | 유의사항 | 상세 하단 |
| `s_name` | 매장명 | 부제 |
| `s_image` | 이미지 경로 | 썸네일 |
| `start_date` | 시작일 | 기간 |
| `end_date` | 종료일 | 기간 |
| `s_new` | 신규 매장 여부 | 뱃지 |

### 실제 응답 예시

```json
{
  "recordCount": 4,
  "pagesize": 10,
  "page": 1,
  "list": [
    {
      "evt_code": "260207399",
      "evt_name": "[고양원당역] 신규점 오픈 이벤트",
      "evt_desc": "1. 제조음료포함 20,000원 이상 구매시 로고머그 증정...",
      "evt_memo": "[유의사항] ...",
      "s_name": "고양원당역",
      "s_image": "/upload/store/2026/03/4766_20260306024723_7b6lq.png",
      "start_date": "2026-03-10",
      "end_date": "2026-03-15",
      "s_new": "Y"
    }
  ]
}
```

## API-04 이벤트 상세 조회

### 언제 호출

- 이벤트 셀을 눌렀을 때

### 요청

| 항목 | 값 |
| --- | --- |
| Method | `POST` |
| URL | `https://www.starbucks.co.kr/whats_new/getLsmEvent.do` |
| Body Pattern | `in_evt_code={evt_code}&search_sido=&search_gugun=&search_store=&search_date=0&page=1` |

### cURL

```bash
curl -L -X POST 'https://www.starbucks.co.kr/whats_new/getLsmEvent.do' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  --data 'in_evt_code=260207399&search_sido=&search_gugun=&search_store=&search_date=0&page=1'
```

### 사용 방식

1. 목록에서 `evt_code`를 받음
2. `in_evt_code`에 넣어서 다시 호출
3. 응답 `list[0]`를 상세 화면 데이터로 사용

### 상세 화면에서 쓸 필드

| 응답 필드 | 앱에서 사용 |
| --- | --- |
| `evt_name` | 제목 |
| `evt_desc` | 본문 |
| `evt_memo` | 유의사항 |
| `s_name` | 매장명 |
| `s_image` | 대표 이미지 |
| `start_date`, `end_date` | 기간 |

## API-05 시/도 목록 조회

### 언제 호출

- 이벤트 지역 필터 화면을 열 때

### 요청

| 항목 | 값 |
| --- | --- |
| Method | `POST` |
| URL | `https://www.starbucks.co.kr/store/getSidoList.do` |
| Body | 빈 body |

### cURL

```bash
curl -L -X POST 'https://www.starbucks.co.kr/store/getSidoList.do' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  --data ''
```

### 응답에서 실제로 쓸 필드

| 응답 필드 | 앱에서 사용 |
| --- | --- |
| `sido_cd` | 시/도 코드 |
| `sido_nm` | 시/도 이름 |

## API-06 구/군 목록 조회

### 언제 호출

- 사용자가 시/도를 고른 직후

### 요청

| 항목 | 값 |
| --- | --- |
| Method | `POST` |
| URL | `https://www.starbucks.co.kr/store/getGugunList.do` |
| Body | `sido_cd={selectedSidoCode}` |

### Body 필드 설명

| Key | Required | Example | 설명 |
| --- | --- | --- | --- |
| `sido_cd` | Yes | `01` | 선택한 시/도 코드 |

### cURL

```bash
curl -L -X POST 'https://www.starbucks.co.kr/store/getGugunList.do' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  --data 'sido_cd=01'
```

### 응답에서 실제로 쓸 필드

| 응답 필드 | 앱에서 사용 |
| --- | --- |
| `gugun_cd` | 구/군 코드 |
| `gugun_nm` | 구/군 이름 |

## 5. 구현할 때 그대로 따르면 되는 규칙

### 홈

- `API-01`만 구현

### 메뉴

- 카테고리 배열은 앱 내부에 하드코딩
- 메뉴 목록은 `API-02`
- 메뉴 상세는 `API-02` 응답 재사용
- 메뉴 상세용 별도 API는 만들지 않음

### 이벤트

- 이벤트 목록은 `API-03`
- 이벤트 상세는 `API-04`
- 지역 필터는 `API-05`, `API-06`

## 6. 지금 구현하지 않아도 되는 것

- 로그인 API
- 가격 정확도 보강용 별도 상세 API
- 주문 옵션 API
- 개인화 추천 API

## 7. 최종 정리

지금 네가 구현할 때 외워야 할 건 이 정도입니다.

- 홈 진입: `POST /banner/getBannerList.do` with `MENU_CD=STB3136`
- 메뉴 카테고리 선택: `GET /upload/json/menu/{CATEGORY_CODE}.js`
- 메뉴 상세 진입: 추가 호출 없음
- 이벤트 목록: `POST /whats_new/getLsmEvent.do`
- 이벤트 상세: 같은 API에 `in_evt_code` 넣어서 재호출
- 시/도 목록: `POST /store/getSidoList.do`
- 구/군 목록: `POST /store/getGugunList.do` with `sido_cd`
