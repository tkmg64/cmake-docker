#pragma once

#include <cstdint>

/**
 * @file device.h
 * @brief ハードウェア通信抽象インターフェースおよびコントローラーの定義
 * @author 開発チーム
 * @date 2026-09-23
 */

/**
 * @brief 外部通信デバイスを抽象化するインターフェースクラス
 *
 * @details
 * ハードウェア依存処理（レジスタへの読み書き、外部バス通信など）を抽象化し、
 * 単体テスト時に Google Mock (gmock) によるモック化を可能にするための純粋仮想クラスです。
 */
class IDevice {
public:
    virtual ~IDevice() noexcept = default;

    /**
     * @brief デバイスのアドレスに値を書き込みます。
     * @param[in] address 書込先アドレス (32ビット符号付き整数)
     * @param[in] value 書込値 (32ビット符号付き整数)
     * @return true 書込成功
     * @return false 書込失敗
     */
    [[nodiscard]] virtual bool write(std::int32_t address, std::int32_t value) = 0;

    /**
     * @brief デバイスのアドレスから値を読み出します。
     * @param[in] address 読出元アドレス (32ビット符号付き整数)
     * @return std::int32_t 読み出された値
     */
    [[nodiscard]] virtual std::int32_t read(std::int32_t address) = 0;
};

/**
 * @brief IDevice インターフェースを利用して通信を制御するコントローラークラス
 *
 * @details
 * 依存性注入 (Dependency Injection) により IDevice の参照を受け取り、
 * 上位層のビジネスロジックと下位層のハードウェアアクセスを疎結合にします。
 */
class DeviceController final {
public:
    /**
     * @brief コンストラクタ
     * @param[in] device 通信に使用するデバイスインターフェースの参照
     */
    explicit DeviceController(IDevice& device) noexcept : device_(device) {}

    ~DeviceController() noexcept = default;
    DeviceController(const DeviceController&) = delete;
    DeviceController& operator=(const DeviceController&) = delete;
    DeviceController(DeviceController&&) noexcept = default;
    DeviceController& operator=(DeviceController&&) noexcept = default;

    /**
     * @brief データを書き込み、正しく書き込まれたか即座に読み出して検証します。
     *
     * @param[in] address 対象アドレス
     * @param[in] value 書込値
     * @return true 書込が成功し、読出値が書込値と一致した場合
     * @return false 書込に失敗、または読出値が不一致の場合
     */
    [[nodiscard]] bool writeAndVerify(std::int32_t address, std::int32_t value) {
        if (!device_.write(address, value)) {
            return false;
        }
        const std::int32_t read_val = device_.read(address);
        return read_val == value;
    }

private:
    IDevice& device_;
};
