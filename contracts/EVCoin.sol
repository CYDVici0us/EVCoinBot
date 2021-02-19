/***************************************************************************************/
/*                  EVCOIN
/*By: Carson Case
/*A simple LGE ERC20 token that allows "ev" to mint tokens at will
/***************************************************************************************/
pragma solidity ^0.6.6;

//Imports
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';


//Contract is an ERC20
contract EVCoin is ERC20{
    /* =====Events=====*/
    event ethRaised(address,uint256);

    /* =====State Variables=====*/
    uint256 public LGESupply;
    uint256 public totalETHContributed;
    uint256 public endTime;
    address public LPTokenReceiver;
    address public ev;
    bool public LGEComplete = false;

    /*=====Data Structures=====*/
    mapping(address => uint256) contributers;
    address[] contributerList;

    /*=====Interfaces=====*/
    IUniswapV2Router02 public UniswapV2Router02;
    
    /*=====Constructor=====*/
    constructor(    
    uint256 _LGESupply,                     //->ERC20 Tokens to be minted for LGE
    uint256 _devFee,                        //->ERC20 Tokens to be minted for Dev Fee                  
    address _UniswapV2Router02,             //->Address of Uniswap Router             
    address _LPTokenReceiver,               //->Address of the recipitent of Liquidity tokens     
    address _ev,                            //->Ev's Address 
    uint256 _endTime)                       //->End time for LGE               
    ERC20("EvCoin", "EV") public {
        UniswapV2Router02 = IUniswapV2Router02(_UniswapV2Router02);     //Initialize Uniswap router
        LGESupply = _LGESupply;                                         //Note tokens to be sent off in LGE
        _mint(address(this),_LGESupply);                                //Mint those tokens to contract
        _mint(msg.sender,_devFee);                                      //Mint dev fee
        LPTokenReceiver = _LPTokenReceiver;                             //LP Token receiver
        ev = _ev;
        endTime = _endTime;                                             //End time
    }

    /*=======================+++++++++========================*/
    /*=======================Modifiers========================*/
    /*=======================+++++++++========================*/

    /*=====IsEv=====*/
    modifier isEv(){
        require(msg.sender == ev);
        _;
    }

    /*====================+++++++++++++++++====================*/
    /*====================Private Functions====================*/
    /*====================+++++++++++++++++====================*/

    /*=====IsOver=====
    Returns if LGE is over or not
    */
    function _isOver() private view returns(bool){
        if(block.timestamp >= endTime){
            return true;
        }else{
            return false;
        }
    }

    /*====================++++++++++++++++=====================*/
    /*====================Public Functions=====================*/
    /*====================++++++++++++++++=====================*/
    
    /*=====Grant EvCoins=====
    Mints evcoin to _who.
    Can only be called by ev
    */
    function grant(address _who, uint256 _howMuch) public isEv{
        _mint(_who,_howMuch);
    }

    /*=====endLGE=====*/
    function endLGE(uint256 _timeout) public{
        //requires
        require(_isOver());                                                         //Require LGE is over
        require(!LGEComplete);                                                      //Require LGE is not already completed

        this.approve(address(UniswapV2Router02),LGESupply);                         //Approve LGE tokens to be sent off

        UniswapV2Router02.addLiquidityETH                                           //Send the liquidity to Uniswap
        {value:address(this).balance}                                               //Ammount of ETH to send
        (             
            address(this),                                                          //Address of non-eth token
            LGESupply,                                                              //Ammount of tokens
            0,  //For these refer to                                                                    
            0,  //Uniswap docs
            LPTokenReceiver,                                                        //Recipitent of tokens
            now+_timeout);                                                          //Timeout to revert
       
        LGEComplete = true;                                                         //Set LGE to complete
    }

    /* =====Receive Function=====*/
    receive() payable external{
        require(!_isOver());                                                        //Require LGE is still going on
        emit ethRaised(msg.sender,msg.value);
        totalETHContributed += msg.value;                                           //Increase total value of ETH raised
        contributerList.push(msg.sender);                                           //Push to list of contributers                                           
        contributers[msg.sender] = msg.value;                                       //Note how much was contributed
    }

    /*=====TEST=====*/
    function test_timestamp() public view returns(uint256){
        return(block.timestamp);
    }

}

