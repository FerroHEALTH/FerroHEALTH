<!-- SPDX-FileCopyrightText: Cadasto B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Memory index

- [Family architecture](family-architecture.md): owner 2026-10-25, five
  servers (FerroEHR, FerroBRIDGE, FerroFED, FerroPIX, FerroTERM) that reach
  each other only over published protocols; shared crates (FerroAUTH,
  FerroAUDIT, FerroUI, FerroSYS) for cross-cutting work, and FerroSYS is never
  a control plane; no product embeds another's
  domain; every console is reactive. A verbatim copy of the page every
  family repository carries.
