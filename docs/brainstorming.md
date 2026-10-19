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