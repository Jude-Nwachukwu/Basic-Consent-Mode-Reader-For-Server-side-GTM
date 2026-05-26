___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Basic GCS Consent State Reader",
  "description": "Reads Google Consent Mode GCS values from SGTM event data and returns granted/denied for Analytics or Advertising consent categories.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "consentCategory",
    "displayName": "Consent category",
    "selectItems": [
      {
        "value": "analytics",
        "displayValue": "Analytics"
      },
      {
        "value": "advertising",
        "displayValue": "Advertising"
      }
    ],
    "simpleValueType": true,
    "help": "Select the consent category to evaluate from the GCS value.",
    "defaultValue": "analytics"
  },
  {
    "type": "SELECT",
    "name": "gcsParameterMode",
    "displayName": "Event data key",
    "selectItems": [
      {
        "value": "auto",
        "displayValue": "Automatic (use GA4 signals)"
      },
      {
        "value": "manual",
        "displayValue": "Manual"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "auto",
    "help": "Automatic uses the standard GA4 GCS key (x-ga-gcs). Select Manual to specify a custom event data key."
  },
  {
    "type": "TEXT",
    "name": "gcsParameterCustom",
    "displayName": "Custom event data key",
    "simpleValueType": true,
    "help": "Enter the event data key that contains the GCS value (e.g. x-ga-gcs).",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "gcsParameterMode",
        "paramValue": "manual",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "enableFallback",
    "checkboxText": "Enable fallback when consent value is missing or unrecognised",
    "simpleValueType": true,
    "defaultValue": false
  },
  {
    "type": "SELECT",
    "name": "fallbackValue",
    "displayName": "Fallback consent state",
    "selectItems": [
      {
        "value": "denied",
        "displayValue": "denied"
      },
      {
        "value": "granted",
        "displayValue": "granted"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "denied",
    "enablingConditions": [
      {
        "paramName": "enableFallback",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "help": "The value to return when the GCS parameter is missing or the value cannot be parsed."
  }
]


___SANDBOXED_JS_FOR_SERVER___

// ─────────────────────────────────────────────────────────────────
// GCS Consent State Reader
// Reads a Google Consent Mode GCS string (e.g. "G111") from SGTM
// event data and returns the consent state for the selected category.
//
// GCS Format: G1XY
//   X (index 2) = Advertising consent  → 0: denied, 1: granted
//   Y (index 3) = Analytics consent    → 0: denied, 1: granted
// ─────────────────────────────────────────────────────────────────

const getEventData = require('getEventData');

// ── Read template field values ────────────────────────────────────
const category       = data.consentCategory;    // 'analytics' | 'advertising'
const paramMode      = data.gcsParameterMode;   // 'auto' | 'manual'
const enableFallback = data.enableFallback;
const fallbackValue  = data.fallbackValue;      // 'granted' | 'denied'

// ── Resolve the event data key based on selected mode ─────────────
// Auto mode always uses the standard GA4 GCS key.
// Manual mode uses the user-supplied key, with a safe fallback to
// the standard key if the field was somehow left empty.
const GCS_DEFAULT_KEY = 'x-ga-gcs';

const paramKey = (paramMode === 'manual' && data.gcsParameterCustom)
  ? data.gcsParameterCustom
  : GCS_DEFAULT_KEY;

// ── Resolve fallback or undefined ────────────────────────────────
function resolveDefault() {
  return enableFallback ? fallbackValue : undefined;
}

// ── Read and validate the GCS string from event data ─────────────
const gcsValue = getEventData(paramKey);

if (!gcsValue || typeof gcsValue !== 'string') {
  return resolveDefault();
}

const gcs = gcsValue.trim().toUpperCase();

// GCS strings must begin with 'G1' and be exactly 4 characters.
// Valid pattern: G1XY where X and Y are each '0' or '1'.
if (gcs.length !== 4 || gcs.indexOf('G1') !== 0) {
  return resolveDefault();
}

const advertisingDigit = gcs.charAt(2);  // X
const analyticsDigit   = gcs.charAt(3);  // Y

// Both digits must be '0' or '1'.
if ((advertisingDigit !== '0' && advertisingDigit !== '1') ||
    (analyticsDigit   !== '0' && analyticsDigit   !== '1')) {
  return resolveDefault();
}

// ── Map digit to consent state ────────────────────────────────────
function digitToState(digit) {
  return digit === '1' ? 'granted' : 'denied';
}

// ── Return the requested consent category ─────────────────────────
if (category === 'advertising') {
  return digitToState(advertisingDigit);
}

if (category === 'analytics') {
  return digitToState(analyticsDigit);
}

// ── Unknown category — should not reach here with valid field config
return resolveDefault();


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 5/26/2026, 12:41:29 PM


