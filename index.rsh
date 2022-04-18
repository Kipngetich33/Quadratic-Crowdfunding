'reach 0.1';

//define global variables
const [isBoolean, TRUE, FALSE ] = makeEnum(2);

const User = {
    ...hasRandom,
    donationAmt:UInt,
    closeContract:UInt,
    getCloseCommand: Fun([], UInt),
}

export const main = Reach.App(()=> {

    //ToDo: Pull partipants from mongo database
    //but for now just create four participants Genesis, Prince,Jazz,Kip

    // //the partipant Genesis is the initializer of the contract itself
    // const Genesis = Participant('Genesis', {
    //     ...User,
    // })

    //The other three partipants are actual application users
    const Prince = Participant('Prince', {
        ...User,
    })

    const Jazz = Participant('Jazz', {
        ...User,
    })

    const Kip = Participant('Kip', {
        ...User
    })

    // now deploy the app to devnet
    init();

    Kip.only(()=> {
        const donationAmtKip = declassify(interact.donationAmt)
        // const deadline = declassify(interact.deadline)
    })

    Kip.publish(donationAmtKip)
        .pay(donationAmtKip)
    commit()

    Prince.only(()=> {
        const donationAmtPrince = declassify(interact.donationAmt)
        // const deadline = declassify(interact.deadline)
    })

    Prince.publish(donationAmtPrince)
        .pay(donationAmtPrince)
    //commit prince's step
    commit()

    Jazz.only(()=> {
        const donationAmtJazz = declassify(interact.donationAmt)
        // const deadline = declassify(interact.deadline)
    })

    Jazz.publish(donationAmtJazz)
        .pay(donationAmtJazz)
    
    //define while loop with Var and invariant declarations
    var contractIsAlive = 0
    invariant( balance() == (donationAmtKip + donationAmtPrince + donationAmtJazz) )
    while(contractIsAlive == 0){
        //since we are within a consesus step we can commit below
        commit() // commit Jazz's step here

        //this is Kip only step
        Kip.only(() => {
            const _closeCommand = interact.getCloseCommand()
            const closeCommand = declassify(_closeCommand)
        })
        Kip.publish(closeCommand)

        // const closeCommand = declassify(interact.closeContract)

        // //check if Kip wants to close the contract
        // Kip.only(() => {
        //     if(interact.closeContract == 1){
        //         //close the contract
        //         // contractIsAlive = FALSE 
        //     }
        // })
        
        contractIsAlive = closeCommand
        //add continue in order to break the loop
        continue
    }
    
    //transfer all tokens back to its owners for now to allow code to compile
    transfer(donationAmtKip).to(Kip)
    transfer(donationAmtPrince).to(Kip)
    transfer(donationAmtJazz).to(Kip)
    //commit all the changes above
    commit()
});

