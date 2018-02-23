/*

OLD, deprecated deployed address: "0x42f3659c55b5a10e556c2da7e613c6f741ddb39f"
OLD, depracated deployed address #2: "0x72b79424419139bf5f73848387d86ffa56054fb6"
OLD deploy string: "0x97f535e98cf250cdd7ff0cb9b29e4548b609a0bd", 2240000000
OLD deprecated main chain deployed address: '0x573ef20fc84fe9326e37ea82a9033c032c9ca9d1'

deploy string (will use my account to move the tokens easily to the ICO before passing control to the multisig):
"0x79BD7d159aBA396B68d714aF62E954FDEF09D16A", 3339687500
Current RINKEBY Deploy:
"0xb608678520ee8b741759b6de187939dee3514906", 3339687500



Current MAINCHAIN Deploy String:
"0x97f535e98cf250CDd7Ff0cb9B29E4548b609A0bd", 3339687500

Current MAINCHAIN Deploy address:
'0xD70B659aE2C61FC52A31723af84A1922747feAb7'


TODO: Publish this then transfer the total supply to the ICO contract once it is published and it's address known.
*/

pragma solidity ^0.4.11;

library SafeMath {
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC223Compliant {
    function tokenFallback(address _from, uint _value, bytes _data) {}
}

contract EtheraffleLOT is ERC223Compliant {
    using SafeMath for uint;

    string    public name;
    string    public symbol;
    bool      public frozen;
    uint8     public decimals;
    address[] public freezers;
    address   public etheraffle;
    uint      public totalSupply;

    mapping (address => uint) public balances;
    mapping (address => bool) public canFreeze;

    event LogFrozenStatus(bool status, uint atTime);
    event LogFreezerAddition(address newFreezer, uint atTime);
    event LogFreezerRemoval(address freezerRemoved, uint atTime);
    event LogEtheraffleChange(address prevER, address newER, uint atTime);
    event LogTransfer(address indexed from, address indexed to, uint value, bytes indexed data);

    /**
     * @dev   Modifier function to prepend to methods rendering them only callable
     *        by the Etheraffle MultiSig wallet.
     */
    modifier onlyEtheraffle() {
        require(msg.sender == etheraffle);
        _;
    }
    /**
     * @dev   Modifier function to prepend to methods rendering them only callable
     *        by address approved for freezing.
     */
    modifier onlyFreezers() {
        require(canFreeze[msg.sender]);
        _;
    }
    /**
     * @dev   Modifier function to prepend to methods to render them only callable
     *        when the frozen toggle is false
     */
    modifier onlyIfNotFrozen() {
        require(!frozen);
        _;
    }
    /**
     * @dev   Constructor: Sets the meta data for the token and gives the intial supply to the
     *        Etheraffle ICO.
     *
     * @param _etheraffle   Address of the Etheraffle's multisig wallet, the only
     *                      address via which the frozen/unfrozen state of the
     *                      token transfers can be toggled.
     * @param _supply       Total numner of LOT to mint on contract creation.

     */
    function EtheraffleLOT(address _etheraffle, uint _supply) {
        freezers.push(_etheraffle);
        name                   = "Etheraffle LOT";
        symbol                 = "LOT";
        decimals               = 6;
        etheraffle             = _etheraffle;
        totalSupply            = _supply * 10 ** uint256(decimals);
        balances[_etheraffle]  = totalSupply;
        canFreeze[_etheraffle] = true;
    }
    /**
     * ERC223 Standard functions:
     *
     * @dev Transfer the specified amount of LOT to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to     Receiver address.
     * @param _value  Amount of LOT to be transferred.
     * @param _data   Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes _data) onlyIfNotFrozen external {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to]        = balances[_to].add(_value);
        if(codeLength > 0) {
            ERC223Compliant receiver = ERC223Compliant(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        LogTransfer(msg.sender, _to, _value, _data);
    }
    /**
     * @dev   Transfer the specified amount of LOT to the specified address.
     *        Standard function transfer similar to ERC20 transfer with no
     *        _data param. Added due to backwards compatibility reasons.
     *
     * @param _to     Receiver address.
     * @param _value  Amount of LOT to be transferred.
     */
    function transfer(address _to, uint _value) onlyIfNotFrozen external {
        uint codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to]        = balances[_to].add(_value);
        if(codeLength > 0) {
            ERC223Compliant receiver = ERC223Compliant(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        LogTransfer(msg.sender, _to, _value, empty);
    }
    /**
     * @dev     Returns balance of the `_owner`.
     * @param _owner    The address whose balance will be returned.
     * @return balance  Balance of the `_owner`.
     */
    function balanceOf(address _owner) constant external returns (uint balance) {
        return balances[_owner];
    }
    /**
     * @dev   Change the frozen status of the LOT token.
     *
     * @param _status   Desired status of the frozen bool
     */
    function setFrozen(bool _status) external onlyFreezers returns (bool) {
        frozen = _status;
        LogFrozenStatus(frozen, now);
        return frozen;
    }
    /**
     * @dev     Allow addition of freezers to allow future contracts to
     *          use the role.
     *
     * @param _new  New freezer address.
     */
    function addFreezer(address _new) external onlyEtheraffle {
        freezers.push(_new);
        canFreeze[_new] = true;
        LogFreezerAddition(_new, now);
    }
    /**
     * @dev     Remove a freezer should they no longer require or need the
     *          the privilege.
     *
     * @param _freezer    The desired address to be removed.
     */
    function removeFreezer(address _freezer) external onlyEtheraffle {
        require(canFreeze[_freezer]);
        canFreeze[_freezer] = false;
        for(uint i = 0; i < freezers.length - 1; i++)
            if(freezers[i] == _freezer) {
                freezers[i] = freezers[freezers.length - 1];
                break;
            }
        freezers.length--;
        LogFreezerRemoval(_freezer, now);
    }
    /**
     * @dev   Allow changing of contract ownership ready for future upgrades/
     *        changes in management structure.
     *
     * @param _new  New owner/controller address.
     */
    function setEtheraffle(address _new) external onlyEtheraffle {
        LogEtheraffleChange(etheraffle, _new, now);
        etheraffle = _new;
    }
    /**
     * @dev   Fallback in case of accidental ether transfer
     */
    function () external payable {
        revert();
    }
    /**
     * @dev   Housekeeping- called in the event this contract is no
     *        longer needed, after a LOT upgrade for example. Deletes
     *        the code from the blockchain. Only callable by the
     *        Etheraffle address.
     */
    function selfDestruct() external onlyEtheraffle {
        require(frozen);
        selfdestruct(etheraffle);
    }
}
/*
MAIN CHAIN

0xD70B659aE2C61FC52A31723af84A1922747feAb7

[{"constant":true,"inputs":[],"name":"frozen","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balances","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_freezer","type":"address"}],"name":"removeFreezer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_new","type":"address"}],"name":"addFreezer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"canFreeze","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_new","type":"address"}],"name":"setEtheraffle","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_status","type":"bool"}],"name":"setFrozen","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"etheraffle","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"freezers","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"selfDestruct","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"},{"name":"_data","type":"bytes"}],"name":"transfer","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_value","type":"uint256"},{"name":"_data","type":"bytes"}],"name":"tokenFallback","outputs":[],"payable":false,"type":"function"},{"inputs":[{"name":"_etheraffle","type":"address"},{"name":"_supply","type":"uint256"}],"payable":false,"type":"constructor"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"status","type":"bool"},{"indexed":false,"name":"atTime","type":"uint256"}],"name":"LogFrozenStatus","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"newFreezer","type":"address"},{"indexed":false,"name":"atTime","type":"uint256"}],"name":"LogFreezerAddition","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"freezerRemoved","type":"address"},{"indexed":false,"name":"atTime","type":"uint256"}],"name":"LogFreezerRemoval","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"prevER","type":"address"},{"indexed":false,"name":"newER","type":"address"},{"indexed":false,"name":"atTime","type":"uint256"}],"name":"LogEtheraffleChange","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"},{"indexed":true,"name":"data","type":"bytes"}],"name":"LogTransfer","type":"event"}]

*/
