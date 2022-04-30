import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
import { ask, yesno, done } from '@reach-sh/stdlib/ask.mjs'
const stdlib = loadStdlib(process.env);

//declare global variables
let contractId = null;

(async () => {
     // *************************************************************************************************************************
    //helper functions section
    const currencyFormater = (x) => stdlib.formatCurrency(x,4) // format to 4 decimal places
    const getBalance = async (userAccount) => currencyFormater(await stdlib.balanceOf(userAccount))
    const parseAtomicToStandard = (atomicUnits) => atomicUnits/1000000 // function that converts atomice units to standard

    //function that get the balance of funds payed to the contract
    const getBalanceContract = async (contractId) => currencyFormater(await stdlib.balanceOf(contractId))
    
    //function that gets address of the contract
    const getContractAddress = async (contactObj) => {
        return contactObj.getContractAddress()
    }
    // *************************************************************************************************************************
    //contract introduction section

    //add comments to show the user that the contract is starting
    console.log(".......................Quadratic Crowdfunding...................................................................")
    console.log("Starting.............................................................")

    
    // *************************************************************************************************************************
    // User definition/login section

    //i have initialized the application with three users for now as represented below
    const predefinedUserNames = ['Prince','Jazz','Kip']
    const predefinedProjects = ['School Project','Road Project']

    //ask user for their username
    const userName = await ask(
        'Enter your username',
        // name is gotten from the callback of what the user enters
        (name) => {
            //check if the given name matches predfined users
            if(predefinedUserNames.includes(name)){
                return name
            }else{
                //throw and error that the entered name is not yet registered
                throw Error(`The entered username ${name} is not yet registered`)
            }
        }
    )

    //ask the user to create or use existing account
    const createNewAccount = await ask(
        'Do you want to create a new account (on testnet)? (y/n)',
        yesno
    )

    let userAccount = null //initiate userAccount as null
    //check if user wants to create new account
    if(createNewAccount){
        //create a new test account and initialize value to 500 units
        userAccount = await stdlib.newTestAccount(stdlib.parseCurrency(1000))
    }else{
        // if the user already has an account ask the user for the account secret
        const accountSecret = await ask(
            'Enter your accounts secret',
            (x => x) // use call back to return the details entered by the user
        )
        //retrive user account from entered account secret
        userAccount = await stdlib.newAccountFromSecret(accountSecret)
    }

    // *************************************************************************************************************************
    //contract deployment/attachement section

    let ctc = null //initialize contract as null

    //determine if the user wants to deploy the contract
    const deployContract = await ask(
        'Do you want to deploy this contract? (y/n)',
        yesno
    )

    //determine action based on users respose above
    if(deployContract){
        //use the user's account to deploy the contract
        ctc = userAccount.contract(backend)
        ctc.getInfo().then((contractDetails) => {
            console.log(`The contract is deployed as = ${JSON.stringify(contractDetails)}`)
            //get contract address and set the contractID as the address
            ctc.getContractAddress().then((info) => {
                contractId = info
                console.log(`Deployed Contract's Address is ${contractId}`)
            })
        })
    }else{
        const contractDetails = await ask(
            'Please enter the contract information',
            JSON.parse
        )
        //user the provided contract information to attach user's account to the contract
        ctc = userAccount.contract(backend,contractDetails)
    }

    //ask user how much they want to donate
    const donatedAmt = await ask(
        'How much do you want to donate',
        stdlib.parseCurrency
    )

    //initialize user interact
    const interact = { ...stdlib.hasRandom }
    //add donation amout to interact
    interact.donationAmt = donatedAmt

    interact.showTotalFunds = async (totalContractBalance) => {
        const standardizedBalance = parseAtomicToStandard(totalContractBalance)
        console.log(`Total funds donated : ${standardizedBalance}`)
    }

    //get close command function
    interact.getContractStatus = async () => {
        console.log("getting closing command")
        const closeContract = await ask(
            'The contract is running.Do you want to end it?',
            yesno
        )
        if(closeContract){
            //set interact close command as 1
            return false
        }else{
            //set interact close command as 0
            return true
        }
    }

    // *************************************************************************************************************************
    // detertmine the correct part/frontend for each user
    const userParts = {
        'Prince':backend.Prince,
        'Jazz':backend.Jazz,
        'Kip':backend.Kip
    }

    // *************************************************************************************************************************
    //keep the contract alive
    interact.closeContract = 0
    //check it the current user is the one that deployed the contract
    if(userName == 'Kip'){
        
    }
    
    // *************************************************************************************************************************
    //the end
    const part = userParts[userName]
    await part(ctc, interact)

    //get user account balance at the end of the contract
    const userAccountBalance = await getBalance(userAccount)
    console.log("................................................................................................................")
    console.log(`Your account balance is ${userAccountBalance}`)
    done()
})()

