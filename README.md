# GCS Consent State Reader — Server-side GTM Variable Template

A Server-side Google Tag Manager (SGTM) Custom Variable Template that reads
Google Consent Mode GCS signals from incoming event data and returns the
consent state for a selected category.

---

## Overview

When GA4 tags fire with Consent Mode enabled, they include a GCS parameter
in the outbound request. This parameter encodes whether a user has granted
or denied consent for Analytics and Advertising in a compact four-character
string such as `G100`, `G101`, `G110`, or `G111`.

This template reads that signal directly from SGTM event data and returns
a plain `granted` or `denied` value for whichever consent category you
configure. The returned value can then be used to control tag firing, enrich
event payloads, or feed into any other logic inside your server container.

---

## When to Use This Template

- You want to make tag firing decisions in SGTM based on a user's consent state
- You need to pass consent status as a parameter to downstream vendor endpoints
- You are building consent-aware data pipelines in a server container
- You want to avoid writing custom JavaScript variables for GCS parsing

---

## Features

- Supports both **Analytics** and **Advertising** consent categories
- Automatically uses the standard GA4 GCS event data key (`x-ga-gcs`) or
  accepts a custom key you define
- Returns `granted`, `denied`, or `undefined` depending on the parsed value
  and your configuration
- Optional fallback handling for missing or unrecognised GCS values
- Clean, validated input handling with no silent failures

---

## GCS Value Reference

Google Consent Mode encodes consent signals in the following format:

**G1XY**

Where:

- `X` represents **Advertising** consent — `0` for denied, `1` for granted
- `Y` represents **Analytics** consent — `0` for denied, `1` for granted

| GCS Value | Advertising | Analytics |
|-----------|-------------|-----------|
| `G100`    | denied      | denied    |
| `G101`    | denied      | granted   |
| `G110`    | granted     | denied    |
| `G111`    | granted     | granted   |

---

## Setup Instructions

1. In your Server-side GTM container, navigate to **Templates**
2. Click **New** under the Variable Templates section
3. Click the overflow menu and select **Import**
4. Import the `.tpl` file from this repository
5. Click **Save**
6. Navigate to **Variables** and click **New**
7. Under Variable Type, select **GCS Consent State Reader**
8. Configure the template fields as described below
9. Name your variable and save — for example, `GCS - Analytics Consent`

Repeat steps 6–9 to create a second variable instance for the other consent
category if needed.

---

## Field Reference

### Consent Category

Select which consent category this variable should evaluate.

| Option        | Description                                      |
|---------------|--------------------------------------------------|
| Analytics     | Returns the analytics consent state from the GCS value |
| Advertising   | Returns the advertising consent state from the GCS value |

This is a required field. Each variable instance evaluates one category.
Create separate variable instances if you need both.

---

### Event Data Key

Controls how the template locates the GCS value inside the incoming event.

| Option                       | Behaviour                                              |
|------------------------------|--------------------------------------------------------|
| Automatic (use GA4 signals)  | Reads from the standard GA4 key `x-ga-gcs`. Recommended for most setups. |
| Manual                       | Displays a text input where you can enter a custom event data key. |

Use **Automatic** if your traffic comes from GA4 tags with Consent Mode
enabled and you have not customised the GCS parameter name upstream.

Use **Manual** if your implementation uses a different parameter name or you
are forwarding events from a custom source that maps the GCS value to a
different key.

---

### Enable Fallback When Consent Value Is Missing or Unrecognised

When checked, the template returns a default consent state instead of
`undefined` in the following situations:

- The configured event data key is not present in the event
- The GCS value is present but cannot be parsed as a valid GCS string

When unchecked, the template returns `undefined` in those situations.

Enabling this option reveals the **Fallback Consent State** selector.

---

### Fallback Consent State

Only visible when the fallback option is enabled.

| Option  | Description                                                 |
|---------|-------------------------------------------------------------|
| denied  | Returns `denied` when the consent value is missing or invalid. Recommended default for privacy-first implementations. |
| granted | Returns `granted` when the consent value is missing or invalid. Use with caution. |

If you are unsure which fallback to choose, select **denied**.

---

## Triggering Recommendations

This is a Variable Template, so it does not fire on its own. Use the
variable it produces in:

- **Tag firing conditions** — add a condition such as
  `{{GCS - Analytics Consent}} equals granted` to an existing trigger
- **Blocking triggers** — prevent a tag from firing when the variable
  returns `denied`
- **Tag fields** — pass the consent value as a parameter to a downstream
  endpoint or enrichment tag

---

## Testing and Validation

Use GTM's **Preview mode** to validate the variable before publishing.

1. Send a test event through your server container that includes a GCS value
   in the event data
2. Open the Preview panel and select the event
3. Navigate to **Variables** and locate your GCS variable instance
4. Confirm the returned value matches the expected consent state for the
   GCS string in your test event

### Recommended test cases

| GCS Value in Event | Category    | Expected Return |
|--------------------|-------------|-----------------|
| `G111`             | Analytics   | `granted`       |
| `G111`             | Advertising | `granted`       |
| `G100`             | Analytics   | `denied`        |
| `G100`             | Advertising | `denied`        |
| `G101`             | Analytics   | `granted`       |
| `G101`             | Advertising | `denied`        |
| `G110`             | Analytics   | `denied`        |
| `G110`             | Advertising | `granted`       |
| Missing parameter  | Either      | `undefined` or fallback value |
| Invalid GCS string | Either      | `undefined` or fallback value |

---

## Troubleshooting

**The variable always returns `undefined`**

The GCS parameter is not present in your event data. Open GTM Preview, select
the relevant event, and check the event data panel to confirm whether
`x-ga-gcs` or your custom key exists. If it is missing, the GCS signal is
not being forwarded to your server container — check your GA4 tag
configuration and Consent Mode setup on the client side.

**The variable returns `undefined` for some events but not others**

Consent Mode signals are only included when the GA4 client-side tag fires
with Consent Mode active. Events from other sources, direct hits, or
requests that bypass your consent banner may not carry a GCS value. Enable
the fallback option and set it to `denied` to handle these cases
consistently.

**The variable returns the wrong consent state**

Confirm you have selected the correct consent category in the field
configuration. Analytics and Advertising consent are separate fields within
the GCS string. Also confirm the GCS value in your event data matches what
you expect — use GTM Preview to inspect the raw event data parameter.

**The custom event data key field is not visible**

The custom key field only appears when **Event Data Key** is set to
**Manual**. Switch the dropdown to Manual to reveal the text input.

---

## Notes and Limitations

- This template only supports the standard four-character GCS format
  (`G1XY`). Extended or custom consent string formats are not supported.
- One variable instance returns one consent category. Create two instances
  if you need both Analytics and Advertising states available in your
  container.
- The template does not write to or modify event data — it is strictly
  read-only.
- GCS values are normalised to uppercase before parsing, so lowercase
  inputs such as `g111` are handled correctly.
- Custom and Community Templates are supported for web and server-side
  containers only. Mobile container support is not available.

---

## Support

If you encounter an issue or have a feature request, please open an issue
in this repository with the following information:

- The GCS value present in your event data
- The template field configuration you are using
- The value the variable is returning
- The value you expected

---

## License

This template is released under the Apache 2.0 License. See `LICENSE` for
full terms.
