import Foundation
import ArgumentParser
import plate

struct IncomeDividerCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "income",
        abstract: "Divides income into pre-set percentages.",
        subcommands: [
            Divide.self,
        ],
        defaultSubcommand: Divide.self
    )
}

IncomeDividerCLI.main()
