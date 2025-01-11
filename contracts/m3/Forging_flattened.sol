
// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface that must be implemented by smart contracts in order to receive
 * ERC-1155 token transfers.
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC-1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC-1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.20;



/**
 * @dev Simple implementation of `IERC1155Receiver` that will allow a contract to hold ERC-1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 */
abstract contract ERC1155Holder is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// File: contracts/m3/Forging.sol


pragma solidity ^0.8.20;


interface ICrystalForge {
    function burn(address account, uint256 id, uint256 value) external;
    function mintByMinter(address account, uint256 id, uint256 amount) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
    
    // Crystal constants
    function RUBY() external view returns (uint256);
    function SAPPHIRE() external view returns (uint256);
    function EMERALD() external view returns (uint256);
    function SOLAR_GEM() external view returns (uint256);
    function OCEAN_GEM() external view returns (uint256);
    function NATURE_GEM() external view returns (uint256);
    function PRISMATIC_GEM() external view returns (uint256);
}

contract CrystalForgeLogic is ERC1155Holder {
    ICrystalForge public crystalForge;
    
    constructor(address _crystalForge) {
        crystalForge = ICrystalForge(_crystalForge);
    }

    function forge(uint256 targetGem) public {
        if (targetGem == crystalForge.SOLAR_GEM()) {
            require(
                crystalForge.balanceOf(msg.sender, crystalForge.RUBY()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.SAPPHIRE()) >= 1,
                "Requires 1 Ruby and 1 Sapphire to forge Solar Gem"
            );
            crystalForge.burn(msg.sender, crystalForge.RUBY(), 1);
            crystalForge.burn(msg.sender, crystalForge.SAPPHIRE(), 1);
        } else if (targetGem == crystalForge.OCEAN_GEM()) {
            require(
                crystalForge.balanceOf(msg.sender, crystalForge.SAPPHIRE()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.EMERALD()) >= 1,
                "Requires 1 Sapphire and 1 Emerald to forge Ocean Gem"
            );
            crystalForge.burn(msg.sender, crystalForge.SAPPHIRE(), 1);
            crystalForge.burn(msg.sender, crystalForge.EMERALD(), 1);
        } else if (targetGem == crystalForge.NATURE_GEM()) {
            require(
                crystalForge.balanceOf(msg.sender, crystalForge.RUBY()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.EMERALD()) >= 1,
                "Requires 1 Ruby and 1 Emerald to forge Nature Gem"
            );
            crystalForge.burn(msg.sender, crystalForge.RUBY(), 1);
            crystalForge.burn(msg.sender, crystalForge.EMERALD(), 1);
        } else if (targetGem == crystalForge.PRISMATIC_GEM()) {
            require(
                crystalForge.balanceOf(msg.sender, crystalForge.RUBY()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.SAPPHIRE()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.EMERALD()) >= 1,
                "Requires all three basic gems to forge Prismatic Gem"
            );
            crystalForge.burn(msg.sender, crystalForge.RUBY(), 1);
            crystalForge.burn(msg.sender, crystalForge.SAPPHIRE(), 1);
            crystalForge.burn(msg.sender, crystalForge.EMERALD(), 1);
        } else {
            revert("Invalid gem fusion target");
        }
        
        crystalForge.mintByMinter(msg.sender, targetGem, 1);
    }

    function burnCrystal(uint256 gemId, uint256 amount) public {
        require(
            gemId >= crystalForge.SOLAR_GEM() && 
            gemId <= crystalForge.PRISMATIC_GEM(), 
            "Only fused gems can be shattered"
        );
        require(
            crystalForge.balanceOf(msg.sender, gemId) >= amount,
            "Insufficient gems to shatter"
        );
        crystalForge.burn(msg.sender, gemId, amount);
    }

    function trade(uint256 fromGem, uint256 toGem) public {
        require(fromGem <= crystalForge.PRISMATIC_GEM(), "Invalid gem type");
        require(
            toGem <= crystalForge.EMERALD(), 
            "Can only trade for basic gems"
        );
        require(
            crystalForge.balanceOf(msg.sender, fromGem) >= 1,
            "No gem to trade"
        );
        
        crystalForge.burn(msg.sender, fromGem, 1);
        crystalForge.mintByMinter(msg.sender, toGem, 1);
    }
}