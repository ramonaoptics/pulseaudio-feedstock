#!/usr/bin/env bash

meson_config_args=(
    --buildtype=release
    -D libdir=lib
    --prefix=${PREFIX}
    --wrap-mode=nodownload
    -D database=simple
    -D doxygen=false
    -D udevrulesdir=${PREFIX}/lib/udev/rules.d
)

# MESON_ARGS is set by conda compiler activation script
meson setup buildconda \
    ${MESON_ARGS} \
    "${meson_config_args[@]}" \
    || (cat buildconda/meson-logs/meson-log.txt; false)
meson compile -v -C buildconda -j ${CPU_COUNT}
meson test -C buildconda --print-errorlogs --timeout-multiplier 10 --num-processes ${CPU_COUNT}
meson install -C buildconda --no-rebuild
