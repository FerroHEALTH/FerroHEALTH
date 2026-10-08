#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# toolchain.sh: the pinned documentation toolchain, in one place.
#
#   . scripts/site/toolchain.sh             (sets the three variables)
#   scripts/site/toolchain.sh               (prints the install-action list)
#
# The versions are the ones FerroEHR's docs toolchain pins
# (.github/actions/docs-toolchain in that repository), so every book in the
# family builds and is checked with the same tools. assemble.sh refuses an
# mdbook of another version, and pages.yml installs exactly these. Move a pin
# in step with FerroEHR, after building the book with the new version.

export MDBOOK_VERSION=0.5.4
export MDBOOK_LINT_VERSION=0.14.4
export LYCHEE_VERSION=0.24.2

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "mdbook@${MDBOOK_VERSION},mdbook-lint@${MDBOOK_LINT_VERSION},lychee@${LYCHEE_VERSION}"
fi
