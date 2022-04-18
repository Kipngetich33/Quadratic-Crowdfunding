# Quadratic Crowdfunding

---

## User Stories

- Signup/ Register as a user of the app
- Topup user account with funds
- Donate to the contract funding pool
- Register a Project
- Vote for a Project
- View funding share for projects

--- 

### Business Logic
- Initiate a contract
- Create a Participant 
- Create an account for a participant
- Attach a participant to the contract
- Accept contributions from participant
- Create Project Accounts
- Stores partipants votes for projects
- Calculate funding share for projects using participants voting power
- Transfer funds to project accounts based on calulated share 

---

## ROADMAP

### Initial implementation version = 0.0.1 (Closed)
- Predefine 3 users that will interact with the contract i.e Prince,Kip and Jazz
- DApp gets user name and compares it with prededined users 
- A user has option to create a test account with 500 units on testnet
- Any of the users can deploy the contract and the other can attach to it
- Only Kip can close the contract once all participants have donated 

### Donation implementation version = 0.0.2 (WIP)
- Allow user to donate to the pool i.e the contract
- Show the total amount donated to the pool 

### Voting implementaton version = 0.0.3 (Open)
- Predefine 2 projects that user can donate to
- Functionality to allow users vote for their favorite projects
- Show total votes for each project

### Funds share implementation version = 0.0.4 (open)
- Use votes and formula to calculate funds each project will recive
- Show the results of the share that each project will recieve

### Disburse funds implementation version = 0.0.4 (open)
- Define an account for each project
- Send the correct share amount to the project's account

### Contract life implementation version = 0.0.5 (open)
- Define at what point the contract will end and send the funds

### Complemt Version 1.0.0 (open)
- Clean up the code and add comments
- Add tests and assertions

