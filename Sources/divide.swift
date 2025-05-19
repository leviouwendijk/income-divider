import Foundation
import ArgumentParser
import plate

enum DivideType: String, Codable {
    case absolute  // from initial principal
    case relative  // from remaining balance
}

struct Divisor: Codable {
    let order: Int
    let percentage: Double
    let type: DivideType
}

struct DivideAccount: Codable {
    let name: String
    let divisor: Divisor
}

struct DistributionEntry: Codable {
    let account: String
    let divisor: Divisor
    let base: Double       // amount base was calculated from
    let amount: Double     // calculated split amount
    let remaining: Double  // balance after this split
}

struct DistributionSummary: Codable {
    let principal: Double
    let entries: [DistributionEntry]
    var totalDistributed: Double { entries.map { $0.amount }.reduce(0, +) }
    var finalRemainder: Double { entries.last?.remaining ?? principal }

    var percentDistributed: Double { totalDistributed / principal * 100 }
    var percentRemaining: Double { finalRemainder  / principal * 100 }

    func textReport(width: Int = 20) -> String {
        var s = [String]()
        s.append("")
        s.append("Dividing income: \(principal)")
        s.append(String(repeating: "-", count: width))
        s.append("")
        for entry in entries {
            s.append("Account: \(entry.account)")
            s.append("    Order: \(entry.divisor.order)")
            s.append("    Type: \(entry.divisor.type.rawValue)")
            s.append(String(format: "    Split: %\(width).2f = %.2f%% of %.2f", entry.amount, entry.divisor.percentage, entry.base))
            s.append("")
        }
        s.append(String(repeating: "=", count: width))
        s.append(String(format: "Metrics for: %.2f", principal))
        s.append("")
        s.append(String(format: "Total distributed: %.2f", totalDistributed))
        s.append(String(format: "Remainder: %.2f", finalRemainder))
        s.append("")
        s.append(String(format: "Percent distributed: %.2f%%", percentDistributed))
        s.append(String(format: "Percent remaining: %.2f%%", percentRemaining))
        s.append("")

        return s.joined(separator: "\n")
    }
}

struct IncomeDivider {
    var accounts: [DivideAccount]

    init(accounts: [DivideAccount]) {
        self.accounts = accounts.sorted { $0.divisor.order < $1.divisor.order }
    }

    func divide(_ income: Double) -> DistributionSummary {
        var remainder = income
        var entries = [DistributionEntry]()

        for account in accounts {
            let pct = account.divisor.percentage / 100
            let base = (account.divisor.type == .relative) ? remainder : income
            let amount = base * pct
            remainder = base - amount
            let entry = DistributionEntry(
                account: account.name,
                divisor: account.divisor,
                base: base,
                amount: amount,
                remaining: remainder
            )
            entries.append(entry)
        }

        return DistributionSummary(principal: income, entries: entries)
    }
}

enum OutputFormat: String, ExpressibleByArgument {
    case text
    case json
    case plist
}

struct Divide: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "divide",
        abstract: "Divide an income across multiple accounts."
    )

    @Argument(help: "The total income to divide.")
    var income: Double

    @Option(name: .shortAndLong, help: "Output format: text, json, or plist.")
    var format: OutputFormat = .text

    @Flag(help: "Compare to old configuration")
    var compare: Bool = false

    func run() throws {
        print()
        print("Current Division Strategy:".ansi(.bold))
        let defaultDivisionAccounts = defaults()

        try distribute(for: defaultDivisionAccounts, format: format)

        if compare {
            print()
            print("Previous Division Strategy:".ansi(.bold))
            let previousDivisionAccounts = previous()
            try distribute(for: previousDivisionAccounts, format: format)
        }
    }

    func distribute(for accounts: [DivideAccount], format: OutputFormat) throws {
        let divider = IncomeDivider(accounts: accounts)
        let summary = divider.divide(income)

        switch format {
        case .text:
            print(summary.textReport())

        case .json:
            let data = try JSONEncoder().encode(summary)
            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }

        case .plist:
            let data = try PropertyListEncoder().encode(summary)
            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }
        }
    }

    private func previous() -> [DivideAccount] {
        return [
            DivideAccount(
                name: "Savings",
                divisor: Divisor(order: 1, percentage: 10, type: .absolute)
            ),
            DivideAccount(
                name: "IncomeTax",
                divisor: Divisor(order: 2, percentage: 25, type: .relative)
            ),
            DivideAccount(
                name: "Charges",
                divisor: Divisor(order: 3, percentage: 10, type: .relative)
            )
        ]
    }

    private func defaults() -> [DivideAccount] {
        return [
            DivideAccount(
                name: "Savings",
                divisor: Divisor(order: 1, percentage: 10, type: .absolute)
            ),
            DivideAccount(
                name: "IncomeTax",
                divisor: Divisor(order: 2, percentage: 25, type: .relative)
            ),
            DivideAccount(
                name: "Charges",
                divisor: Divisor(order: 3, percentage: 5, type: .relative)
            ),
            DivideAccount(
                name: "Purchases",
                divisor: Divisor(order: 4, percentage: 20, type: .relative)
            )
        ]
    }
}
