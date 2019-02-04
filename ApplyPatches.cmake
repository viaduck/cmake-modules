# MIT License
#
# Copyright (c) 2019 The ViaDuck Project
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

find_program(PATCH_PROGRAM patch)
if (NOT PATCH_PROGRAM)
    message(FATAL_ERROR "Cannot find patch utility")
endif()

macro(ApplyPatches patch_glob target_dir)
    # find all patch files
    file(GLOB PATCH_FILES ${patch_glob})

    # apply each patch subsequently
    foreach(PATCH_FILE ${PATCH_FILES})
        # try to apply the patch
        execute_process(
                COMMAND ${PATCH_PROGRAM} -p1 -i ${PATCH_FILE}
                RESULT_VARIABLE PATCH_RESULT
                WORKING_DIRECTORY ${target_dir}
        )

        if (NOT ${PATCH_RESULT} EQUAL "0")
            message(FATAL_ERROR "Failed to apply patch: ${PATCH_FILE}")
        endif()
    endforeach()
endmacro()

macro(ApplyPatchesOnce name patch_glob target_dir)
    if (NOT ${name}_patched)
        ApplyPatches(${patch_glob} ${target_dir})
        set(${name}_patched TRUE CACHE BOOL "Indicates whether the patches were already applied" FORCE)
    endif()
endmacro()
