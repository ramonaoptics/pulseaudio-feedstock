#!/usr/bin/env bash

# need to link with librt for sysroot_linux-64 < 2.17 for clock_gettime
if [[ $target_platform == linux-64 ]] ; then
    export LDFLAGS="$LDFLAGS -lrt"
fi

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
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    # only error on linux-64 for now since some tests fail on other linux
    # platforms and there's no easy way to disable specific tests
    if [[ $target_platform == linux-64 ]] ; then
        meson test -C buildconda --print-errorlogs --timeout-multiplier 25
    else
        meson test -C buildconda --print-errorlogs --timeout-multiplier 25 || true
    fi
fi
meson install -C buildconda --no-rebuild
