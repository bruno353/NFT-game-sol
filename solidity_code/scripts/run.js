const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
  
    //Doing the specifications for each character:
    const gameContract = await gameContractFactory.deploy(
      ["He-Man", "Barksw", "Skeletor"],       // Names
      ["https://i.imgur.com/LBd65X3.jpg", // Images
      "https://i.imgur.com/vDkNQu9.jpg", 
      "https://i.imgur.com/zhSA9s5.jpg"],
      ["Warrior", "Shooter", "Wizard"], //Types
      [300, 100, 150],                    // HP values
      [70, 200, 140],                       // Attack damage values
      "The Dragon", // Boss name
      "https://i.imgur.com/lebag2q.png", // Boss image
        10500, // Boss hp
       50 // Boss attack damage
   );
    
    
     
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    txn = await gameContract.attackBoss();
    await txn.wait();
    
    txn = await gameContract.attackBoss();
    await txn.wait();

  };
  
    



  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();