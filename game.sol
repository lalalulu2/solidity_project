// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract rockScissorsPaper {
    struct room
    {

        address player1;
        address player2;

        bytes32 hash1;
        bytes32 hash2;

        uint8 res1;
        uint8 res2;

        address winner;
        uint8 counter;

        bool draw;
        bool open;
    }

    mapping (uint => room) rooms;

    function roomOpen(uint id) public {
        rooms[id].open = true;
        rooms[id].player1 = msg.sender;
        rooms[id].counter = 1;
    }

    function joinPlayer(uint id) public {
        require(msg.sender != rooms[id].player1 && rooms[id].counter == 1 && rooms[id].open == true);
        rooms[id].player2 = msg.sender;
        rooms[id].counter = 2;
    }

    modifier verify1 (uint id){
        require(msg.sender == rooms[id].player1 && rooms[id].counter == 2 && rooms[id].open == true);
        _;
    }

    modifier verify2 (uint id){
        require(msg.sender == rooms[id].player2 && rooms[id].counter == 2 && rooms[id].open == true);
        _;
    }
    function movePlayer1(uint id, bytes32 hash1) public verify1(id){
        rooms[id].hash1 = hash1;
        if (rooms[id].hash2 != 0x0) {
            rooms[id].counter = 3;
        }
    }
    function movePlayer2(uint id, bytes32 hash2) public verify2(id){
        rooms[id].hash2 = hash2;
        if (rooms[id].hash1 != 0x0) {
            rooms[id].counter = 3;
        }
    }

    function decodeHash1(uint id, string calldata seed1) public {
        require(msg.sender == rooms[id].player1 && rooms[id].counter == 3 && keccak256(bytes(seed1)) == rooms[id].hash1 && rooms[id].open == true);
        if (str_to_bytes_1(seed1) == 0x31) rooms[id].res1 = 1;
        if (str_to_bytes_1(seed1) == 0x32) rooms[id].res1 = 2;
        if (str_to_bytes_1(seed1) == 0x33) rooms[id].res1 = 3;
        if (rooms[id].res1 != 0x0 &&  rooms[id].res2 != 0x0) {
            rooms[id].counter == 4;
            winner(id);
        }
    }

    function decodeHash2(uint id, string calldata seed2) public {
        require(msg.sender == rooms[id].player2 && rooms[id].counter == 3 && keccak256(bytes(seed2)) == rooms[id].hash2 && rooms[id].open == true);
        if (str_to_bytes_1(seed2) == 0x31) rooms[id].res2 = 1;
        if (str_to_bytes_1(seed2) == 0x32) rooms[id].res2 = 2;
        if (str_to_bytes_1(seed2) == 0x33) rooms[id].res2 = 3;
        if (rooms[id].res1 != 0x0 &&  rooms[id].res2 != 0x0) {
            rooms[id].counter == 4;
            winner(id);
        }
    }


    function winner(uint id) internal {
        if (rooms[id].res1 == rooms[id].res2) rooms[id].draw = true; //если одинаковые значения, то ничья
        // перебор значений и определение победителя
        if (rooms[id].res1 == 1 && rooms[id].res2 == 2) rooms[id].winner = rooms[id].player1;
        if (rooms[id].res1 == 1 && rooms[id].res2 == 3) rooms[id].winner = rooms[id].player2;
        if (rooms[id].res1 == 2 && rooms[id].res2 == 1) rooms[id].winner = rooms[id].player2;
        if (rooms[id].res1 == 2 && rooms[id].res2 == 3) rooms[id].winner = rooms[id].player1;
        if (rooms[id].res1 == 3 && rooms[id].res2 == 1) rooms[id].winner = rooms[id].player1;
        if (rooms[id].res1 == 3 && rooms[id].res2 == 2) rooms[id].winner = rooms[id].player2;
        rooms[id].open = false;
    }

    event Win(address indexed _winner);

    function seeWinner(uint id) public returns(address) {
        if (rooms[id].draw == true) return 0x0000000000000000000000000000000000000000;
        else {
            emit Win(rooms[id].winner);
            return rooms[id].winner;
        }
    }

    function str_to_bytes_1(string calldata seed) pure internal returns(bytes1){
        bytes memory seed_b;
        seed_b = bytes(seed);
        return seed_b[0];
    }
}
