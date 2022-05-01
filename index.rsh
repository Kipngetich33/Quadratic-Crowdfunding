'reach 0.1';

const User = {
    ...hasRandom,
    donationAmt:UInt,
    getContractStatus: Fun([], Bool),
    showTotalFunds: Fun([UInt],Null),
    projectVote:UInt,
    logFromBackend:Fun([UInt],Null),
    logFromBackend2:Fun([Object({
        road: UInt, 
        school: UInt, 
        status: Bool,
        totalFunds:UInt
    })],Null)
}

const projectVotes = {
    school:0,
    road:0
}

const userVotes = {
    Kip:Null,
    Prince:Null
}

export const main = Reach.App(()=> {

    //ToDo: Pull partipants from mongo database
    //but for now just create four participants Genesis, Prince,Jazz,Kip

    // //the partipant Genesis is the initializer of the contract itself
    // const Genesis = Participant('Genesis', {
    //     ...User,
    // })

    //The other three partipants are actual application users
    const Kip = Participant('Kip', {
        ...User,
    })

    const Prince = Participant('Prince', {
        ...User
    })   

    const Jazz = Participant('Jazz', {
        ...User,
    })

    // now deploy the app to devnet
    init();

    //Kip's step
    Kip.only(()=> {
        const donationAmtKip = declassify(interact.donationAmt)
    })
    Kip.publish(donationAmtKip)
        .pay(donationAmtKip)
    commit();

    //Prince Step
    Prince.only(()=> {
        const donationAmtPrince = declassify(interact.donationAmt)
    })
    Prince.publish(donationAmtPrince)
        .pay(donationAmtPrince)
    commit();
    //Jazz's step
    Jazz.only(()=> {
        const donationAmtJazz = declassify(interact.donationAmt)
    })
    Jazz.publish(donationAmtJazz)
        .pay(donationAmtJazz)
    
    //define while loop with Var and invariant declarations
    var contractDetails = {
        status:true,
        school:0,
        road:0,
        totalFunds:0
    }
    invariant( balance() == (donationAmtKip + donationAmtPrince + donationAmtJazz) )
    while(contractDetails.status){
        commit()
       
        //this is a kip only step
        Kip.only(() => {
            const usersVoteKip = declassify(interact.projectVote)
            //new votes
            const school_votes_kip =  usersVoteKip == 1 ? 1 : 0 
            const road_votes_kip =  usersVoteKip == 2 ? 1 : 0 
        });
        //publish kips votes
        Kip.publish(school_votes_kip,road_votes_kip)
        commit();

        //this is a price only step
        Prince.only(() => {
            const usersVotePrince = declassify(interact.projectVote)
            //new votes
            const school_votes_prince =  usersVotePrince == 1 ? 1 : 0 
            const road_votes_prince =  usersVotePrince == 2 ? 1 : 0
        });
        Prince.publish(school_votes_prince,road_votes_prince)
        commit();

        //this is a price only step
        Jazz.only(() => {
            const usersVoteJazz = declassify(interact.projectVote)
            //new votes
            const school_votes_jazz =  usersVoteJazz == 1 ? 1 : 0 
            const road_votes_jazz =  usersVoteJazz == 2 ? 1 : 0
        });
        Jazz.publish(school_votes_jazz,road_votes_jazz)
        commit();

        //this is a kip only step
        Kip.only(() => {
            const newContractStatus = declassify(interact.getContractStatus())
        })
        Kip.publish(newContractStatus)
        
        //now update the contract details
        contractDetails = {
            status:newContractStatus,
            school: contractDetails.school + school_votes_kip + school_votes_prince + school_votes_jazz,
            road: contractDetails.road + road_votes_kip + road_votes_prince + road_votes_jazz,
            totalFunds: balance()
        }
        continue
    }

    //Inform all the Participant of the result
    each([Kip,Prince,Jazz],() => {
        interact.logFromBackend2(contractDetails)
    })

    // transfer all tokens back to its owners for now to allow code to compile
    // ToDo : Find a way to send funds to the correct project
    transfer(donationAmtKip).to(Kip)
    transfer(donationAmtPrince).to(Prince)
    transfer(donationAmtJazz).to(Jazz)
    //commit all the changes above
    commit()
});

