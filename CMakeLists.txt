project(quick-memo C CXX)
cmake_minimum_required(VERSION 2.8.9)

# Set Quick Memo version
set(VERSION_MAJOR 1)
set(VERSION_MINOR 0)

# Sets BZR_REVNO
execute_process(
    COMMAND bzr revno ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE BZR_REVNO
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(NOT BZR_REVNO)
    set(BZR_REVNO "latest")
endif(NOT BZR_REVNO)


# Do not remove this line, its required for the correct functionality of the Ubuntu-SDK
set(UBUNTU_MANIFEST_PATH "manifest.json.in" CACHE INTERNAL "Tells QtCreator location and name of the manifest file")
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

find_package(Qt5Core)
find_package(Qt5Qml)
find_package(Qt5Quick)
# find_package(ubuntu-sdk-libs)

# Automatically create moc files
set(CMAKE_AUTOMOC ON)

# Components PATH
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")

option(INSTALL_TESTS "Install the tests on make install" on)

set(APP_NAME          quick-memo)
set(APP_DIR           "app")
set(MAIN_QML          "main.qml")
set(DESKTOP_FILE      "quick-memo.desktop")
set(ICON              "graphics/memo.svg")

# Set install paths
set(CMAKE_INSTALL_PREFIX /)
set(DATA_DIR /)
set(DESKTOP_DIR ${DATA_DIR})
set(DESKTOP_FILE_NAME "quick-memo.desktop")

set(EXEC "qmlscene $@ ${APP_DIR}/${MAIN_QML}")

# This command figures out the target architecture for use in the manifest file
execute_process(
  COMMAND dpkg-architecture -qDEB_HOST_ARCH
  OUTPUT_VARIABLE CLICK_ARCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Configure manifest.json
configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json
        DESTINATION ${CMAKE_INSTALL_PREFIX})
configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/app_info.json)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/app_info.json DESTINATION ${DATA_DIR})

install(DIRECTORY "app/graphics" DESTINATION ${DATA_DIR})
install(FILES "quick-memo.apparmor" DESTINATION ${DATA_DIR})
install(FILES "COPYING" DESTINATION ${DATA_DIR})
install(FILES "COPYING.LGPL-3" DESTINATION ${DATA_DIR})
install(FILES "copyright" DESTINATION ${DATA_DIR})

# "App" subdirectory
configure_file(${DESKTOP_FILE_NAME}.in ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE_NAME}.in)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE} DESTINATION ${DESKTOP_DIR})

file(GLOB_RECURSE QML_JS_FILES *.qml *.js)
add_custom_target(quick-memo_QMlFiles ALL
    SOURCES ${QML_JS_FILES}
    COMMAND cp -r ${CMAKE_CURRENT_SOURCE_DIR}/app ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${QMLFILES}
)
install(DIRECTORY app DESTINATION ${DATA_DIR})

add_subdirectory(po)

add_custom_target("autopilot" chmod +x ${CMAKE_SOURCE_DIR}/app/tests/autopilot/run
                    COMMAND ${CMAKE_SOURCE_DIR}/app/tests/autopilot/run
                    DEPENDS quick-memobackend quick-memobackend-qmldir
                    WORKING_DIRECTORY ./app)

add_custom_target("check" /usr/bin/qmltestrunner -input ${CMAKE_SOURCE_DIR}/app/tests/unit -import ${CMAKE_BINARY_DIR}/backend
                    DEPENDS quick-memobackend quick-memobackend-qmldir
                    WORKING_DIRECTORY ./app)

add_custom_target("run" /usr/bin/qmlscene -I ${CMAKE_BINARY_DIR}/backend  ${CMAKE_SOURCE_DIR}/app/quick-memo.qml
                    DEPENDS quick-memobackend quick-memobackend-qmldir
                    WORKING_DIRECTORY ./app)

# No op custom target for all not compiled files, so they show up in the QtCreator project tree
add_custom_target("quick-memo_ClickFiles" ALL SOURCES "quick-memo.apparmor" "manifest.json.in")

