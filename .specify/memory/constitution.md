<!--
SYNC IMPACT REPORT
==================
Version change: N/A → 1.0.0 (initial)
Modified principles: N/A (initial constitution)
Added sections:
  - Core Principles (5): Test-First Development, Native iOS Excellence,
    User Experience Quality, Code Architecture, Simplicity & Pragmatism
  - Development Standards
  - Quality Gates
  - Governance
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (no updates needed - Constitution Check section is generic)
  - .specify/templates/spec-template.md ✅ (no updates needed - template is principle-agnostic)
  - .specify/templates/tasks-template.md ✅ (no updates needed - supports TDD workflow)
Follow-up TODOs: None
-->

# Luno Constitution

## Core Principles

### I. Test-First Development (NON-NEGOTIABLE)

Test-Driven Development is mandatory for all feature implementation in Luno.

- Tests MUST be written before implementation code
- Tests MUST fail before implementation begins (Red phase)
- Implementation MUST be minimal to pass tests (Green phase)
- Refactoring MUST maintain passing tests (Refactor phase)
- No pull request shall be merged without corresponding test coverage
- Unit tests for business logic, UI tests for critical user flows, snapshot tests for UI components

**Rationale**: TDD ensures code correctness, serves as living documentation, and enables confident refactoring. For a productivity app where reliability is paramount, this discipline prevents regressions and maintains user trust.

### II. Native iOS Excellence

Luno embraces platform conventions and leverages native iOS capabilities fully.

- SwiftUI MUST be the primary UI framework; UIKit only when SwiftUI lacks capability
- Follow Apple Human Interface Guidelines for all UI/UX decisions
- Use native iOS patterns: Combine for reactive programming, async/await for concurrency
- Adopt Swift best practices: value types over reference types where appropriate, protocol-oriented design
- Support the latest two major iOS versions minimum
- Respect system settings: Dynamic Type, Dark Mode, Reduce Motion, VoiceOver

**Rationale**: Native development provides the best user experience, performance, and access to platform features. Embracing iOS conventions reduces cognitive load for users and leverages Apple's ongoing platform investments.

### III. User Experience Quality

Every feature MUST prioritize accessibility, performance, and polish.

- Accessibility MUST NOT be an afterthought: VoiceOver support, sufficient contrast, touch target sizes (44x44pt minimum)
- App launch time MUST remain under 400ms (cold start to interactive)
- UI interactions MUST respond within 100ms; no frame drops during animations (maintain 60fps)
- Offline capability MUST be considered for core productivity features
- Error states MUST be user-friendly with clear recovery paths
- Loading states MUST provide feedback; no blank screens during data fetches

**Rationale**: A productivity app must be fast, reliable, and usable by everyone. Performance and accessibility are features, not polish items to add later.

### IV. Code Architecture

Maintain clean separation of concerns and testable architecture.

- Follow MVVM pattern: Views observe ViewModels; ViewModels contain presentation logic; Models represent domain
- Business logic MUST reside in services/use cases, not in ViewModels or Views
- Dependencies MUST be injected, never instantiated directly in consumers
- Data layer MUST abstract persistence (CoreData, SwiftData, or UserDefaults) behind repository protocols
- Network layer MUST be abstracted behind service protocols for testability
- No business logic in SwiftUI Views; Views are declarative UI descriptions only

**Rationale**: Clean architecture enables testing, allows implementation swapping, and keeps the codebase maintainable as it grows. Dependency injection is essential for TDD.

### V. Simplicity & Pragmatism

Start simple. Add complexity only when proven necessary.

- YAGNI (You Aren't Gonna Need It): Do not build features or abstractions for hypothetical future needs
- Prefer composition over inheritance
- Avoid premature optimization; profile before optimizing
- Third-party dependencies MUST be justified: prefer Apple frameworks, evaluate maintenance burden
- Code comments explain "why", not "what"; self-documenting code is preferred
- Delete dead code immediately; version control preserves history

**Rationale**: Complexity is the enemy of reliability and velocity. A productivity app must ship features quickly and maintain them indefinitely. Simplicity enables both.

## Development Standards

### Code Style & Conventions

- Swift code MUST pass SwiftLint with project configuration
- SwiftFormat MUST be applied before commits
- Naming follows Swift API Design Guidelines
- File organization: one type per file, grouped by feature module
- Maximum function length: 40 lines (excluding setup/configuration)
- Maximum file length: 400 lines (signals need for decomposition)

### Version Control

- Commits MUST be atomic and describe intent ("Add task completion animation" not "Update TaskView")
- Branch naming: `feature/###-description`, `fix/###-description`, `chore/description`
- Pull requests require passing CI and at least one approval
- Main branch MUST always be in a deployable state

### Documentation

- Public APIs MUST have documentation comments
- Complex algorithms MUST have explanatory comments
- Architecture decisions MUST be recorded in ADRs (Architecture Decision Records) when significant

## Quality Gates

All code changes MUST pass these gates before merging:

1. **Compilation**: Zero warnings in Release configuration
2. **Tests**: 100% of tests pass; no skipped tests without documented reason
3. **Coverage**: Minimum 70% line coverage for new code; 80% for business logic services
4. **Linting**: Zero SwiftLint errors; warnings addressed or explicitly disabled with justification
5. **Accessibility Audit**: New screens pass Accessibility Inspector checks
6. **Performance**: No regression in app launch time or memory footprint

## Governance

This constitution supersedes all other development practices for the Luno project.

### Amendment Process

1. Propose amendment via pull request to this document
2. Document rationale for change and impact assessment
3. Obtain team consensus (or designated maintainer approval for solo projects)
4. Update version number according to semantic versioning
5. Propagate changes to affected templates and documentation

### Versioning Policy

- **MAJOR**: Removing or fundamentally redefining a principle (breaking change to workflow)
- **MINOR**: Adding new principle, section, or materially expanding guidance
- **PATCH**: Clarifications, wording improvements, typo fixes

### Compliance

- All pull requests MUST be reviewed against constitution principles
- Technical debt or deviations MUST be documented with remediation plan
- Quarterly review of constitution relevance and adherence

**Version**: 1.0.0 | **Ratified**: 2026-02-04 | **Last Amended**: 2026-02-04
