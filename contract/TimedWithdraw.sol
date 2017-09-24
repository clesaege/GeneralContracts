/**
 *  @title Timed Withdraw
 *  @author Clément Lesaege - <clement@lesaege.com>
 *  Bug Bounties: This code hasn't undertaken a bug bounty program yet.
 */

pragma solidity ^0.4.16;

/** @title Timed Withdraw
 *  Owner can prepare a withdraw which takes time before it can be proceeded.
 *  Emergency can withdraw at anytime.
 */
contract TimedWithdraw{
    address public owner; // Address which can withdraw with a delay.
    address public emergency; // Address which can widraw at any time.
    uint public delay; // Delay to withdraw.
    
    struct Transaction {
        address recipient;
        uint amount;
        bytes transactionData;
        uint timeReady;
        bool executed;
    }
    Transaction[] public transactions;
    
    event TransactionPrepared();
    
    modifier onlyOwner {require(msg.sender==owner); _;}
    modifier onlyEmergency{ require(msg.sender==emergency); _;}
    
    /** @dev Constructor. Set the address and the time to process.
     *  @param _emergency Address which can withdraw at any time.
     *  @param _delay The time to process a transaction started by owner.
     */
    function TimedWithdraw(address _emergency, uint _delay) {
        owner=msg.sender;
        emergency=_emergency;
        delay=_delay;
    }
    
    /** Execute a call to recipient sending amount wei.
     *  @param _recipient Address of the recipient.
     *  @param _amount Amount to send in wei.
     *  @param _transactionData Binary data to specify the function to be called and the argument for more info see Ethereum ABI.
     */
    function execute(address _recipient, uint _amount, bytes _transactionData) onlyEmergency {
         if (!_recipient.call.value(_amount)(_transactionData))
                throw;
    }
    
    /** Execute a call to recipient sending amount wei.
     *  @param _recipient Address of the recipient.
     *  @param _amount Amount to send in wei.
     *  @param _transactionData Binary data to specify the function to be called and the argument for more info see Ethereum ABI.
     */
    function prepare(address _recipient, uint _amount, bytes _transactionData) onlyOwner {
        transactions.push(Transaction({
            recipient: _recipient,
            amount: _amount,
            transactionData: _transactionData,
            timeReady: now + delay,
            executed: false
        }));
        TransactionPrepared();
    }
    
    /** Execute a transaction which has been prepared.
     *  @param _transactionID ID of the transaction to execute.
     */
    function executePrepared(uint _transactionID) onlyOwner {
        Transaction transaction=transactions[_transactionID];
        require(transaction.timeReady<=now);
        require(!transaction.executed);
        
        
        transaction.executed=true;
        if (!transaction.recipient.call.value(transaction.amount)(transaction.transactionData))
                throw;
    }

}
