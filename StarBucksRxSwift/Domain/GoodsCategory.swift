enum GoodsCategory: CaseIterable {
    case coldBrew
    case brewedCoffee
    case espresso
    case prachino
    case blended
    case refresher
    case pizio
    case tea
    case etc
    case juice
    case bread
    case cake
    case sandwichAndSalad
    case warmFood
    case fruitAndYogurt
    case snackAndMiniDessert
    case iceCream

    var code: String {
        switch self {
        case .coldBrew:  "W0000171"
        case .brewedCoffee:  "W0000060"
        case .espresso:  "W0000003"
        case .prachino:  "W0000004"
        case .blended:  "W0000005"
        case .refresher:  "W0000422"
        case .pizio: "W0000061"
        case .tea: "W0000075"
        case .etc: "W0000053"
        case .juice: "W0000062"
        case .bread:
            "W0000013"
        case .cake:
            "W0000032"
        case .sandwichAndSalad:
            "W0000033"
        case .warmFood:
            "W0000054"
        case .fruitAndYogurt:
            "W0000055"
        case .snackAndMiniDessert:
            "W0000056"
        case .iceCream:
            "W0000064"
        }
    }

    var displayName: String {
        switch self {
        case .coldBrew:
            "Cold Brew"
        case .brewedCoffee:
            "Brewed"
        case .espresso:
            "Espresso"
        case .prachino:
            "Frappuccino"
        case .blended:
            "Blended"
        case .refresher:
            "Refresher"
        case .pizio:
            "Fizzio"
        case .tea:
            "Tea"
        case .etc:
            "Etc"
        case .juice:
            "Juice"
        case .bread:
            "Bread"
        case .cake:
            "Cake"
        case .sandwichAndSalad:
            "Sandwich"
        case .warmFood:
            "Warm Food"
        case .fruitAndYogurt:
            "Yogurt"
        case .snackAndMiniDessert:
            "Snack"
        case .iceCream:
            "Ice Cream"
        }
    }

    static var appSections: [GoodsCategory] {
        [.coldBrew, .espresso, .tea, .bread, .cake]
    }
}
