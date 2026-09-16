#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 or CC0-1.0
#
# Vendored pqclean's SPHINCS+ "*-simple" merkle.c assigns a local
# `unsigned int steps[]` array to a struct field typed `uint32_t *`
# (see mupq/pqclean/.../wotsx1.h: `uint32_t *wots_steps;`). Both are
# 32-bit unsigned integers, so this is harmless in practice, but it is
# a genuine pointer-*type* mismatch: on x86_64/glibc, uint32_t IS
# unsigned int, so it only ever warned there. On this ARM/newlib
# toolchain uint32_t is `long unsigned int`, a distinct type, and this
# arm-none-eabi-gcc 15.3 build rejects the mismatch by default via
# -Wincompatible-pointer-types instead of just warning.
#
# Upstream PQClean/PQClean fixed this later by retyping several
# functions across wots.c/wots.h/merkle.c. Rather than fork the
# pqclean submodule to carry that (or bump its pin, which risks
# breaking unrelated schemes), we apply the minimal one-line cast fix
# at the single assignment site in each affected scheme.
#
# This script is idempotent: it only touches files that still have
# the unpatched line, so it's safe to run on every `direnv` activation
# (see .envrc) even after `git submodule update` resets the submodule
# back to its pristine, unpatched state.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

SCHEMES=(
  sphincs-sha2-128f-simple sphincs-sha2-128s-simple
  sphincs-sha2-192f-simple sphincs-sha2-192s-simple
  sphincs-sha2-256f-simple sphincs-sha2-256s-simple
  sphincs-shake-128f-simple sphincs-shake-128s-simple
  sphincs-shake-192f-simple sphincs-shake-192s-simple
  sphincs-shake-256f-simple sphincs-shake-256s-simple
)

for scheme in "${SCHEMES[@]}"; do
  f="mupq/pqclean/crypto_sign/${scheme}/clean/merkle.c"
  if [ -f "$f" ] && grep -q 'info\.wots_steps = steps;' "$f"; then
    sed -i.bak 's/info\.wots_steps = steps;/info.wots_steps = (uint32_t *)steps;/' "$f"
    rm -f "$f.bak"
    echo "fix-sphincs-abi: patched $f"
  fi
done
