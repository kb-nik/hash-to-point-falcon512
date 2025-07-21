pragma solidity ^0.8.2;


contract HashToPoint {
    bytes32[76] private SALTS = [
        bytes32("1"), bytes32("2"), bytes32("3"), bytes32("4"),
        bytes32("5"), bytes32("6"), bytes32("7"), bytes32("2"),
        bytes32("3"), bytes32("4"), bytes32("5"), bytes32("6"),
        bytes32("7"), bytes32("8"), bytes32("9"), bytes32("10"),
        bytes32("11"), bytes32("12"), bytes32("13"), bytes32("14"),
        bytes32("15"), bytes32("16"), bytes32("17"), bytes32("18"),
        bytes32("19"), bytes32("20"), bytes32("21"), bytes32("22"),
        bytes32("23"), bytes32("24"), bytes32("25"), bytes32("26"),
        bytes32("27"), bytes32("28"), bytes32("29"), bytes32("30"),
        bytes32("31"), bytes32("32"), bytes32("1"), bytes32("2"),
        bytes32("3"), bytes32("4"), bytes32("5"), bytes32("6"),
        bytes32("7"), bytes32("2"), bytes32("3"), bytes32("4"),
        bytes32("5"), bytes32("6"), bytes32("7"), bytes32("8"),
        bytes32("9"), bytes32("10"), bytes32("11"), bytes32("12"),
        bytes32("13"), bytes32("14"), bytes32("15"), bytes32("16"),
        bytes32("17"), bytes32("18"), bytes32("19"), bytes32("20"),
        bytes32("21"), bytes32("22"), bytes32("23"), bytes32("24"),
        bytes32("25"), bytes32("26"), bytes32("27"), bytes32("28"),
        bytes32("29"), bytes32("30"), bytes32("31"), bytes32("32")
    ];

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
        uint256 t;
        uint256 count;
        for (uint256 idx = 0; count < n; idx += 2) {
            uint16 v = uint16(uint8(ctx[idx])) << 8 | uint16(uint8(ctx[idx + 1]));
            result[count] = uint256(v) % q;
            unchecked { count++; }
        }
        return result;
    }
    receive() external payable {}
}
