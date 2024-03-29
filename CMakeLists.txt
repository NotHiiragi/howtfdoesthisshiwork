include(qpm_defines.cmake)

set(MOD_ID "pinkcute")

cmake_minimum_required(VERSION 3.21)
project(${COMPILE_ID} C CXX ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED 20)

set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

set(CMAKE_ASM_FLAGS "${CFLAGS} -x assembler-with-cpp")

add_compile_options(-frtti -fexceptions)
add_compile_options(-O3)
add_compile_definitions(VERSION=\"${MOD_VERSION}\")
add_compile_definitions(MOD_ID=\"${MOD_ID}\")

RECURSE_FILES(cpp_file_list ${SOURCE_DIR}/*.cpp)
RECURSE_FILES(c_file_list ${SOURCE_DIR}/*.c)
RECURSE_FILES(asm_file_list ${SOURCE_DIR}/*.s)

add_library(
        ${COMPILE_ID}
        SHARED
        ${cpp_file_list}
        ${c_file_list}
        ${asm_file_list}
)

target_include_directories(${COMPILE_ID} PRIVATE .)


target_include_directories(${COMPILE_ID} PRIVATE ${SOURCE_DIR})

target_include_directories(${COMPILE_ID} PRIVATE ${INCLUDE_DIR})

target_include_directories(${COMPILE_ID} PUBLIC ${SHARED_DIR})

target_include_directories(${COMPILE_ID} PRIVATE ${EXTERN_DIR}/includes/${CODEGEN_ID}/include)

target_link_libraries(${COMPILE_ID} PRIVATE -llog)

include(extern.cmake)

add_custom_command(TARGET ${COMPILE_ID} POST_BUILD
        COMMAND ${CMAKE_STRIP} -d --strip-all
        "lib${COMPILE_ID}.so" -o "stripped_lib${COMPILE_ID}.so"
        COMMENT "Strip debug symbols done on final binary.")

add_custom_command(TARGET ${COMPILE_ID} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory debug
        COMMENT "Make directory for debug symbols"
        )

add_custom_command(TARGET ${COMPILE_ID} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E rename lib${COMPILE_ID}.so debug/lib${COMPILE_ID}.so
        COMMENT "Rename the lib to debug_ since it has debug symbols"
        )


add_custom_command(TARGET ${COMPILE_ID} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E rename stripped_lib${COMPILE_ID}.so lib${COMPILE_ID}.so
        COMMENT "Rename the stripped lib to regular"
        )
        foreach(so_file ${so_list})
        cmake_path(GET so_file FILENAME file)
        
        add_custom_command(TARGET ${COMPILE_ID} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy ${so_file} debug/${file}
                COMMENT "Copy so files for ndk stack"
        )
        
        add_custom_command(TARGET ${COMPILE_ID} POST_BUILD
                COMMAND ${CMAKE_STRIP} -g -S -d --strip-all ${so_file} -o ${file}
                COMMENT "Strip debug symbols from the dependencies")
        endforeach()
        
        foreach(a_file ${a_list})
        cmake_path(GET a_file FILENAME file)
        
        add_custom_command(TARGET ${COMPILE_ID} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${a_file} debug/${file}
        COMMENT "Copy a files for ndk stack")
        endforeach()
