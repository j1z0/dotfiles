// appearance-watch — run a command whenever macOS flips light/dark.
//
// This exists because macOS has no way to notify a shell script about
// appearance changes. Polling `defaults read -g AppleInterfaceStyle` on a timer
// works but spawns a process every few seconds forever; this observes the
// distributed notification instead and stays idle in between.
//
//   appearance-watch 'theme apply'
//
// Compiled by install.sh into ~/.dotfiles/bin/appearance-watch.

import Foundation

let command = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ""
guard !command.isEmpty else {
    FileHandle.standardError.write("usage: appearance-watch <shell command>\n".data(using: .utf8)!)
    exit(2)
}

func run(_ command: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-lc", command]
    try? process.run()
}

DistributedNotificationCenter.default.addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
    object: nil,
    queue: .main
) { _ in
    // The notification lands a beat before `defaults read` reports the new
    // value, so give cfprefsd a moment before anything reads the appearance.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { run(command) }
}

run(command)          // get in sync at launch
RunLoop.main.run()
