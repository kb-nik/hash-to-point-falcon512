// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract FalconDecompressor {
    error InvalidLength();
    error InvalidEncoding();
    error TrailingBitsNotZero();
    error ValueTooLarge();


    function decompress(bytes calldata data, uint256 n) external payable returns (int256[] memory out) {
        uint256 bitLen = data.length * 8;
        if (bitLen < n * 9) revert InvalidLength();

        out = new int256[](n);
        uint256 idx;

        for (uint256 i = 0; i < n; ++i) {
            bool neg = _getBit(data, idx); idx++;
            uint256 abs7 = _readBits(data, idx, 7); idx += 7;

            uint256 k;
            while (true) {
                if (idx >= bitLen) revert InvalidEncoding();
                if (_getBit(data, idx)) { idx++; break; }
                unchecked { k++; idx++; }
                if (k > 256) revert InvalidEncoding();
            }

            uint256 val = abs7 + (k << 7);
            if (val > uint256(type(int256).max)) revert ValueTooLarge();
            out[i] = neg ? -int256(val) : int256(val);
        }

        while (idx < bitLen) {
            if (_getBit(data, idx)) revert TrailingBitsNotZero();
            idx++;
        }
    }

    function _getBit(bytes calldata data, uint256 bitIndex) internal pure returns (bool) {
        uint256 bytePos = bitIndex >> 3;
        uint256 bitPos  = 7 - (bitIndex & 7);
        return ((uint8(data[bytePos]) >> bitPos) & 1) == 1;
    }

    function _readBits(bytes calldata data, uint256 bitIndex, uint256 count) internal pure returns (uint256 result) {
        for (uint256 j; j < count; ++j) {
            result = (result << 1) | (_getBit(data, bitIndex + j) ? 1 : 0);
        }
    }
}
