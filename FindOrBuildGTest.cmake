set(GTEST_SRC_DIR "" CACHE PATH "Path to GTest source")

if (GTEST_SRC_DIR)
    message(STATUS "Path to GTest source specified; adding to project")

    # add subdirectory so that gtest is built automatically
    if (NOT TARGET gtest)
        add_subdirectory(${GTEST_SRC_DIR} ${CMAKE_CURRENT_BINARY_DIR}/gtest)
    endif()
    set(GTEST_FOUND TRUE)
    set(GTEST_BOTH_LIBRARIES gtest gtest_main)
else()
    if (NOT GTEST_FOUND)
        message(STATUS "No path to GTest source specified. Trying to find GTest.")

        find_package(GTest)

        if (GTEST_FOUND)
            message(STATUS "Found GTest.")
        endif()
    endif()
endif()
