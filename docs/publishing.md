# Publishing

The catalogue distribution model follows Hightea ADR 0011 and ADR 0014: full signed snapshots over x0x gossip, not CRDT deltas.

## Topic

`x0x.commons.agent-conventions.v1`

## Publish Shape

Each publish is one complete baseline-style envelope containing:

- publisher verifying-key metadata;
- signature metadata;
- the complete `manifest.json` content.

Consumers verify the envelope, then replace their cached manifest wholesale if the signed `manifest.version` is newer than their current verified version.

## Current State

This initial repository seed does not implement publishing or signing. It only defines the data shape and baseline artefact. The signing key, signing CLI, and publish automation are intentionally deferred until the catalogue is ready to be consumed over x0x.

## Convergence Rule

Latest validly signed snapshot from an authorised publisher wins.

Consumers should ignore:

- unsigned topic messages;
- messages signed by an unknown publisher key;
- messages with invalid signatures;
- messages whose `manifest.version` is lower than the cached version;
- messages using an unsupported `schemaVersion`.

## Canonicalization

The intended signature input is RFC 8785 JSON Canonicalization Scheme output for the embedded `manifest` object, with signature context `x0x-agent-conventions-v1`.

The exact signing command is not specified yet because x0x should own the cryptographic primitive and public-key verification interface. This repo must not invent a parallel signing scheme.
