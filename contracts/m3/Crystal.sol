// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract CrystalForge is ERC1155, ERC1155Burnable, Ownable {
    // Base Crystals
    uint256 public constant RUBY = 0;
    uint256 public constant SAPPHIRE = 1;
    uint256 public constant EMERALD = 2;
    
    // Forged Crystals
    uint256 public constant SOLAR_GEM = 3;      // Ruby + Sapphire
    uint256 public constant OCEAN_GEM = 4;      // Sapphire + Emerald
    uint256 public constant NATURE_GEM = 5;     // Ruby + Emerald
    uint256 public constant PRISMATIC_GEM = 6;  // All Combined

    mapping(address => mapping(uint256 => uint256)) private lastMintTimestamp;
    mapping(address => bool) public minters;

    constructor() ERC1155("ipfs://bafybeifj72jealr24gasdlolcstqtndmf7qqfdpwld6hxl2xfyphntdrkm/") Ownable(msg.sender) {
        // Initialize the contract
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Not a recognized crystal forge");
        _;
    }

    function setMinter(address minter, bool status) public onlyOwner {
        minters[minter] = status;
    }

    function mint(address account, uint256 id, uint256 amount) public {
        require(
            id <= EMERALD, 
            "Only basic crystals can be mined directly"
        );
        require(
            block.timestamp >= lastMintTimestamp[account][id] + 1 minutes,
            "Crystal formation needs 1 minute to stabilize"
        );
        
        lastMintTimestamp[account][id] = block.timestamp;
        _mint(account, id, amount, "");
    }

    function mintByMinter(
        address account,
        uint256 id,
        uint256 amount
    ) public onlyMinter {
        require(id <= PRISMATIC_GEM, "Invalid crystal type");
        _mint(account, id, amount, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public onlyMinter {
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
