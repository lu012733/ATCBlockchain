*/
pragma solidity ^0.4.8;

import "./base/Ownable.sol";

/// @title Token Registry - Stores metadata associated with CHR119 tokens. 
contract TokenRegistry is Ownable {

    event LogAddToken(
        address token,
        string name,
        string symbol,
        string url,
        uint8 decimals,
        bytes32 ipfsHash,
        bytes32 swarmHash
    );

    event LogRemoveToken(
        address token,
        string name,
        string symbol,
        string url,
        uint8 decimals,
        bytes32 ipfsHash,
        bytes32 swarmHash
    );

    event LogTokenNameChange(address token, string oldName, string newName);
    event LogTokenSymbolChange(address token, string oldSymbol, string newSymbol);
    event LogTokenUrlChange(address token, string oldUrl, string newUrl);
    event LogTokenIpfsHashChange(address token, bytes32 oldIpfsHash, bytes32 newIpfsHash);
    event LogTokenSwarmHashChange(address token, bytes32 oldSwarmHash, bytes32 newSwarmHash);

    mapping (address => TokenMetadata) public tokens;
    mapping (string => address) tokenBySymbol;
    mapping (string => address) tokenByName;

    address[] public tokenAddresses;

    struct TokenMetadata {
        address token;
        string name;
        string symbol;
        string url;
        uint8 decimals;
        bytes32 ipfsHash;
        bytes32 swarmHash;
    }

    modifier tokenExists(address _token) {
        if (tokens[_token].token != address(0)) {
            _;
        }
    }

    modifier tokenDoesNotExist(address _token) {
        if (tokens[_token].token == address(0)) {
            _;
        }
    }

    /// @dev Allows owner to add a new token to the registry.
    /// @param _token Address of new token.
    /// @param _name Name of new token.
    /// @param _symbol Symbol for new token.
    /// @param _url Token's project URL.
    /// @param _decimals Number of decimals, divisibility of new token.
    /// @param _ipfsHash IPFS hash of token icon.
    /// @param _swarmHash Swarm hash of token icon.
    function addToken(
        address _token,
        string _name,
        string _symbol,
        string _url,
        uint8 _decimals,
        bytes32 _ipfsHash,
        bytes32 _swarmHash)
        public
        onlyOwner
        tokenDoesNotExist(_token)
    {
        tokens[_token] = TokenMetadata({
            token: _token,
            name: _name,
            symbol: _symbol,
            url: _url,
            decimals: _decimals,
            ipfsHash: _ipfsHash,
            swarmHash: _swarmHash
        });
        tokenAddresses.push(_token);
        tokenBySymbol[_symbol] = _token;
        tokenByName[_name] = _token;
        LogAddToken(
            _token,
            _name,
            _symbol,
            _url,
            _decimals,
            _ipfsHash,
            _swarmHash
        );
    }

    /// @dev Allows owner to remove an existing token from the registry.
    /// @param _token Address of existing token.
    function removeToken(address _token)
        public
        onlyOwner
        tokenExists(_token)
    {
        for (uint i = 0; i < tokenAddresses.length; i++) {
            if (tokenAddresses[i] == _token) {
                tokenAddresses[i] = tokenAddresses[tokenAddresses.length - 1];
                tokenAddresses.length -= 1;
                break;
            }
        }
        TokenMetadata token = tokens[_token];
        LogRemoveToken(
            token.token,
            token.name,
            token.symbol,
            token.url,
            token.decimals,
            token.ipfsHash,
            token.swarmHash
        );
        delete tokenBySymbol[token.symbol];
        delete tokenByName[token.name];
        delete tokens[_token];
    }

    /// @dev Allows owner to modify an existing token's name.
    /// @param _token Address of existing token.
    /// @param _name New name.
    function setTokenName(address _token, string _name)
        public
        onlyOwner
        tokenExists(_token)
    {
        TokenMetadata token = tokens[_token];
        LogTokenNameChange(_token, token.name, _name);
        delete tokenByName[token.name];
        tokenByName[_name] = _token;
        token.name = _name;
    }

    /// @dev Allows owner to modify an existing token's symbol.
    /// @param _token Address of existing token.
    /// @param _symbol New symbol.
    function setTokenSymbol(address _token, string _symbol)
        public
        onlyOwner
        tokenExists(_token)
    {
        TokenMetadata token = tokens[_token];
        LogTokenSymbolChange(_token, token.symbol, _symbol);
        delete tokenBySymbol[token.symbol];
        tokenBySymbol[_symbol] = _token;
        token.symbol = _symbol;
    }

    /// @dev Allows owner to modify an existing token's IPFS hash.
    /// @param _token Address of existing token.
    /// @param _ipfsHash New IPFS hash.
    function setTokenIpfsHash(address _token, bytes32 _ipfsHash)
        public
        onlyOwner
        tokenExists(_token)
    {
        TokenMetadata token = tokens[_token];
        LogTokenIpfsHashChange(_token, token.ipfsHash, _ipfsHash);
        token.ipfsHash = _ipfsHash;
    }

    /// @dev Allows owner to modify an existing token's Swarm hash.
    /// @param _token Address of existing token.
    /// @param _swarmHash New Swarm hash.
    function setTokenSwarmHash(address _token, bytes32 _swarmHash)
      public
      onlyOwner
      tokenExists(_token)
    {
        TokenMetadata token = tokens[_token];
        LogTokenSwarmHashChange(_token, token.swarmHash, _swarmHash);
        token.swarmHash = _swarmHash;
    }

    /// @dev Allows owner to modify an existing token's URL.
    /// @param _token Address of existing token.
    /// @param _url New URL.
    function setTokenUrl(address _token, string _url)
        public
        onlyOwner
        tokenExists(_token)
    {
        TokenMetadata token = tokens[_token];
        LogTokenUrlChange(_token, token.url, _url);
        token.url = _url;
    }

    /*
     * Web3 call functions
     */

    /// @dev Provides a registered token's address when given the token symbol.
    /// @param _symbol Symbol of registered token.
    /// @return Token's address.
    function getTokenAddressBySymbol(string _symbol) constant returns (address tokenAddress) {
        return tokenBySymbol[_symbol];
    }

    /// @dev Provides a registered token's address when given the token name.
    /// @param _name Name of registered token.
    /// @return Token's address.
    function getTokenAddressByName(string _name) constant returns (address tokenAddress) {
        return tokenByName[_name];
    }

    /// @dev Provides a registered token's metadata, looked up by address.
    /// @param _token Address of registered token.
    /// @return Token metadata.
    function getTokenMetaData(address _token)
        constant
        returns (
            address tokenAddress,
            string name,
            string symbol,
            string url,
            uint8 decimals,
            bytes32 ipfsHash,
            bytes32 swarmHash
        )
    {
        TokenMetadata memory token = tokens[_token];
        return (
            token.token,
            token.name,
            token.symbol,
            token.url,
            token.decimals,
            token.ipfsHash,
            token.swarmHash
        );
    }

    /// @dev Provides a registered token's metadata, looked up by name.
    /// @param _name Name of registered token.
    /// @return Token metadata.
    function getTokenByName(string _name)
        constant
        returns (
            address tokenAddress,
            string name,
            string symbol,
            string url,
            uint8 decimals,
            bytes32 ipfsHash,
            bytes32 swarmHash
        )
    {
        address _token = tokenByName[_name];
        return getTokenMetaData(_token);
    }

    /// @dev Provides a registered token's metadata, looked up by symbol.
    /// @param _symbol Symbol of registered token.
    /// @return Token metadata.
    function getTokenBySymbol(string _symbol)
        constant
        returns (
            address tokenAddress,
            string name,
            string symbol,
            string url,
            uint8 decimals,
            bytes32 ipfsHash,
            bytes32 swarmHash
        )
    {
        address _token = tokenBySymbol[_symbol];
        return getTokenMetaData(_token);
    }

    /// @dev Returns an array containing all token addresses.
    /// @return Array of token addresses.
    function getTokenAddresses() constant returns (address[]) {
        return tokenAddresses;
    }
}
