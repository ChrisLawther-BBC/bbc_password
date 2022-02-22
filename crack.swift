#!/usr/bin/env swift

import Foundation

func lines(from filename: String) -> [String] {
    let url = URL(fileURLWithPath: filename)
    return try! String(contentsOf: url, encoding: .utf8)
        .components(separatedBy: .newlines)
}

let leakedPasswords = lines(from: "leaked_passwords_v1.txt")
print("Checking \(leakedPasswords.count) leaked passwords")

let userPasswords = leakedPasswords
    .filter { !$0.isEmpty }
    .reduce(into: [String: String]()) { dict, row in
    let components = row.components(separatedBy: ",")
    dict[components[1]] = components[0]
}

let leaked = Set(userPasswords.keys)

let commonPasswords = lines(from: "toppassword.txt")
print("Trying \(commonPasswords.count) common passwords")
print(leaked.count)

func scramble(_ password: String) -> String {

    let aValue = "A".unicodeScalars.first!.value

    var capsHashedValues = [3] + password
        .uppercased()
        .unicodeScalars
        .filter { CharacterSet.uppercaseLetters.contains($0) }  // Only caps
        .map { $0.value - aValue }                              // A=0, B=1 etc.

    for idx in capsHashedValues.indices[1...] {
        capsHashedValues[idx] = (capsHashedValues[idx-1] + capsHashedValues[idx]) % 26
    }

    let scalars = capsHashedValues
        .dropFirst()
        .compactMap { UnicodeScalar($0 + aValue) }

    return String(String.UnicodeScalarView(scalars))
}

let matches = commonPasswords.compactMap { password -> (String, String, String)? in
    let scrambled = scramble(password)
    guard leaked.contains(scrambled) else { return nil }
    return (userPasswords[scrambled]!, password, scrambled)
}

for (user, password, scrambled) in matches {
    print("\(user)'s password is \(password) (scrambles to \(scrambled))")
}

let found = matches.count
let leakedCount = leaked.count
let percentage = 100 * found / leakedCount

print("Done! (Found \(found) of \(leakedCount) = \(percentage)%)")
