# Dependency injection (get_it) and state management (Riverpod)

These two solve different problems. Mixing them up is the most common source of
confusion, so this project gives each a clear job.

## The split used in this project

| | get_it | Riverpod |
| --- | --- | --- |
| Question it answers | "How do I build and find a service?" | "What should the screen show right now, and when does it change?" |
| Holds | database, repositories, use cases, bootstrapper | UI state (startup progress, later: form state, filtered lists, selected month) |
| Lifetime | the whole app, created lazily | tied to widgets/scopes; can be disposed and rebuilt |
| Used by | `service_locator.dart` only (composition root) | widgets and controllers |
| Knows about Flutter? | no | yes (`flutter_riverpod`) |

The bridge is one provider: `serviceLocatorProvider`. Riverpod providers read
services through it (`ref.watch(serviceLocatorProvider).get<Bootstrapper>()`).
Business classes (use cases, repositories) receive their dependencies through
constructors and never call get_it themselves; only the composition root does.
That keeps them trivially testable.

## get_it in 60 seconds

```dart
locator.registerLazySingleton<AppStatusRepository>(() => AppStatusRepositoryImpl(locator()));
locator.registerFactory<RecordAppLaunch>(() => RecordAppLaunch(locator(), DateTime.now));
final repo = locator<AppStatusRepository>();
```

- `registerSingleton`: created immediately, one instance.
- `registerLazySingleton`: created on first use, one instance (our default).
- `registerFactory`: new instance every time (stateless use cases).
- `dispose:` callback runs on `locator.reset()` (closes the DB).
- In tests use `GetIt.asNewInstance()` so tests do not share state.

Pitfall: calling `GetIt.instance` deep inside business code hides dependencies
(a "service locator anti-pattern"). We avoid that by passing the locator only
to `configureDependencies`.

## Riverpod in 60 seconds

```dart
final bootstrapControllerProvider =
    NotifierProvider<BootstrapController, BootstrapState>(BootstrapController.new);

// in a widget:
final state = ref.watch(bootstrapControllerProvider);      // rebuild on change
ref.read(bootstrapControllerProvider.notifier).start();    // call a method (in callbacks)
```

- `Provider`: read-only value (config, formatter).
- `Notifier` / `AsyncNotifier`: state plus methods (our `BootstrapController`).
- `FutureProvider` / `StreamProvider`: async data; later dashboards will use
  drift streams here so screens update when data changes.
- `ref.watch` in `build`, `ref.read` in event handlers.
- Tests: `ProviderScope(overrides: [...])` swaps any provider for a fake.

## Why these two for this project

- Many services with swappable implementations (rule engine vs. local LLM
  parsers in Phase 7, several AI models): get_it registrations make swapping a
  one-line change in one file.
- Lots of reactive UI (dashboards, filtered histories, budget status): Riverpod
  handles caching, rebuilds and async states without boilerplate, and works
  without `BuildContext` for non-widget logic.

## Choosing per project

| Situation | Reasonable choice |
| --- | --- |
| Small app, few services, mostly UI state | Riverpod alone (providers *are* the DI) |
| Team already uses events/states and wants strict, traceable transitions | `bloc` / `flutter_bloc` (plus get_it or `RepositoryProvider` for DI) |
| Tiny app or prototype | `provider` or plain `ChangeNotifier` + `ListenableBuilder` |
| Many injectable classes, want compile-time wiring | get_it + `injectable` (code generation) |
| Reactive-value style, minimal ceremony | `signals`, or the `flutter_it` family (get_it + watch_it) |

Questions to ask:

1. How much UI state is asynchronous or derived from other state? (more -> Riverpod/bloc)
2. Will the logic be shared with non-Flutter Dart code (CLI, server)? (keep domain pure; get_it/pure Dart DI fits)
3. How many people work on it and how much structure do they need? (bloc is explicit; Riverpod is flexible)
4. How much do you value fewer concepts over strict layering? (Riverpod alone)

Both libraries are mainstream and actively maintained; switching state
management later is a presentation-layer change precisely because domain and
data layers do not depend on either.

## Versions in this project

Verified on pub.dev in October 2026: `flutter_riverpod 3.4.x`, `get_it 9.2.x`,
`drift 2.35.x`. Riverpod 3 changed some APIs compared with older tutorials
(for example, `StateNotifierProvider` moved to a legacy import). If a tutorial
does not compile, check which Riverpod major version it targets.

Docs: riverpod.dev, pub.dev/packages/get_it, drift.simonbinder.eu.
