import Foundation
import ArgumentParser
import plate

struct IncomeDivider: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "income",
        abstract: "Divides income into pre-set percentages.",
        subcommands: [
            Divide.self,
        ],
        defaultSubcommand: Divide.self
    )
}

IncomeDivider.main()
