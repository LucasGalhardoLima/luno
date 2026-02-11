# Contract: Formspree Waitlist Form Integration

**Feature**: 002-lunar-design
**Date**: 2026-02-10

## Form Submission

### Endpoint
- **URL**: User-provided Formspree URL (format: `https://formspree.io/f/{form_id}`)
- **Method**: POST
- **Content-Type**: `application/x-www-form-urlencoded` (HTML form) or `application/json` (AJAX)

### Required Fields

| Field | Type | Validation | Description |
|-------|------|------------|-------------|
| `email` | string | Valid email format | User's email address |

### Optional Hidden Fields

| Field | Type | Description |
|-------|------|-------------|
| `utm_source` | string | Traffic source |
| `utm_medium` | string | Traffic medium |
| `utm_campaign` | string | Campaign name |
| `locale` | string | User's locale (e.g., `en-US`) |

### Spam Prevention

| Field | Type | Description |
|-------|------|-------------|
| `website` | string | Honeypot field — must be empty; hidden from users via CSS/SR-only |

### Response (AJAX mode)

**Success** (HTTP 200):
```json
{
  "ok": true,
  "next": "https://formspree.io/thanks"
}
```

**Validation Error** (HTTP 422):
```json
{
  "error": "Invalid email address",
  "errors": [{ "field": "email", "message": "..." }]
}
```

### Behavior

1. **HTML fallback**: Form submits via standard HTML `action` — Formspree handles redirect
2. **AJAX enhancement**: JavaScript intercepts submit, calls `fetch()`, shows inline feedback
3. **Success state**: Replace form with "Thank you" message
4. **Error state**: Show validation error inline below email field
5. **Loading state**: Disable submit button, show spinner
