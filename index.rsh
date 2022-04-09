'reach 0.1';

const User = {
    getName: Fun([], UInt),
}

export const main = Reach.App(()=> {

    //ToDo: Pull partipants from mongo database
    //but for now just create four participants Genesis, Prince,Jazz,Kip

    //the partipant Genesis is the initializer of the contract itself
    const Genesis = Participant('Genesis', {
        ...User,
    })

    //The other three partipants are actual application users
    const Prince = Participant('Prince', {
        ...User,
    })

    const Jazz = Participant('Jazz', {
        ...User,
    })

    const Kip = Participant('Kip', {
        ...User,
    })

    // now deploy the app to devnet
    deploy()


});