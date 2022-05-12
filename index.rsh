'reach 0.1';

const User = {
    ...hasRandom,
    ...hasConsoleLogger,
    donationAmt:UInt,
    getContractStatus: Fun([], Bool),
    showTotalFunds: Fun([UInt],Null),
    projectVote:UInt,
    informTimeOut:Fun([],Null),
    logFromBackend:Fun([UInt],Null),
    logFromBackend2:Fun([Object({
        road: UInt, 
        school: UInt, 
        status: Bool,
        totalFunds:UInt,
    })],Null),
    logFromBackend3:Fun([Tuple(UInt,UInt,UInt)],Null),
    informUserOfFundsShare:Fun([UInt,UInt,UInt],Null)
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

    //create Participant interfaces for the two projects if.e Road and school,these two 
    //accounts are where the funds will be transfered
    // const School = Participant('School', {})
    // const Road = Participant('Road', {})

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
        // .timeout(relativeTime(5), () => closeTo(Kip,() => {}))
    commit();

    //Prince Step
    Prince.only(()=> {
        const donationAmtPrince = declassify(interact.donationAmt)
    })
    Prince.publish(donationAmtPrince)
        .pay(donationAmtPrince)
        // .timeout(relativeTime(5), () => closeTo(Prince,() => {}))
    commit();

    //add publish for the project Participant so that they are bound to an adresss and can recieve funds
    // School.only(() => {

    // })
    // School.publish()
    // commit();
    // Road.only(() => {
        
    // })
    // Road.publish()
    // commit();

    //Jazz's step
    Jazz.only(()=> {
        const donationAmtJazz = declassify(interact.donationAmt)
    })
    Jazz.publish(donationAmtJazz)
        .pay(donationAmtJazz)
        // .timeout(relativeTime(5), () => closeTo(Jazz,() => {}))
    
    //define while loop with Var and invariant declarations
    var contractDetails = {
        // contractStatus:true,
        status:true,
        school:0,
        road:0,
        totalFunds:0,
        projects:{
            school:{
                amounts:array(UInt,[0,0,0])
            },
            road:{
                amounts:array(UInt,[0,0,0])
            }
        },
        timeOut:0
    }
    invariant( balance() == (donationAmtKip + donationAmtPrince + donationAmtJazz) )
    while(contractDetails.timeOut < 1){
        commit()
         //Log information to all participants
        each([Kip,Prince,Jazz],() => {
            // interact.logFromBackend(contractDetails.timeOut)
            // interact.log()
        })
       
        //this is a kip only step
        Kip.only(() => {
            const usersVoteKip = declassify(interact.projectVote)
            //new votes
            const school_votes_kip =  usersVoteKip == 1 ? 1 : 0 
            const road_votes_kip =  usersVoteKip == 2 ? 1 : 0 
            const schoolAmountKip =  usersVoteKip == 1 ? donationAmtKip : 0 
            const roadAmountKip =  usersVoteKip == 2 ? donationAmtKip : 0
        });
        //publish kips votes
        Kip.publish(school_votes_kip,road_votes_kip,schoolAmountKip,roadAmountKip)
            // .timeout(relativeTime(5), () => closeTo(Kip,() => {}))
        commit();

        //this is a price only step
        Prince.only(() => {
            const usersVotePrince = declassify(interact.projectVote)
            //determine votes and amounts for each project for Prince
            const school_votes_prince =  usersVotePrince == 1 ? 1 : 0 
            const road_votes_prince =  usersVotePrince == 2 ? 1 : 0
            const schoolAmountPrince =  usersVotePrince == 1 ? donationAmtPrince : 0 
            const roadAmountPrince =  usersVotePrince == 2 ? donationAmtPrince : 0
        });
        Prince.publish(school_votes_prince,road_votes_prince,schoolAmountPrince,roadAmountPrince)
            // .timeout(relativeTime(5), () => closeTo(Prince,() => {}))
        commit();

        //this is a price only step
        Jazz.only(() => {
            const usersVoteJazz = declassify(interact.projectVote)
            //new votes and amounts for Jazz
            const school_votes_jazz =  usersVoteJazz == 1 ? 1 : 0 
            const road_votes_jazz =  usersVoteJazz == 2 ? 1 : 0
            const schoolAmountJazz =  usersVoteJazz == 1 ? donationAmtJazz : 0 
            const roadAmountJazz =  usersVoteJazz == 2 ? donationAmtJazz : 0
        });
        Jazz.publish(school_votes_jazz,road_votes_jazz,schoolAmountJazz,roadAmountJazz)
            // .timeout(relativeTime(5), () => closeTo(Jazz,() => {}))
        commit();

        //add publish for the project Participant so that they are bound to an adresss and can recieve funds
        // School.only(() => {

        // })
        // School.publish()
        //     .timeout(relativeTime(0),()=>{});
        // commit();
        // Road.only(() => {
            
        // })
        // Road.publish()
        //     .timeout(relativeTime(0),()=>{});
        // commit();

        //this is a kip only step
        Kip.only(() => {
            // const newContractStatus = declassify(interact.getContractStatus())
        })
        Kip.publish()
            // .timeout(relativeTime(5), () => closeTo(Kip,() => {}))

        // now update the contract details
        contractDetails = {
            ...contractDetails,
            school: contractDetails.school + school_votes_kip + school_votes_prince + school_votes_jazz,
            road: contractDetails.road + road_votes_kip + road_votes_prince + road_votes_jazz,
            totalFunds: balance(),
            projects:{
                school:{
                    amounts:array(UInt,[...contractDetails.projects.school.amounts.set(0,schoolAmountKip).set(1,schoolAmountPrince).set(2,schoolAmountJazz)])
                },
                road:{
                    amounts:array(UInt,[...contractDetails.projects.road.amounts.set(0,roadAmountKip).set(1,roadAmountPrince).set(2,roadAmountJazz)])
                }
            },
            timeOut: contractDetails.timeOut + 1
        }
        continue
    }

    //calculate project voting power *******************************************************************************************************************************
    //define while loop to get the squareroot of donated amounts

    // function that takes in a UInt and returns its square *(helper function) 
    const squareFunction = (value) => {
        return pow (value, 2, 100)
    }
    
    //function that checks if the current index is the last in order to find the square *(helper function) 
    const checkIndex = (currentIndex) => {
        //if the current index is the last index
        if(currentIndex == 1){
            return true
        }else{
            return false
        }
    }

    //calculate total amount by adding two given values *(helper function) 
    const calculateTotalAmount = (currentAmount,newAmount) => {
        return currentAmount + newAmount
    }

    //calculate newAmounts 
    const calculateNewAmounts = (currentAmount,newAmount,currentIndex) => {
        //first and the two amounts to get the total
        const calulatedTotal = calculateTotalAmount(currentAmount,newAmount)
        //check whether this is the last index in order to square according to formula
        if(checkIndex(currentIndex)){
            //this is the last index hence square the result to get the voting power
            return squareFunction(calulatedTotal)
        }else{
            //return the calculated total since this is not the last index
            return calulatedTotal
        }
    }

    //calulate project funds share
    const projectFundShare = (projectVotingPower,AllProjectVotingPower) => {
        const totalFunds = balance();
        const projectRation = (projectVotingPower * totalFunds)/AllProjectVotingPower;
        return projectRation //* totalFunds 
    }
    
    var votingIndex = {
        donationIndex:3,
        schoolVotingPower:0,
        roadVotingPower:0
    }
    invariant(votingIndex.donationIndex <= 3 && balance() == (donationAmtKip + donationAmtPrince + donationAmtJazz))
    while(votingIndex.donationIndex > 0){
        commit();
        const currentSchoolDonationAmount = contractDetails.projects.school.amounts[votingIndex.donationIndex - 1]
        const currentRoadDonationAmount = contractDetails.projects.road.amounts[votingIndex.donationIndex - 1]
        Kip.only(() => {
            
        })
        Kip.publish()

        //update the votingIndex details
        votingIndex = {
            ...votingIndex,
            donationIndex:votingIndex.donationIndex - 1,
            schoolVotingPower:calculateNewAmounts(votingIndex.schoolVotingPower,sqrt(currentSchoolDonationAmount),votingIndex.donationIndex),
            roadVotingPower:calculateNewAmounts(votingIndex.roadVotingPower,sqrt(currentRoadDonationAmount),votingIndex.donationIndex)
        }
        continue
    } 
    //now square the result to get the voting powers of the projects
    const totalVotingPower = votingIndex.schoolVotingPower + votingIndex.roadVotingPower
    //get voting powers as costants
    const schoolVotes = votingIndex.schoolVotingPower
    const roadVotes = votingIndex.roadVotingPower
    //get project funds
    const schoolProjectFunds = projectFundShare(schoolVotes,totalVotingPower)
    const roadProjectFunds = projectFundShare(roadVotes,totalVotingPower)

    // const testFunctionData = testFunction()
    each([Kip,Prince,Jazz],() => {
        const totalFunds = balance();
        interact.informUserOfFundsShare(totalFunds,schoolProjectFunds,roadProjectFunds)
    });


    //end of calculate project voting power ************************************************************************************************************************

    // transfer all tokens back to its owners for now to allow code to compile
    // ToDo : Find a way to send funds to the correct project
    transfer(donationAmtKip).to(Kip)
    transfer(donationAmtPrince).to(Prince)
    transfer(donationAmtJazz).to(Jazz)
    //commit all the changes above
    commit()
});

