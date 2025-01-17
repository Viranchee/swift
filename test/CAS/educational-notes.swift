// RUN: %empty-directory(%t)

// RUN: %target-swift-frontend -scan-dependencies -module-name Test -O \
// RUN:   -disable-implicit-string-processing-module-import -disable-implicit-concurrency-module-import -parse-stdlib \
// RUN:   %s -o %t/deps.json -swift-version 5 -cache-compile-job -cas-path %t/cas

// RUN: %{python} %S/Inputs/BuildCommandExtractor.py %t/deps.json Test > %t/MyApp.cmd
// RUN: echo "\"-disable-implicit-string-processing-module-import\"" >> %t/MyApp.cmd
// RUN: echo "\"-disable-implicit-concurrency-module-import\"" >> %t/MyApp.cmd
// RUN: echo "\"-parse-stdlib\"" >> %t/MyApp.cmd

// RUN: not %target-swift-frontend -color-diagnostics -diagnostic-style=llvm -print-educational-notes -diagnostic-documentation-path %S/../diagnostics/test-docs/ \
// RUN:   -emit-module -emit-module-path %t/test.module @%t/MyApp.cmd %s 2>&1 | %FileCheck %s --match-full-lines --strict-whitespace
// RUN: not %target-swift-frontend -no-color-diagnostics -print-educational-notes -diagnostic-documentation-path %S/../diagnostics/test-docs/ \
// RUN:   -emit-module -emit-module-path %t/test.module @%t/MyApp.cmd %s 2>&1 | %FileCheck %s --match-full-lines --strict-whitespace --check-prefix=NO-COLOR

// A diagnostic with no educational notes
let x = 1 +
// CHECK:{{.*}}[0m[0;1;31merror: [0m[1mexpected expression after operator
// CHECK-NOT: {{-+$}}

// NO-COLOR:{{.*}}error: expected expression after operator
// NO-COLOR-NOT: {{-+$}}

// A diagnostic with an educational note using supported markdown features
typealias Crap = () -> ()
extension Crap {}
// CHECK:{{.*}}[0m[0;1;31merror: [0m[1mnon-nominal type 'Crap' (aka '() -> ()') cannot be extended
// CHECK-NEXT:[0mextension Crap {}
// CHECK-NEXT:[0;1;32m^         ~~~~
// CHECK-NEXT:[0m[0m[1mNominal Types[0m
// CHECK-NEXT:--------------
// CHECK-EMPTY:
// CHECK-NEXT:Nominal types documentation content. This is a paragraph
// CHECK-EMPTY:
// CHECK-NEXT:  blockquote
// CHECK-NEXT:  {{$}}
// CHECK-NEXT:  - item 1
// CHECK-NEXT:  - item 2
// CHECK-NEXT:  - item 3
// CHECK-NEXT:  {{$}}
// CHECK-NEXT:  let x = 42
// CHECK-NEXT:  if x > 0 {
// CHECK-NEXT:    print("positive")
// CHECK-NEXT:  }
// CHECK-NEXT:  {{$}}
// CHECK-NEXT:Type 'MyClass'
// CHECK-EMPTY:
// CHECK-NEXT:[Swift](swift.org)
// CHECK-EMPTY:
// CHECK-NEXT:[0m[1mbold[0m italics
// CHECK-NEXT:--------------
// CHECK-NEXT:[0m[1mHeader 1[0m
// CHECK-NEXT:[0m[1mHeader 3[0m

// NO-COLOR:{{.*}}error: non-nominal type 'Crap' (aka '() -> ()') cannot be extended
// NO-COLOR-NEXT:extension Crap {}
// NO-COLOR-NEXT:^         ~~~~
// NO-COLOR-NEXT:Nominal Types
// NO-COLOR-NEXT:--------------
// NO-COLOR-EMPTY:
// NO-COLOR-NEXT:Nominal types documentation content. This is a paragraph
// NO-COLOR-EMPTY:
// NO-COLOR-NEXT:  blockquote
// NO-COLOR-NEXT:  {{$}}
// NO-COLOR-NEXT:  - item 1
// NO-COLOR-NEXT:  - item 2
// NO-COLOR-NEXT:  - item 3
// NO-COLOR-NEXT:  {{$}}
// NO-COLOR-NEXT:  let x = 42
// NO-COLOR-NEXT:  if x > 0 {
// NO-COLOR-NEXT:    print("positive")
// NO-COLOR-NEXT:  }
// NO-COLOR-NEXT:  {{$}}
// NO-COLOR-NEXT:Type 'MyClass'
// NO-COLOR-EMPTY:
// NO-COLOR-NEXT:[Swift](swift.org)
// NO-COLOR-EMPTY:
// NO-COLOR-NEXT:bold italics
// NO-COLOR-NEXT:--------------
// NO-COLOR-NEXT:Header 1
// NO-COLOR-NEXT:Header 3

// CHECK-DESCRIPTIVE: educational-notes.swift
// CHECK-DESCRIPTIVE-NEXT:  | // A diagnostic with an educational note
// CHECK-DESCRIPTIVE-NEXT:  | extension Crap {}
// CHECK-DESCRIPTIVE-NEXT:  | ^ error: expected expression after operator
// CHECK-DESCRIPTIVE-NEXT:  |

// CHECK-DESCRIPTIVE: educational-notes.swift
// CHECK-DESCRIPTIVE-NEXT:  | // A diagnostic with an educational note
// CHECK-DESCRIPTIVE-NEXT:  | extension Crap {}
// CHECK-DESCRIPTIVE-NEXT:  |           ~~~~
// CHECK-DESCRIPTIVE-NEXT:  | ^ error: non-nominal type 'Crap' (aka '() -> ()') cannot be extended
// CHECK-DESCRIPTIVE-NEXT:  |
// CHECK-DESCRIPTIVE-NEXT: Nominal Types
// CHECK-DESCRIPTIVE-NEXT: -------------
