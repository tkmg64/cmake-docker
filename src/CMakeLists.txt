set(BinaryName SampleApp)
set(LibraryName ${BinaryName}Lib)

add_library(${LibraryName} SHARED main.cpp func.cpp)
target_include_directories(${LibraryName} PUBLIC include)

add_executable(${BinaryName} main.cpp func.cpp)
target_include_directories(${BinaryName} PUBLIC include)
target_link_libraries(${BinaryName} ${LibraryName})