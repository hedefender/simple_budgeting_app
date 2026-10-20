# Brainstorming Report
## Scan & Budget Ecosystem

Version: 1.0
Status: Concept Validation / Architecture Brainstorming
Last Updated: 2026-10-19

---

# Vision

Create a privacy-first ecosystem of independent applications focused on document digitization and personal financial management.

The ecosystem follows the principle:

> User owns the data.
> Developer never owns the data.

No developer-controlled cloud infrastructure should be required for normal operation.

Applications must remain fully functional even when used independently.

---

# Ecosystem Components

## Application 1: Scan

Purpose:

Document capture, OCR processing, PDF generation and automated delivery.

The application acts as an acquisition layer for information.

Responsibilities:

- Camera capture
- Document enhancement
- OCR
- PDF generation
- Email delivery
- JSON export

Non Responsibilities:

- Financial analysis
- Expense categorization
- Spending reports
- Budget planning
- Cloud storage

---

## Application 2: Budget

Purpose:

Personal financial organization and analytics.

The application acts as an information interpretation layer.

Responsibilities:

- Expense tracking
- Income tracking
- OCR import
- JSON import
- Categorization
- Statistics
- Reporting
- Forecasting

Non Responsibilities:

- Banking operations
- Trading
- Tax declaration submission
- Cloud storage ownership

---

# Core Philosophy

## Privacy First

User documents must never pass through developer-owned infrastructure.

All operations should be performed:

- Locally
- On-device
- Under user control

---

## Offline First

Applications should remain useful without internet access.

Internet access may be used only for:

- Email delivery
- User-controlled cloud providers
- Optional future updates

---

## User-Owned Data

The ecosystem should never require:

- Mandatory accounts
- Developer cloud
- Subscription infrastructure
- Remote storage controlled by the vendor

User keeps ownership of:

- Documents
- OCR output
- Expense history
- Budget database

At all times.

---

# Scan Application

## Mission

Transform physical documents into digital assets with the minimum possible user interaction.

The desired workflow is:

SCAN & SEND

↓

Capture

↓

OCR

↓

PDF

↓

JSON

↓

Email

---

## Supported Content

The application is not limited to receipts.

Examples:

- Utility bills
- Telecom bills
- Water bills
- Invoices
- Contracts
- Letters
- Announcements
- Personal notes
- Book pages
- Comic pages
- Printed forms
- Generic documents

---

## First Launch Configuration

User selects:

- Gmail
- Outlook
- Yahoo

User configures:

- Destination email

Options:

- Send to myself
- Send to custom address

---

## Scanning Modes

### Single Page

Capture one document.

Generate one PDF.

### Multi Page

Capture multiple pages.

Generate one combined PDF.

Potential monetization candidate.

---

## Email Delivery

Email Subject:

YYYY-MM-DD_HH-MM-SS

Example:

2026-10-19_14-23-11

Email Body:

Raw OCR transcript.

Attachment:

Generated PDF.

---

## OCR

Requirements:

- Local processing
- Greek support
- English support
- Fast execution
- Offline capable

Technology Candidate:

Google ML Kit

---

## JSON Generation

Generate raw OCR JSON output.

Purpose:

Machine-readable information exchange.

Example:

```json
{
  "schemaVersion": 1,
  "documentId": "",
  "createdAt": "",
  "ocrText": "",
  "pdfPath": "",
  "imagePaths": []
}
```

---

# Budget Application

## Mission

Transform documents and OCR output into structured financial information.

The application must remain fully functional without the Scan application.

---

## Supported Input Methods

### Manual Entry

User manually enters:

- Amount
- Vendor
- Category

---

### OCR Import

User imports:

- Image
- PDF

Application performs OCR.

---

### Scan Integration

User imports Scan-generated JSON.

---

### Future CSV Import

Potential support.

---

# Rust Strategy

Budget shall use a hybrid architecture.

## Flutter

Responsibilities:

- UI
- Navigation
- Forms
- Charts
- Settings
- Platform integration

---

## Rust

Responsibilities:

- Rule Engine
- Categorization Engine
- Data Processing
- Statistics
- Forecasting
- AI Integration
- Data Normalization

Communication:

flutter_rust_bridge

---

# AI / LLM Philosophy

LLM should not act as a chatbot.

LLM is a specialized document analysis module.

Purpose:

Convert OCR text into structured financial information.

---

## Rule Engine First

The system should attempt:

1. Pattern matching
2. Rules
3. Regex extraction

before invoking AI.

---

## LLM Fallback

Only execute when confidence score is low.

Pipeline:

Input

↓

Rule Engine

↓

Confidence Score

↓

LLM

↓

Normalized Expense Record

---

## Example OCR

Input:

ΔΕΗ
Πληρωτέο ποσό 83.50€

Output:

```json
{
  "vendor": "ΔΕΗ",
  "category": "Utilities",
  "amount": 83.50,
  "currency": "EUR"
}
```

---

# Shared Data Philosophy

Applications must remain independent.

No direct execution dependency.

No service dependency.

No mandatory installation dependency.

Instead:

Shared Data Exchange

↓

JSON Files

↓

Common Schema

---

## Shared Storage

Preferred mechanism:

Shared user-controlled storage.

Examples:

- Device storage
- User cloud storage
- Shared folder

Applications exchange data through files.

Not through background services.

---

# Household Use Cases

## Personal Budget

Single user.

---

## Household Budget

Separate dataset.

Possible approaches:

- Separate profile
- Separate installation
- Dual App / App Clone

depending on platform capabilities.

---

# Professional Use Cases

Supported:

- Individuals
- Couples
- Families
- Freelancers

Not primary target:

- Accounting firms
- ERP systems
- Full business accounting

---

# Tax Support Philosophy

The application should assist tax preparation.

It should NOT perform tax filing.

Example:

Financial Summary

↓

Report Generation

↓

Accountant Review

↓

Tax Submission by Professional

---

# Cloud Philosophy

Developer-owned cloud:

Rejected.

Reasons:

- Cost
- Privacy concerns
- Data ownership concerns
- Legal complexity

---

## User-Owned Cloud

Acceptable.

Examples:

- Google Drive
- OneDrive
- Dropbox

Credentials remain user-controlled.

---

# Future Expansion

Potential future applications:

- Investment Viewer
- Portfolio Import Tool
- Household Budget Companion

Must reuse common schemas and Rust core components.

---

# Product Positioning

Scan:

"Privacy-first document scanner with OCR, PDF generation and email delivery."

Budget:

"Privacy-first local budgeting and financial organization platform."

---

# Guiding Principle

The ecosystem succeeds if:

Users gain better visibility into their finances
without surrendering ownership of their data.

Everything else is secondary.


# Architecture and Product Evolution Notes

These notes were produced during architecture review and long-term product planning.

They do not represent immediate implementation tasks.

They serve as guidance for future architectural decisions.

---

# LLM Separation Principle

Different AI systems should be used for different responsibilities.

Implementation assistants (Claude Code, Antigravity, IDE agents) are responsible for:

- code generation
- implementation details
- migrations
- testing
- refactoring

Architecture assistants are responsible for:

- product direction
- long-term design review
- scope control
- boundary validation
- ecosystem consistency

Reason:

Implementation-focused agents may naturally prefer preserving existing code and decisions.

Architecture reviews should periodically challenge assumptions and re-evaluate long-term goals.

---

# Brainstorming as a First-Class Artifact

The project should permanently maintain a dedicated brainstorming document.

This document exists independently from:

- roadmap
- implementation plans
- source code
- technical documentation

Purpose:

Capture product philosophy and design intent.

Questions it should answer:

Why does the product exist?

What problem does it solve?

What should the product never become?

---

# Product Transformation

Original concept:

Budget App

Current direction:

Document Driven Personal Finance Platform

The system is gradually evolving into:

Documents
↓
OCR
↓
Structured Data
↓
Financial Knowledge
↓
Reports
↓
Insights

This evolution should be acknowledged explicitly in future planning.

---

# Scan and Budget Relationship

The applications are not dependencies.

The applications are companions.

Incorrect model:

Scan
↓
Budget

Correct model:

Scan

Budget

Shared Exchange Format

The exchange format is the integration point.

Not direct application coupling.

---

# Shared Exchange Philosophy

JSON exchange is a product boundary.

The schema should be treated as a contract.

Breaking schema compatibility should be considered a major version change.

Goals:

- long-term stability
- backward compatibility
- future application interoperability

Future applications may consume the same schema.

---

# Budget Independence Principle

Budget must remain usable without Scan.

Supported input sources:

- Manual entry
- OCR import
- PDF import
- Image import
- JSON import
- Future CSV import

Scan is an accelerator.

Not a requirement.

---

# Scan Independence Principle

Scan must remain useful without Budget.

Primary value:

- OCR
- PDF generation
- Email delivery
- Document archive creation

Budget integration is additional functionality.

Not the primary purpose.

---

# Document Type Awareness

Future planning should include a document classification layer.

Suggested enum:

- Unknown
- Receipt
- UtilityBill
- Invoice
- Statement
- Contract
- GenericDocument

Reason:

Different document types require different parsing strategies.

This is expected to become valuable before advanced rule engines and local AI processing.

---

# Data Ownership Manifesto

User owns:

- Documents
- OCR output
- Financial data
- Reports
- Backups

Developer owns:

- Application code

Only.

Developer should never require ownership of user-generated financial content.

---

# Product Boundaries

In Scope

- Personal budgeting
- Household budgeting
- Freelance finance tracking
- OCR-based expense capture
- Financial reporting
- Spending analytics

Out of Scope

- Full ERP
- Business accounting software
- Banking platform
- Crypto trading platform
- Tax filing platform
- Developer-controlled cloud storage

---

# Cloud Philosophy

Developer-owned cloud infrastructure remains rejected.

Reasons:

- Increased operational costs
- Privacy concerns
- Data ownership concerns
- Legal obligations
- Vendor lock-in

Accepted alternatives:

- Local storage
- OneDrive
- Google Drive
- Dropbox
- User-controlled storage providers

---

# Team Sharing Philosophy

Future collaboration should not require developer-controlled servers.

Preferred solutions:

- Shared cloud folders
- Shared exports
- Encrypted exchange packages
- User-controlled synchronization

The default assumption remains:

Users control the storage.

---

# Budget as Knowledge System

The long-term goal is not merely expense tracking.

The system should gradually evolve towards:

Financial Knowledge Management

Examples:

- Spending analysis
- Cost trend identification
- Obligation tracking
- Recurring payment awareness
- Financial summaries

Without becoming a banking application.

---

# AI Philosophy

AI is a processing component.

AI is not a product feature.

Primary purpose:

- categorization
- normalization
- document interpretation

The system should never depend on conversational AI to perform its core functions.

The application must remain useful even if AI is disabled entirely.

---

# Guiding Principle

The ecosystem succeeds when:

Users gain visibility into their finances

without surrendering ownership of their data.

Everything else is secondary.

# Analytics Engine First

Charts must never calculate business data.

Charts are presentation components only.

All financial calculations must be performed inside the Analytics Engine.

The Analytics Engine produces normalized summary datasets.

Flutter visualizes those datasets.

This ensures:

- platform independence
- consistent reporting
- reusable business logic
- desktop/mobile parity

Examples:

- Monthly Expense Summary
- Income vs Expense Summary
- Category Breakdown
- Vendor Breakdown
- Recurring Obligation Summary

# Scan: document type and soft filter

Design idea only, nothing is implemented. It belongs to Phase 8 (Scan). Added 2026-10-21 at the owner's request.

- Scan gets a type choice: Receipt or Document. In Document mode it keeps only the PDF and does not create a JSON file.
- Optional field `documentType` in the Scan JSON schema, with values such as `receipt`, `utilityBill`, `invoice`,
  `genericDocument`. It is an addition that breaks nothing (unknown fields are ignored) and the schema stays at v1.
  When the field is absent the type is `unknown`.
- The soft filter for receipts is a WARNING, not a block. The user can choose "save anyway".
- The check stays minimal: an amount and a date, or a keyword. If it grows, it belongs to a shared rules package and not
  to a copy of the rule engine inside Scan, so that ADR-003 (independence) is not broken.