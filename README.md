# agent-conventions

Declarative catalogue of AI coding-agent filesystem conventions: detection rules, placement paths, asset formats, and capability flags.

The first consumer is Hightea. The catalogue is initially private under `JimCollinson/agent-conventions`; transfer to Saorsa Labs, WithAutonomi, or x0x remains a later decision once the catalogue has proved useful.

## What This Is

- A data-only registry of agent product conventions.
- A baked-in baseline for consumers that need to work before x0x networking is available.
- A future signed snapshot feed on the x0x gossip topic `x0x.commons.agent-conventions.v1`.

## What This Is Not

- It is not a package manager.
- It is not a directory of x0x agent identities.
- It does not publish skills, prompts, commands, or MCP servers.
- It does not distribute executable code over x0x.

## Files

- `manifest.json` is the unsigned source catalogue.
- `baseline.json` is the signed-snapshot envelope shape that consumers can embed. The initial file carries placeholder signing fields because the publisher key has not been generated yet.
- `schema.md` documents the current schema and compatibility rules.
- `docs/publishing.md` documents the planned signed-snapshot publishing model.
- `scripts/verify-topic.sh` is a local operator check for x0x topic reachability and envelope shape.

## Branches

The default branch is `main`, matching the Saorsa Labs / WithAutonomi convention.

## License

MIT for now. If this repo transfers to Saorsa Labs, WithAutonomi, or x0x, the license may be revisited as part of that transfer.
