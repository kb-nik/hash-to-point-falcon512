// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract HashToPoint {
    bytes32[76] private SALTS;

    constructor() {
        for (uint256 i = 0; i < SALTS.length; i++) {
            SALTS[i] = bytes32(i + 1);
        }
    }

    function shake(string calldata message) private view returns (bytes memory) {
        bytes memory buf = new bytes(64 * 32);
        for (uint256 i = 0; i < 64; ++i) {
            bytes32 h = keccak256(abi.encodePacked(SALTS[i], message));
            assembly {
                mstore(add(add(buf, 32), mul(i, 32)), h)
            }
        }
        return buf;
    }

    function hash_to_point(uint256 q,uint256 n,string calldata message) external view returns (uint256[] memory result) {
        require(n <= 512, "n too large");
        result = new uint256[](n);
        bytes memory ctx = shake(message);
        uint256 count;
        for (uint256 idx = 0; count < n; idx += 2) {
            uint16 v = (uint16(uint8(ctx[idx])) << 8)
                     | uint16(uint8(ctx[idx + 1]));
            result[count] = uint256(v) % q;
            unchecked { count++; }
        }
        return result;
    }

    receive() external payable {}
}
