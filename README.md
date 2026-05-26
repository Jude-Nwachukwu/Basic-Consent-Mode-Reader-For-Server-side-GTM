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
