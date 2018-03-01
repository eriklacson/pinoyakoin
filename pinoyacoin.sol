pragma solidity ^0.4.18;

contract administer {


    address public admin;

    function administer() public {

        admin = msg.sender;

        }

    modifier onlyAdmin() {

        require (msg.sender == admin);
        _;
                    
        }

    function transferedAdmin(address newAdmin) public onlyAdmin {

        admin = newAdmin;

        }       
}

contract Coin {

        string public standard = "Coin 0.1";
        string public name;
        string public symbol;
        uint256 public totalSupply;
        uint8 public decimals;



        /* This creates an array with all balances */
        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowance;


        /* Set-up events */
        event Transfer(address indexed from, address indexed to, uint256 value);

        /* Initializes contract with initial supply tokens to the creator of the contract */
        function Coin (uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public {
            balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
            name = tokenName;                                   // Set the name for display purposes
            symbol = tokenSymbol;                               // Set the symbol for display purposes
            decimals = decimalUnits;                            // Amount of decimals for display purposes 
            totalSupply = initialSupply;                        // Initial Total Tokens Available
            
            }
            
        /* Method to tansfer tokens */
        function transfer(address _to, uint256 _value) public {
            
            /* Notify anyone listening that this transfer took place */
            Transfer(msg.sender, _to, _value);
            
            /* Check if sender has balance and for overflows */
            
            require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);

            /* Add and subtract new balances */
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            }

        /* Method to approve another user to transfer tokens in behalf of  */   
        function approve(address _spender, uint256 _value) public returns (bool success) {

            allowance[msg.sender][_spender] = _value; //assign allowed maximum transfer value
            return true;
            }

        /* Method to transfer funds in behalf of another user */    
        function transferFrom (address _from, address _to, uint256 _value) public returns (bool success) {

            require(balanceOf[_from] > _value); //check if source has enough tokens for the transaction
            require((balanceOf[_to] + _value) > balanceOf[_to]); // check for overflows
            require(_value < allowance[_from][msg.sender]); //check of sender is approve to execute transaction
            balanceOf[_from] -= _value; //subtract transfered tokens from source
            balanceOf[_to] += _value; //add transfered tokens to recipient
            allowance[_from][msg.sender] -= _value; //subtract from sender maximum allowed token transfer  
            Transfer(_from,_to,_value); //send event
            return true; //returns success

           }   
                                
    }

 contract PinoyAkoin is administer, Coin {

    unint256 public sellPrice;
    unint256 public buyPrice;
    mapping(address => bool) public frozenAccount;

    event FrozenFund (address target, bool frozen);

    function PinoyAkoin (uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, address centralAdmin) Coin(0, tokenName, tokenSymbol, decimalUnits) public {

        totalSupply = initialSupply;

        if (centralAdmin != 0) {

            admin = centralAdmin;

            }
        else { admin = msg.sender;} 

        balanceOf[admin] = initialSupply;

        }

    function mintToken (address target, uint256 mintAmount) public onlyAdmin {

        balanceOf[target] += mintAmount;
        totalSupply += mintAmount;
        Transfer(0, this, mintAmount);
        Transfer(this, target, mintAmount);

        }

    function freezeToken (address target, bool freeze) public onlyAdmin {

        frozenAccount[target] = freeze;
        FrozenFund(target, freeze);


        }


    /* Method to tansfer tokens */
        function transfer(address _to, uint256 _value) public {
            
            /* Notify anyone listening that this transfer took place */
            Transfer(msg.sender, _to, _value);
                        
            require(frozenAccount[_to]); //check if account is frozen
            require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]); //check for balance overflows

            /* Add and subtract new balances */
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            }    


    /* Method to transfer funds in behalf of another user */    
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success) {

            require(frozenAccount[_from]); //check if account is frozen
            require(balanceOf[_from] > _value); //check if source has enough tokens for the transaction
            require((balanceOf[_to] + _value) > balanceOf[_to]); // check for overflows
            require(_value < allowance[_from][msg.sender]); //check of sender is approve to execute transaction
            balanceOf[_from] -= _value; //subtract transfered tokens from source
            balanceOf[_to] += _value; //add transfered tokens to recipient
            allowance[_from][msg.sender] -= _value; //subtract from sender maximum allowed token transfer  
            Transfer(_from,_to,_value); //send event
            return true; //returns success

           }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyAdmin {

        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;

        }

    function buy payble {

        uint256 amount = (msg.value/(1 ether)) / buyPrice;
        require (balanceOf[this] > amount);
        balanceOf[msg.sender] += amount;
        balanceOf[this] -= amount;
        Transfer(this, msg.sender, amount)


        }

    function sell (uint256 amount) {

        require(balanceOf[msg.sender] > amount);
        balanceOf[this] += amount;
        balanceOf[msg.sender] -= amount;
        if(!msg.sender.send(amount * sellPrice * 1 ether)) {
            throw;
            }
        else {

            Transfer(msg.sender, this, amount);            

            }



        }                      

}    