# Sorted

Weekly meal planning on autopilot: Sorted reads your calendar, plans meals that hit your macros, works out what you already have, fills your supermarket basket and books a delivery slot.

Hackathon proof of concept, October 2026.

## What's here

| Path | What it is |
|---|---|
| [PRD.md](PRD.md) | Product requirements: problem, scope, flow, AI design, build plan |
| [prototype/index.html](prototype/index.html) | Clickable prototype of the full flow, with sample data |
| [website/index.html](website/index.html) | Marketing page with the live demo and a waitlist |
| [website/demo.html](website/demo.html) | Generated copy of the prototype for the website. Don't edit it by hand |
| [scripts/build-demo.sh](scripts/build-demo.sh) | Rebuilds `website/demo.html` from the prototype |

Everything is plain HTML, CSS and JavaScript. There's nothing to install.

## Running locally

Open `prototype/index.html` in a browser.

The website's waitlist and embedded demo only work on the published page, because they rely on the hosting platform's storage.

## Published links

- Prototype: https://claude.ai/artifact/PTTcy8mipqdz65ncGHPQ2w
- Website: https://claude.ai/artifact/KjjGj6CA9mksP2ECTYGUR9

## Changing the prototype

1. Edit `prototype/index.html`.
2. Run `sh scripts/build-demo.sh` to update the website's copy.
3. Republish both.
