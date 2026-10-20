ADR-001: No Developer Cloud

Status: Accepted

Reason:
User privacy and low operational costs.

Consequences:
- User-managed storage only
- No vendor-hosted backups

ADR-002: Rust for Business Logic

Status: Accepted

Reason:
Shared compute layer across platforms.

Consequences:
- Flutter handles UI
- Rust handles parsing and analytics

ADR-003: Scan and Budget Independence

Status: Accepted

Reason:
Applications must remain useful individually.

Consequences:
- JSON contract required
- No service dependency

