# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(native_sqlcipher_library VERSION 0.0.1 LANGUAGES C CXX)

add_library(native_sqlcipher SHARED
  native_sqlcipher.c
  sqlite3.c
  fts5_hans.cpp
)

set_target_properties(native_sqlcipher PROPERTIES
  PUBLIC_HEADER native_sqlcipher.h
  OUTPUT_NAME "native_sqlcipher"
)

target_compile_definitions(native_sqlcipher PUBLIC 
  DART_SHARED_LIB
  #SQLITE_API=FFI_PLUGIN_EXPORT
  SQLITE_HAS_CODEC
  SQLITE_TEMP_STORE=3
  SQLITE_THREADSAFE=1
  SQLITE_ENABLE_FTS5
  SQLITE_OMIT_LOAD_EXTENSION
  SQLITE_OMIT_DEPRECATED
  SQLITE_EXTRA_INIT=sqlcipher_extra_init
  SQLITE_EXTRA_SHUTDOWN=sqlcipher_extra_shutdown
  HAVE_STDINT_H
  SQLITE_EXTRA_AUTOEXT=sqlite3_fts5_hans_init
  
)

set_target_properties(native_sqlcipher PROPERTIES
  CXX_STANDARD 11
  CXX_STANDARD_REQUIRED ON
)

if(ANDROID)
  set(JNI_LIBS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../android/src/main/jniLibs)
  add_library(crypto SHARED IMPORTED)
  set_target_properties(crypto PROPERTIES
    IMPORTED_LOCATION ${JNI_LIBS_DIR}/${ANDROID_ABI}/libcrypto.so)
  
  add_library(ssl SHARED IMPORTED)
  set_target_properties(ssl PROPERTIES
      IMPORTED_LOCATION ${JNI_LIBS_DIR}/${ANDROID_ABI}/libssl.so)
      
  target_link_libraries(native_sqlcipher PRIVATE crypto ssl)
  target_include_directories(native_sqlcipher
    PUBLIC
      ${CMAKE_CURRENT_SOURCE_DIR}
    PRIVATE
      ${CMAKE_CURRENT_SOURCE_DIR}/android/include
      ${CMAKE_CURRENT_SOURCE_DIR}/include
  )
  find_library(log-lib log)
  target_link_libraries(native_sqlcipher PRIVATE ${log-lib})

  # Support Android 15 16k page size
  target_link_options(native_sqlcipher PRIVATE "-Wl,-z,max-page-size=16384")
else()
  find_package(OpenSSL REQUIRED)
  target_link_libraries(native_sqlcipher PRIVATE OpenSSL::Crypto)
  target_include_directories(native_sqlcipher
    PUBLIC
      ${CMAKE_CURRENT_SOURCE_DIR}
    PRIVATE
      ${OPENSSL_INCLUDE_DIR}
      ${CMAKE_CURRENT_SOURCE_DIR}/include
  )
endif()
