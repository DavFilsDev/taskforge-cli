# taskforge_cli

A CLI task manager written in pure Dart, built as a portfolio piece to
demonstrate clean architecture, SOLID design, and idiomatic Dart 3
before moving into Flutter.

> **A note on how this was verified:** the code and tests below were
> written and reviewed carefully, but they have **not been run**
> through `dart analyze` / `dart test` by the author of this repo's
> generation, because no Dart SDK was available in that environment.
> Before you trust this as a portfolio piece, run the "Testing" and
> "Quality checks" commands below yourself and fix anything the
> analyzer flags. Treat this README's checklist as a to-do list, not
> a completed report.

## Architecture

Four layers, each depending only inward (Presentation → Domain ←
Data), wired together at the edges by dependency injection:

```
┌──────────────────────────────────────────────────────────┐
│                     presentation/                        │
│   commands/  (Command pattern: add, list, done, delete)  │
│   formatters/ (turns Task → terminal text)               │
│   validators/ (CLI argument parsing)                     │
└───────────────────────┬──────────────────────────────────┘
                         │ depends on
                         ▼
┌────────────────────────────────────────────────────────────┐
│                        domain/                             │
│   entities/    Task (abstract) → StandardTask, UrgentTask  │
│   interfaces/  Repository<T>, TaskRepository               │
│   strategies/  SortStrategy (priority vs date)             │
│   use_cases/   Add / List / Complete / Delete, TaskFactory │
└───────────────────────▲────────────────────────────────────┘
                         │ implements
                         │
┌──────────────────────────────────────────────────────────────────┐
│                        data/                                     │
│   models/        TaskModel (Task <-> JSON map)                   │
│   sources/       JsonFileDataSource (raw file I/O)               │
│   repositories/  JsonTaskRepository (implements TaskRepository)  │
└──────────────────────────────────────────────────────────────────┘

              core/  — exceptions, constants, validators, DI
                      (shared by every layer above)
```

The domain layer defines interfaces (`TaskRepository`, `SortStrategy`)
that it doesn't implement itself; `data/` provides the concrete
implementation and `core/di/service_locator.dart` wires the concrete
class into the abstraction at startup. Nothing in `domain/` or
`presentation/` ever imports a class from `data/` directly — they only
know about domain-owned interfaces. That's what makes the use cases
and commands testable with fakes instead of a real file on disk.

### Design patterns used, and why

| Pattern | Where | Why |
|---|---|---|
| **Repository** | `TaskRepository` / `JsonTaskRepository` | Hides "how tasks are stored" behind a domain-shaped interface. Swapping JSON for SQLite later means writing one new class, not touching use cases. |
| **Factory** | `TaskFactory` | Centralizes the "does this deadline make the task urgent?" decision so no call site duplicates that logic. |
| **Strategy** | `SortStrategy`, `PrioritySortStrategy`, `DateSortStrategy` | `ListTasksUseCase` sorts without knowing *how* — new orderings slot in without changing the use case. |
| **Command** | `Command`, `AddCommand`, etc. | `main.dart` dispatches on `command.name` instead of a growing `switch` full of business logic. |
| **Singleton** | `ServiceLocator` | One shared dependency graph per process; `ServiceLocator.reset()` exists purely so tests can rebuild it against a temp directory. |
| **Dependency Injection** | Constructors everywhere | Every use case takes a `TaskRepository`, every command takes its use case — concrete wiring only happens once, in `ServiceLocator`. |

### Dart-specific choices worth calling out

- `Task` is an `abstract base class`; `StandardTask` and `UrgentTask`
  are `final` — this uses Dart 3's class modifiers to make the
  inheritance boundary explicit: nothing outside this file can extend
  `Task` in a way that breaks these two known shapes.
- `Repository<T>` is a generic `interface class`; `TaskRepository`
  specializes it for `Task` and adds `findByTitle`, following
  interface segregation.
- `Priority` is an `enum` with a `PriorityX` extension carrying
  `weight`, `label`, and a `parse` factory — behavior attached without
  bloating the enum body, and using `switch` expressions (Dart 3)
  instead of a chain of `if`/`else`.
- Custom exceptions form a `sealed` hierarchy (`AppException`), so
  exhaustive `switch` handling is possible anywhere that's useful.

## Setup

Requires the Dart SDK (`>=3.3.0`). Install dependencies:

```bash
dart pub get
```

## Running the app

```bash
dart run bin/taskforge_cli.dart --help

dart run bin/taskforge_cli.dart add --title "Write README" --priority high
dart run bin/taskforge_cli.dart add --title "Ship it" --priority medium --deadline 2026-08-01
dart run bin/taskforge_cli.dart list --sort priority
dart run bin/taskforge_cli.dart list --sort date --pending-only
dart run bin/taskforge_cli.dart done --id <task-id>
dart run bin/taskforge_cli.dart delete --id <task-id>
```

Tasks persist to `tasks.json` in the current working directory.

Exit codes: `0` success · `64` usage error (bad/missing argument) ·
`65` data error (not found, duplicate, corrupt store) · `74` I/O error
(filesystem problem) · `1` unexpected error.

## Testing

```bash
dart test
```

Tests are organized by layer under `test/`:

- `test/domain/` — entity validation, `UrgentTask` urgency logic,
  `SortStrategy` implementations, `TaskFactory`'s promotion rule.
- `test/use_cases/` — each use case against `test/fakes/FakeTaskRepository`,
  an in-memory fake (no mocking package needed for an interface this
  small).
- `test/data/` — `JsonFileDataSource` and `JsonTaskRepository` against
  **real temporary directories** (`Directory.systemTemp.createTemp`,
  cleaned up in `tearDown`), including corrupted-JSON and
  wrong-JSON-shape cases.
- `test/presentation/` — the hand-rolled CLI argument parser.

## Quality checks

```bash
dart format .
dart analyze
dart test
```

`analysis_options.yaml` extends `package:lints/recommended.yaml` with
stricter analyzer settings (`strict-casts`, `strict-inference`,
`strict-raw-types`) and a few extra lint rules. Run these yourself —
see the note at the top of this README about why they haven't been
run already.


## Continuous integration

`.github/workflows/dart.yml` runs on every push and pull request to
`main`: `dart pub get`, `dart format --set-exit-if-changed`,
`dart analyze --fatal-infos`, then `dart test`. A PR that fails
formatting, has any analyzer issue (including infos), or breaks a
test cannot merge — the same three commands you'd run locally are
what CI enforces.

## Troubleshooting

- **`dart: command not found`** — the Dart SDK isn't on your `PATH`.
  See the Setup section, or run `which dart` to confirm where it's
  installed.
- **Tasks seem to "disappear" between runs** — `tasks.json` is written
  relative to your *current working directory*, not the project root.
  Run `pwd` before `dart run bin/taskforge_cli.dart ...` to confirm
  where you are; the file will show up there, not necessarily where
  you expect.
- **A test fails only when run alongside others, not alone** — check
  whether it depends on `ServiceLocator`'s singleton state. Tests that
  touch `ServiceLocator` must call `ServiceLocator.reset()` in `setUp`
  (see `test/app_test.dart`) so each test starts from a clean
  dependency graph pointed at its own temp directory.
- **`dart analyze` flags something this README doesn't mention** — run
  it locally before pushing; CI (see above) will block the merge
  either way.

## Design decisions and trade-offs

- **No argument-parsing package.** A hand-rolled `CliInputValidator`
  was used instead of `package:args`, to keep the "core Dart" story
  honest for a portfolio piece. In a real production CLI, `args` would
  be the better call — this is a deliberate trade-off for this
  project's purpose.
- **A type discriminator in the JSON, not date-based re-inference.**
  When loading from disk, a task's `type` field is trusted over
  re-running `TaskFactory`'s urgency check against "now" — otherwise
  an old, already-handled `StandardTask` could silently become an
  `UrgentTask` weeks later just because its stale deadline field
  happens to fall inside the urgent window again.
- **Fakes over mocks.** `TaskRepository` is small enough that a
  hand-written in-memory fake is simpler to read (and just as
  effective at isolating use cases from real I/O) than pulling in
  `mockito` or `mocktail`.

## What this project is meant to demonstrate

- Clean layering where dependencies point inward and interfaces (not
  concrete classes) are what upper layers depend on.
- Deliberate use of Dart 3 features (class modifiers, `switch`
  expressions, super-parameters) rather than defaulting to older
  Dart 1/2 idioms.
- A test suite that actually exercises real filesystem behavior for
  the persistence layer, not just in-memory happy paths.

## Author

Developed and maintained by **Fanampinirina Miharisoa David Fisl RATIANDRAIBE**.

Feel free to reach out or contribute through:

- GitHub: [F Miharisoa David Fils RATIANDRAIBE](https://github.com/DavFilsDev)
- LinkedIn: [Fanampinirina Miharisoa David Fils RATIANDRAIBE](https://www.linkedin.com/in/fanampinirina-miharisoa-david-fils-ratiandraibe-722376330/)