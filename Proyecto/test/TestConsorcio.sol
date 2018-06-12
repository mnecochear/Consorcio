pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Consorcio.sol";

contract TestConsorcio {
  Consorcio consorcio = Consorcio(DeployedAddresses.Consorcio());

  // Testing the sayHi() function
  function testSaysHi() public {
    uint returnString = consorcio.sayHi();

    uint expected = 3;

    Assert.equal(returnString, expected, "Should return number 3");
  }

}
