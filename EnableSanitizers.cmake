# MIT License
#
# Copyright (c) 2023 The ViaDuck Project
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

set(VIADUCK_SANITIZERS OFF CACHE BOOL "")

if (VIADUCK_SANITIZERS AND CMAKE_CXX_COMPILER_ID MATCHES "(Apple)?[Cc]lang" AND NOT ANDROID)
    macro(make_viaduck_san_target name suffix)
        # parse flags
        cmake_parse_arguments(VIADUCK_SAN "" "" "COMPILE_FLAGS;LINK_FLAGS" ${ARGN})

        # call project macro to create basic test target
        make_viaduck_test_target(${name}_${suffix})
        # add flags
        target_compile_options(${name}_${suffix} PRIVATE
            # reasonable speed optimizations
            -O1
            # enable reduced debug infos
            -gline-tables-only
            # meaningful stack traces
            -fno-omit-frame-pointer
            # perfect stack traces
            -fno-optimize-sibling-calls
            # sanitizer specific compile flags
            ${VIADUCK_SAN_COMPILE_FLAGS}
        )
        target_link_options(${name}_${suffix} PRIVATE
            # sanitizer specific link flags
            ${VIADUCK_SAN_LINK_FLAGS}
        )
    endmacro()

    function(enable_sanitizers_for_target name)
        message(STATUS "Enabled sanitizers for ${name}")

        # ~no slowdown
        make_viaduck_san_target(${name} asan
            COMPILE_FLAGS -fsanitize=address,leak,undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,nullability
            -fsanitize-address-use-after-scope
            LINK_FLAGS -fsanitize=address
            )
        # slowdown ~1.5X
        make_viaduck_san_target(${name} tsan COMPILE_FLAGS -fsanitize=thread LINK_FLAGS -fsanitize=thread)
        # slowdown ~10X
        make_viaduck_san_target(${name} msan COMPILE_FLAGS -fsanitize=memory -fsanitize-recover=memory LINK_FLAGS -fsanitize=memory)
    endfunction()
else()
    function(enable_sanitizers_for_target name)
    endfunction()
endif()
