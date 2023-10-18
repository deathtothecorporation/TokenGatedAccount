/* solhint-disable private-vars-leading-underscore */
/* solhint-disable func-name-mixedcase */

pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "openzeppelin/token/ERC721/ERC721.sol";
import "src/TGARegistry.sol";
import "src/TokenGatedAccount.sol";
import "./TestUtils.sol";

contract SimpleNFT is ERC721 {
    constructor()
        ERC721("SimpleNFT", "SNFT")
    {}

    function mint(address forWhom, uint id)
        public
    {
        _mint(forWhom, id);
    }
}

contract TGATests is Test {
    SimpleNFT simpleNFT;
    TestUtils testUtils;
    TGARegistry tgaRegistry;
    TokenGatedAccount tgaAccountImpl;

    function setUp() public {
        simpleNFT = new SimpleNFT();

        tgaRegistry = new TGARegistry();
        tgaAccountImpl = new TokenGatedAccount();

        testUtils = new TestUtils(tgaRegistry, tgaAccountImpl);
    }

    function test_expectedPermissions() public {
        // send a Milady to a new address `firstNFTHolder`
        address firstNFTHolder = address(uint160(10));
        payable(firstNFTHolder).transfer(100);
        simpleNFT.mint(firstNFTHolder, 0);

        // create TGA for NFT
        address payable tgaAddress = testUtils.createTGA(simpleNFT, 0);
        TokenGatedAccount tga = TokenGatedAccount(tgaAddress);
        
        // send that TGA some eth to play with
        (bool sent, ) = tgaAddress.call{value: 100}("");
        require(sent, "Failed to send Ether");

        address payable someOtherAddress = payable(address(uint160(11)));

        vm.expectRevert("Unauthorized caller");
        tga.execute{value: 1}(address(this), 1, "", 0);

        vm.startPrank(firstNFTHolder);
        console.log("tgaOwner",tga.owner());
        tga.execute{value: 1}(someOtherAddress, 1, "", 0);
        vm.stopPrank();

        // test that bonded account can act
        address payable bondedAccount = payable(address(uint160(12)));
        bondedAccount.transfer(100);

        vm.prank(firstNFTHolder);
        tga.bond(bondedAccount);
        vm.prank(bondedAccount);
        tga.execute{value:1}(someOtherAddress, 1, "", 0);

        // test that this stops working once the base NFT is send somewhere else
        vm.prank(firstNFTHolder);
        simpleNFT.transferFrom(firstNFTHolder, someOtherAddress, 0);
        vm.prank(bondedAccount);
        vm.expectRevert("Unauthorized caller");
        tga.execute{value:1}(someOtherAddress, 1, "", 0);

        // now let's rebond the account and test that it can change the bonded account itself
        vm.prank(someOtherAddress);
        tga.bond(bondedAccount);
        vm.prank(bondedAccount);
        tga.bond(someOtherAddress);
    }
}