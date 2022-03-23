pragma solidity ^0.8.6;

contract ConnectFour {

    event GameCreated(uint game_id, address player, uint256 wager);
    event GameJoined(uint game_id, address player);
    event GameFinished(uint game_id, address winner);

    struct GAME {
        address _player1;
        address _player2;
        uint256 _wager;
        bool _turn;
        uint8[7][6] board;
        uint256 _blockStart;
        uint256 _blockEnd;
        address winner;
    }

    uint public id_count = 1;
    mapping(uint => GAME) public GAMES;

    address ADMIN;
    constructor() {
        ADMIN = msg.sender;
    }

    function createGame() public payable {
        GAMES[id_count]._player1 = msg.sender;
        GAMES[id_count]._wager = msg.value;
        GAMES[id_count]._blockStart = block.timestamp;
        emit GameCreated(id_count, msg.sender, msg.value);
        id_count += 1;
    }

    function joinGame(uint256 game_id) public payable {
        GAME storage game = GAMES[game_id];
        require(game._player1 != address(0) && game._player2 == address(0), "Game already in play");
        require(game.winner == address(0), "Game already finished");
        require(msg.value == game._wager, "Wager does not match");
        game._player2 = msg.sender;
        game._wager += msg.value;
        emit GameJoined(game_id, msg.sender);
    }

    function move(uint game_id, uint8 col, bool claim) public {
        require(col < 7, "Invalid column");
        /* check whose turn and switch*/
        GAME storage game = GAMES[game_id];
        if (game._turn == false) { require(game._player1 == msg.sender, "It is not your turn!"); game._turn = true; }
        else { require(game._player2 == msg.sender, "It is not your turn!"); game._turn = false; }

        /* Find free space*/
        uint8 count = 0;
        while (game.board[count][col] != 0) {
            count += 1;
        }

        /* Place chip */
        /* 1 for player1 */
        if(game._turn == true) {
            game.board[count][col] = 1;
        }
        /* 2 for player2 */
        else {
            game.board[count][col] = 2;
        }

        if(claim == true) { this.claimWin(game_id, msg.sender); }
    }

    /* Check board logic and send wager to winner */
    function claimWin(uint game_id, address player) external payable {
        GAME storage game = GAMES[game_id];
        require(game._player1 == player || game._player2 == player, "Address given is not a player in this game");
        uint8 player_n;
        if(game._player1 == player) { player_n = 1; }
        else { player_n = 2; }

        if(checkBoard(game_id, player_n) == true) {
            /* Finalize game*/
            game._blockEnd = block.timestamp;
            game.winner = player;
            payable(player).transfer(game._wager);
            emit GameFinished(game_id, player);
        }
    }

    function checkBoard(uint game_id, uint8 player) internal view returns (bool) {
        GAME storage game = GAMES[game_id];

        uint8 counter = 0;
        /* Check Horizontal */
        for(uint8 c = 0; c < 7; c++) {
            for(uint8 r = 0; r < 6; r++) {
                if(game.board[r][c] == player) { counter += 1; }
                else { counter = 0; }

                if(counter == 4) {
                    return true;
                }
            }
            counter = 0;
        }
        /* Check Vertical */
         for(uint8 r = 0; r < 6; r++) {
            for(uint8 c = 0; c < 7; c++) {
                if(game.board[r][c] == player) { counter += 1; }
                else { counter = 0; }

                if(counter == 4) {
                    return true;
                }
            }
            counter = 0;
        }

        /* Check Diagonal Ascending*/
        /* Check Diagonal Descending*/
        return false;
    }

    function viewBoard(uint game_id) public view returns(uint8[7][6] memory) {
        return GAMES[game_id].board;
    }
}
