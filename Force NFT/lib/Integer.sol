pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

library Integer {
    function toString(int256 a, uint256 radix)
        internal pure returns(string memory) {
        
        if (a == 0) {
            return "0";
        }
        
        uint256 m = a < 0 ? uint256(-a) : uint256(a);
        
        uint256 length = 0;
        for (uint256 n = m; n != 0; n /= radix) {
            ++length;
        }
        
        bytes memory bs;
        if (a < 0) {
            bs = new bytes(++length);
            bs[0] = bytes1(uint8(45));
        } else {
            bs = new bytes(length);
        }
        
        for (uint256 i = length - 1; m != 0; --i) {
            uint256 b = m % radix;
            m /= radix;
            
            if (b < 10) {
                bs[i] = bytes1(uint8(b + 48));
            } else {
                bs[i] = bytes1(uint8(b + 87));
            }
        }
        
        return string(bs);
    }
    
    function toString(int256 a) internal pure returns(string memory) {
        return Integer.toString(a, 10);
    }
}
