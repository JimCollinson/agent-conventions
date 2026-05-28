# Schema

This repository is data-only. Consumers must treat catalogue files as structured data and must not execute anything distributed through the catalogue.

## Versioning

- `schemaVersion` identifies the manifest schema shape.
- `version` is a monotonic snapshot sequence number and is the convergence key.
- `updatedAt` is an RFC 3339 timestamp for operator visibility.
- Consumers ignore snapshots with a lower `version` than their current verified snapshot.
- Consumers should fail soft on unknown fields.
- Consumers should reject unknown major `schemaVersion` values and continue using their embedded baseline or last verified snapshot.

## Manifest Shape

```json
{
  "schemaVersion": 1,
  "version": 1,
  "updatedAt": "2026-05-28T12:07:06Z",
  "topic": "x0x.commons.agent-conventions.v1",
  "source": {
    "derivedFrom": "Hightea src/skills-bridge.ts",
    "sourcePackage": "skills@1.5.7"
  },
  "agents": []
}
```

Each agent entry contains:

- `id`: stable kebab-case product identifier.
- `displayName`: human-readable product name.
- `status`: current curation status. The initial seed uses `seeded` for entries copied from Hightea's vendored table.
- `lastVerifiedAt`: date of direct vendor/source verification, or `null` when only seeded from an upstream table.
- `detection.anyOf`: declarative signals. A consumer may treat any matching signal as evidence that the product is installed.
- `assets.skills.paths.default`: ordered candidate paths for skill placement.
- `assets.skills.format`: a named format understood by consumers.
- `assets.skills.activation`: how the product discovers or activates the asset.
- `capabilities`: categories currently described by the entry.

## Path Variables

Paths are literal templates, not shell scripts. Consumers expand only documented variables:

- `$HOME`
- `$PWD`
- `${XDG_CONFIG_HOME:-$HOME/.config}`
- `${CLAUDE_CONFIG_DIR:-$HOME/.claude}`
- `${CODEX_HOME:-$HOME/.codex}`
- `${VIBE_HOME:-$HOME/.vibe}`

## Baseline Envelope

`baseline.json` wraps a manifest with signing metadata:

```json
{
  "schemaVersion": 1,
  "version": 1,
  "updatedAt": "2026-05-28T12:07:06Z",
  "topic": "x0x.commons.agent-conventions.v1",
  "publisher": {
    "name": "Jim Collinson",
    "publicKey": null,
    "publicKeyEncoding": null,
    "keyId": null
  },
  "signature": {
    "algorithm": null,
    "value": null,
    "encoding": "base64",
    "canonicalization": "rfc8785-json-canonicalization",
    "context": "x0x-agent-conventions-v1"
  },
  "manifest": {}
}
```

The initial baseline intentionally has null signing fields. Consumers must not treat it as cryptographically authenticated until a real publisher public key and signature are present.
