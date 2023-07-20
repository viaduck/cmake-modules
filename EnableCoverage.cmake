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

set(VIADUCK_COVERAGE OFF CACHE BOOL "Enable generation of coverage targets")
set(VIADUCK_COVERAGE_TYPE "lcov" CACHE STRING "Select the tool and mode used to generate coverage reports. Changing this type requires deleting all existing coverage files and recompiling the project")
set_property(CACHE VIADUCK_COVERAGE_TYPE PROPERTY STRINGS "lcov" "gcovr_xml" "gcovr_html" "fastcov")

if (VIADUCK_COVERAGE AND NOT WIN32 AND NOT ANDROID)
    # only include if we are generating coverage to avoid requiring coverage tools unnecessarily
    include(CodeCoverage)

    # setup specified target with suitable values for viaduck projects
    # assuming that the ${name} target has been created in the current scope and can be edited (for compiler flags)
    # and that it can be run without arguments
    #
    # name: name of target to generate coverage for
    # basedir: base directory of the target, this is where the exclusion paths will be relative to
    # argn: every other argument is an exclusion path
    function(enable_coverage_for_target name basedir)
        message(STATUS "Enabled coverage for ${name}")

        # include generated file for dynamic call based on coverage type
        # beware of issues with forwarding ARGV when positional arguments are lists
        set(temp_file "${CMAKE_CURRENT_BINARY_DIR}/temp_file.cmake")
        file(WRITE  "${temp_file}" "function(setup_target_for_coverage_dynamic)\n")
        file(APPEND "${temp_file}" "    setup_target_for_coverage_${VIADUCK_COVERAGE_TYPE}(\${ARGV})\n")
        file(APPEND "${temp_file}" "endfunction()")
        include("${temp_file}")

        # include git revision module
        include(GetGitRevisionDescription)
        get_git_head_revision(GIT_REFSPEC GIT_SHA1)

        # per-type-arguments
        set(COVERAGE_ARGS_lcov
            LCOV_ARGS --rc lcov_branch_coverage=1
            GENHTML_ARGS -t ${GIT_SHA1} --legend --branch-coverage)

        # add compiler and linker flags to target
        append_coverage_compiler_flags_to_target(${name})
        # create new target running the ${name} target
        setup_target_for_coverage_dynamic(
            NAME ${name}_coverage
            EXECUTABLE ${name}
            DEPENDENCIES ${name}
            BASE_DIRECTORY "${basedir}"
            EXCLUDE "/usr/*" ${ARGN}

            ${COVERAGE_ARGS_${VIADUCK_COVERAGE_TYPE}}
        )
    endfunction()
else()
    function(enable_coverage_for_target name)
    endfunction()
endif()
