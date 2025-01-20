set(TestBinary testSampleApp)

file(GLOB MY_SRCS ${PROJECT_SOURCE_DIR}/src/*.cpp)
set(MY_INCLUDE_PATH ${PROJECT_SOURCE_DIR}/src)


set(MY_SRCS_MINUS_MAIN ${MY_SRCS})
list(REMOVE_ITEM MY_SRCS_MINUS_MAIN ${PROJECT_SOURCE_DIR}/src/main.cpp)

file(GLOB MY_TEST_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
set(MY_TEST_INCLUDE_PATH ${CMAKE_CURRENT_SOURCE_DIR})


add_executable(${TestBinary}
  ${MY_TEST_SRCS}
  ${MY_SRCS_MINUS_MAIN}
  )

target_include_directories(${TestBinary} PUBLIC
  ${MY_INCLUDE_PATH}
  ${MY_TEST_INCLUDE_PATH}
  )

target_link_libraries(${TestBinary} gtest_main)