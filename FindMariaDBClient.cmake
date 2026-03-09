# MIT License
#
# Copyright (c) 2018 The ViaDuck Project
# Copyright (c) 2026 Towel 42 Development, LLC and Scott Aron Bloom
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

# - Try to find MariaDB client library. This matches both the "old" client library and the new C connector.
# Once found this will define
#  MariaDBClient_FOUND - System has MariaDB client library
#  MariaDBClient_INCLUDE_DIRS - The MariaDB client include directory (typically 1)
#  MariaDBClient_LIBRARY_DIR - The MariaDB client library directory
#  MariaDBClient_LIBRARIES   - The library to link against
#  MariaDBClient_INSTALL_FILES - The Files to install for a self contained installation (shared library)


# includes
#set(CMAKE_FIND_DEBUG_MODE TRUE)
find_path(MariaDBClient_INCLUDE_DIRS
        NAMES mariadb/mysql.h mysql.h  #NOTE due to the forking of MySQL into MariaDB the primary header file is mysql.h
        PATH_SUFFIXES mariadb/include include
        HINTS ${MariaDB_ROOT} ${MySQL_ROOT}
        NO_CACHE
        NO_DEFAULT_PATH
        DOC The location of the MariaDB include directory
)
#set(CMAKE_FIND_DEBUG_MODE FALSE)        
#message( STATUS MariaDBClient_INCLUDE_DIRS=${MariaDBClient_INCLUDE_DIRS})

# library
#set(CMAKE_FIND_DEBUG_MODE TRUE)
find_path(MariaDBClient_LIBRARY_DIR
        NAMES libmariadb.lib mariadb.lib
        PATH_SUFFIXES mariadb lib
        HINTS ${MariaDB_ROOT} ${MySQL_ROOT}
        NO_CACHE
        NO_DEFAULT_PATH
        DOC The location of the MariaDB library directory
)
#set(CMAKE_FIND_DEBUG_MODE FALSE)        
#MESSAGE( STATUS MariaDBClient_LIBRARY_DIR=${MariaDBClient_LIBRARY_DIR})

#set(CMAKE_FIND_DEBUG_MODE TRUE)
find_library(MariaDBClient_LIBRARY
        NAMES mariadb
        PATH_SUFFIXES mariadb/lib lib
        HINTS ${MariaDB_ROOT} ${MySQL_ROOT}
        NO_CACHE
        NO_DEFAULT_PATH
        NAMES_PER_DIR
        )
#set(CMAKE_FIND_DEBUG_MODE FALSE)        
#MESSAGE( STATUS MariaDBClient_LIBRARY=${MariaDBClient_LIBRARY})

set(BAK_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_SHARED_LIBRARY_SUFFIX})
find_library(MariaDBClient_INSTALL_FILES
        NAMES mariadb
        PATH_SUFFIXES mariadb/lib lib
        HINTS ${MariaDB_ROOT} ${MySQL_ROOT}
        NO_CACHE
        NO_DEFAULT_PATH
        )
 
if(WIN32 AND MariaDBClient_INSTALL_FILES)
    set(CMAKE_FIND_LIBRARY_SUFFIXES .pdb)
    find_library(_pdb_file
            NAMES mariadb
            PATH_SUFFIXES mariadb/lib lib
            HINTS ${MariaDB_ROOT} ${MySQL_ROOT}
            NO_CACHE
            NO_DEFAULT_PATH
            )
    
    SET( MariaDBClient_INSTALL_FILES ${MariaDBClient_INSTALL_FILES} ${_pdb_file})
endif()

set(CMAKE_FIND_LIBRARY_SUFFIXES ${BAK_CMAKE_FIND_LIBRARY_SUFFIXES})

#message( STATUS MariaDBClient_INCLUDE_DIRS=${MariaDBClient_INCLUDE_DIRS})
#message( STATUS MariaDBClient_LIBRARY_DIR=${MariaDBClient_LIBRARY_DIR})
#message( STATUS MariaDBClient_LIBRARY=${MariaDBClient_LIBRARY})
#message( STATUS MariaDBClient_INSTALL_FILES=${MariaDBClient_INSTALL_FILES})

include(FindPackageHandleStandardArgs)
SET( ERROR_MESSAGE "Could NOT find MariaDBClient - Please set MariaDB_ROOT or MySQL_ROOT" )
find_package_handle_standard_args(
    MariaDBClient #package name
    ${ERROR_MESSAGE} #error message
    MariaDBClient_INCLUDE_DIRS        #required vars
    MariaDBClient_LIBRARY_DIR   
    MariaDBClient_LIBRARY  
    MariaDBClient_INSTALL_FILES
    
)

if(MariaDBClient_FOUND)
    if(NOT TARGET MariaDBClient::MariaDBClient)
        add_library(MariaDBClient::MariaDBClient UNKNOWN IMPORTED)
        set_target_properties(
            MariaDBClient::MariaDBClient 
        PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MariaDBClient_INCLUDE_DIRS}"
            IMPORTED_LOCATION "${MariaDBClient_LIBRARY}"
        )
    endif()
endif()

mark_as_advanced(
    MariaDBClient_INCLUDE_DIRS
    MariaDBClient_LIBRARY_DIR
    MariaDBClient_LIBRARY
    MariaDBClient_INSTALL_FILES)

set(MariaDBClient_INCLUDE_DIRS  ${MariaDBClient_INCLUDE_DIRS})
set(MariaDBClient_LIBRARY_DIR   ${MariaDBClient_LIBRARY_DIR})
set(MariaDBClient_LIBRARIES     ${MariaDBClient_LIBRARY})
set(MariaDBClient_INSTALL_FILES ${MariaDBClient_INSTALL_FILES})
