import Foundation

enum MockStarbucksData {
    static let banners: [HomeBannerItemDTO] = [
        HomeBannerItemDTO(
            menuCode: "STB3136",
            title: "Spring Berry Glow",
            imageUploadPath: nil,
            imageName: nil,
            mobileImageName: nil,
            link: "https://www.starbucks.co.kr",
            altMessage: "봄 시즌 프로모션과 메인 배너 노출 예시",
            viewStartDate: "2026-03-30",
            viewEndDate: "2026-04-30"
        ),
        HomeBannerItemDTO(
            menuCode: "STB3136",
            title: "Reserve Coffee Moment",
            imageUploadPath: nil,
            imageName: nil,
            mobileImageName: nil,
            link: "https://www.starbucks.co.kr",
            altMessage: "리저브 원두와 스토리형 홈 카드 예시",
            viewStartDate: "2026-03-30",
            viewEndDate: "2026-04-15"
        ),
        HomeBannerItemDTO(
            menuCode: "STB3136",
            title: "Dessert Pairing Week",
            imageUploadPath: nil,
            imageName: nil,
            mobileImageName: nil,
            link: "https://www.starbucks.co.kr",
            altMessage: "푸드와 음료 페어링 추천 배너 예시",
            viewStartDate: "2026-04-01",
            viewEndDate: "2026-04-20"
        )
    ]

    static let menuItemsByCategory: [GoodsCategory: [MenuItemDTO]] = [
        .coldBrew: [
            makeMenuItem(
                code: "9200000002487",
                name: "콜드 브루 오트 라떼",
                description: "부드러운 오트와 깔끔한 콜드 브루 조합",
                category: "콜드 브루",
                kcal: "110",
                sugars: "12",
                protein: "2",
                sodium: "45",
                caffeine: "155",
                isNew: true,
                isRecommended: true
            ),
            makeMenuItem(
                code: "9200000002488",
                name: "나이트로 바닐라 크림",
                description: "부드러운 크림과 나이트로 커피의 조합",
                category: "콜드 브루",
                kcal: "80",
                sugars: "10",
                protein: "1",
                sodium: "40",
                caffeine: "232",
                isNew: false,
                isRecommended: true
            )
        ],
        .espresso: [
            makeMenuItem(
                code: "9200000002489",
                name: "카페 아메리카노",
                description: "진한 에스프레소 샷과 뜨거운 물의 클래식 조합",
                category: "에스프레소",
                kcal: "10",
                sugars: "0",
                protein: "1",
                sodium: "5",
                caffeine: "150",
                isNew: false,
                isRecommended: true
            ),
            makeMenuItem(
                code: "9200000002490",
                name: "카라멜 마키아또",
                description: "에스프레소와 바닐라 시럽, 카라멜 드리즐",
                category: "에스프레소",
                kcal: "200",
                sugars: "22",
                protein: "6",
                sodium: "120",
                caffeine: "95",
                isNew: false,
                isRecommended: false
            )
        ],
        .tea: [
            makeMenuItem(
                code: "9200000002491",
                name: "자몽 허니 블랙 티",
                description: "상큼한 자몽과 깊은 블랙 티의 밸런스",
                category: "티",
                kcal: "125",
                sugars: "29",
                protein: "0",
                sodium: "5",
                caffeine: "30",
                isNew: false,
                isRecommended: true
            ),
            makeMenuItem(
                code: "9200000002492",
                name: "얼 그레이 티",
                description: "향긋한 베르가못 향이 살아있는 대표 티",
                category: "티",
                kcal: "0",
                sugars: "0",
                protein: "0",
                sodium: "0",
                caffeine: "40",
                isNew: false,
                isRecommended: false
            )
        ],
        .bread: [
            makeMenuItem(
                code: "9300000001101",
                name: "바질 치즈 치아바타",
                description: "식사 대용으로 가볍게 즐길 수 있는 치아바타",
                category: "브레드",
                kcal: "320",
                sugars: "6",
                protein: "12",
                sodium: "520",
                caffeine: "0",
                isNew: true,
                isRecommended: false
            )
        ],
        .cake: [
            makeMenuItem(
                code: "9300000002101",
                name: "딸기 생크림 케이크",
                description: "시즌 무드에 맞춘 대표 디저트 케이크",
                category: "케이크",
                kcal: "420",
                sugars: "31",
                protein: "5",
                sodium: "180",
                caffeine: "0",
                isNew: true,
                isRecommended: true
            )
        ]
    ]

    static let featuredMenuItems: [MenuItemDTO] = [
        menuItemsByCategory[.coldBrew]?.first,
        menuItemsByCategory[.tea]?.first,
        menuItemsByCategory[.cake]?.first
    ].compactMap { $0 }

    static let events: [StoreEventItemDTO] = [
        StoreEventItemDTO(
            eventCode: "260207399",
            eventName: "리저브 원두 테이스팅 위크",
            eventDescription: "리저브 원두를 중심으로 한 시음 이벤트와 노트 소개를 홈과 이벤트 탭에서 노출하는 예시입니다.",
            eventMemo: "매장별 진행 일정은 상이할 수 있습니다.",
            storeName: nil,
            storeImage: nil,
            startDate: "2026-03-30",
            endDate: "2026-04-12",
            eventStartDate: nil,
            eventEndDate: nil,
            isNewStore: nil
        ),
        StoreEventItemDTO(
            eventCode: "260207400",
            eventName: "봄 시즌 디저트 페어링",
            eventDescription: "봄 시즌 음료와 디저트 조합을 소개하는 프로모션 예시입니다.",
            eventMemo: "재고 상황에 따라 일부 매장 제외",
            storeName: nil,
            storeImage: nil,
            startDate: "2026-04-01",
            endDate: "2026-04-20",
            eventStartDate: nil,
            eventEndDate: nil,
            isNewStore: nil
        ),
        StoreEventItemDTO(
            eventCode: "260207401",
            eventName: "멤버십 티저 캠페인",
            eventDescription: "로그인 기능은 제외하지만, 홈과 이벤트 화면에서 캠페인 카드 구성을 확인하기 위한 목 데이터입니다.",
            eventMemo: "실제 서비스 연동 시 CTA 문구 변경 예정",
            storeName: nil,
            storeImage: nil,
            startDate: "2026-04-05",
            endDate: "2026-04-30",
            eventStartDate: nil,
            eventEndDate: nil,
            isNewStore: nil
        )
    ]

    static func menuItems(for category: GoodsCategory) -> [MenuItemDTO] {
        menuItemsByCategory[category] ?? []
    }

    static func event(with code: String) -> StoreEventItemDTO? {
        events.first { $0.eventCode == code }
    }

    private static func makeMenuItem(
        code: String,
        name: String,
        description: String,
        category: String,
        kcal: String,
        sugars: String,
        protein: String,
        sodium: String,
        caffeine: String,
        isNew: Bool,
        isRecommended: Bool
    ) -> MenuItemDTO {
        MenuItemDTO(
            productCode: code,
            productName: name,
            content: description,
            filePath: nil,
            imageUploadPath: nil,
            categoryName: category,
            kcal: kcal,
            sugars: sugars,
            protein: protein,
            sodium: sodium,
            caffeine: caffeine,
            saturatedFat: "0",
            newIcon: isNew ? "N" : "0",
            recommend: isRecommended ? "1" : "0",
            soldOut: "N",
            price: nil
        )
    }
}
