// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract GemsNFT is ERC1155 {
    uint256 public constant AMOUNT = 1;
    address private immutable _owner;
    bytes public constant DEFAULT_MESSAGE = "";
    
    mapping (address => bool) public allowedToMintDirectly;
    
    constructor() ERC1155("ipfs://bafybeifj72jealr24gasdlolcstqtndmf7qqfdpwld6hxl2xfyphntdrkm/") {
        _owner = msg.sender;
        allowedToMintDirectly[msg.sender] = true;
    }

    modifier authorizedAddressesOnly {
      require(allowedToMintDirectly[msg.sender], "GemsNFT: Unauthorized address.");
      _;
    }

    function allowToMintDirectly(address user) external {
        require(msg.sender == _owner, "GemsNFT: Unauthorized address.");
        allowedToMintDirectly[user] = true;
    }

    function mint(address minter, uint256 id) external authorizedAddressesOnly {
        _mint(minter, id, AMOUNT, DEFAULT_MESSAGE);
    }

    function burn(address burner, uint256 id) external authorizedAddressesOnly {
        _burn(burner, id, AMOUNT);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external authorizedAddressesOnly {
        _mintBatch(to, ids, amounts, "");
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/bafybeifj72jealr24gasdlolcstqtndmf7qqfdpwld6hxl2xfyphntdrkm/",
                Strings.toString(_id)
            )
        );
    }
}
