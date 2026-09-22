#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <cstdint>

#include "device.h"

namespace {

/**
 * @brief Google Mock を利用した IDevice のモッククラス
 */
class MockDevice : public IDevice {
public:
    MOCK_METHOD(bool, write, (std::int32_t address, std::int32_t value), (override));
    MOCK_METHOD(std::int32_t, read, (std::int32_t address), (override));
};

// 正常系: write 成功かつ read で一致する値が取得できた場合
TEST(DeviceControllerMockTest, WriteAndVerify_Success) {
    MockDevice mock_device;
    DeviceController controller(mock_device);

    constexpr std::int32_t kTargetAddress = 0x1000;
    constexpr std::int32_t kTargetValue = 42;

    // write(0x1000, 42) が1回呼ばれて true を返すことを期待
    EXPECT_CALL(mock_device, write(kTargetAddress, kTargetValue))
        .Times(1)
        .WillOnce(testing::Return(true));

    // read(0x1000) が1回呼ばれて 42 を返すことを期待
    EXPECT_CALL(mock_device, read(kTargetAddress)).Times(1).WillOnce(testing::Return(kTargetValue));

    EXPECT_TRUE(controller.writeAndVerify(kTargetAddress, kTargetValue));
}

// 異常系: write が失敗した場合、read は呼び出されずに false が返ること
TEST(DeviceControllerMockTest, WriteAndVerify_WriteFails) {
    MockDevice mock_device;
    DeviceController controller(mock_device);

    constexpr std::int32_t kTargetAddress = 0x1000;
    constexpr std::int32_t kTargetValue = 42;

    // write が失敗するシナリオ
    EXPECT_CALL(mock_device, write(kTargetAddress, kTargetValue))
        .Times(1)
        .WillOnce(testing::Return(false));

    // write 失敗時は read が一切呼び出されないことを検証
    EXPECT_CALL(mock_device, read(testing::_)).Times(0);

    EXPECT_FALSE(controller.writeAndVerify(kTargetAddress, kTargetValue));
}

// 異常系: write は成功したが read で書き込んだ値と異なる値が返った場合
TEST(DeviceControllerMockTest, WriteAndVerify_ReadMismatch) {
    MockDevice mock_device;
    DeviceController controller(mock_device);

    constexpr std::int32_t kTargetAddress = 0x1000;
    constexpr std::int32_t kTargetValue = 42;
    constexpr std::int32_t kCorruptedValue = 99;

    EXPECT_CALL(mock_device, write(kTargetAddress, kTargetValue))
        .Times(1)
        .WillOnce(testing::Return(true));

    // 異なる値が返却されるシナリオ
    EXPECT_CALL(mock_device, read(kTargetAddress))
        .Times(1)
        .WillOnce(testing::Return(kCorruptedValue));

    EXPECT_FALSE(controller.writeAndVerify(kTargetAddress, kTargetValue));
}

}  // namespace
