// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;



//importing the opzenzeppelin ERC721 contract:
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

//used to do console logs:
import "hardhat/console.sol";


//to get the functions of ERC721 contract, we inherits from it
contract MyEpicGame is ERC721 {
    
    //Each NFT will have this attributes:
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        string characterType; 
        uint hp;
        uint maxHp;
        uint attackDamage;
    }
    //Array to hold default data about characters
    CharacterAttributes[] defaultCharacters;
    
    //Creating the tokenID:
     using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //Mapping for tokenId => NFT:
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    //mapping for adress => tokenId:
    mapping(address => uint256) public nftHolders;
    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);



    //creating the boss for the game:
        struct BigBoss {
      string name;
      string imageURI;
      uint hp;
      uint maxHp;
      uint attackDamage;
    }

    BigBoss public bigBoss;




    //Doing a looping to saving the values of each character (there will be 3 types) and creating the boos:

    constructor( 
        string[] memory characterNames,
        string[] memory characterImageURIs,
        string[] memory characterType,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        string memory bossName, 
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
        // token name and symbol
        )

        ERC721("Masters", "HE")

        {
            for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        characterType: characterType[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);}

      //the boss:
            bigBoss = BigBoss({
          name: bossName,
          imageURI: bossImageURI,
          hp: bossHp,
          maxHp: bossHp,
          attackDamage: bossAttackDamage});
          console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);


        //increment for NFT starting with id = 1
      _tokenIds.increment();
      }

   
    

    //functions for users to mint the NFT:
    function mintCharacterNFT(uint _characterIndex) external {

        uint256 newItemId = _tokenIds.current();

        //function to mint nfts:
        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      characterType: defaultCharacters[_characterIndex].characterType,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

    //mapping who owns the NFT
    nftHolders[msg.sender] = newItemId;

    //increment the tokenID:
    _tokenIds.increment();

    //emit event
    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }



    //function to attack the dragon:
    function attackBoss() public {
  // Get the state of the player's NFT.
  uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
  CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
  console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
  console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

  //the player only can attack if it isnt dead!
  require (
    player.hp > 0,
    "Error: character must have HP to attack boss."
  );

  //the player only can attack a dragon alive!
  require (
    bigBoss.hp > 0,
    "Error: boss must have HP to attack boss."
  );

  //Player Attack Boss -turnaround to not get negative numbers(we are only working with uint) -
  if (bigBoss.hp < player.attackDamage) {
    bigBoss.hp = 0;
  } else {
    bigBoss.hp = bigBoss.hp - player.attackDamage;
  }

  //Boss Attack player-turnaround to not get negative numbers(we are only working with uint) -
  if (player.hp < bigBoss.attackDamage) {
    player.hp = 0;
  } else {
    player.hp = player.hp - bigBoss.attackDamage;
  }

  console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
  console.log("Boss attacked player. New player hp: %s\n", player.hp);

  emit AttackComplete(bigBoss.hp, player.hp);


}



  //function to see player NFT:

  function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
  // Get the tokenId of the user's character NFT
  uint256 userNftTokenId = nftHolders[msg.sender];
  // If the user has a tokenId in the map, return their character.
  if (userNftTokenId > 0) {
    return nftHolderAttributes[userNftTokenId];
  }
  // Else, return an empty character.
  else {
    CharacterAttributes memory emptyStruct;
    return emptyStruct;
   }
}



  //function to see the default characters:
  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
  return defaultCharacters;
}



  //function to see the boss:
  function getBigBoss() public view returns (BigBoss memory) {
  return bigBoss;
}




  //creating the URI function:

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strMaxHp = Strings.toString(charAttributes.maxHp);
    string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);
    

    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "',
        charAttributes.name,
        ' -- NFT #: ',
        Strings.toString(_tokenId),
        ' -- Type: ',
        charAttributes.characterType,
        '", "description": "This is an NFT that lets people play in the He-man Metaverse!", "image": "',
        charAttributes.imageURI,
        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
        strAttackDamage,'}]}'
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
}


    }
    
