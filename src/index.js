const { ethers } = require("ethers");
const fs = require("fs");

const createCsvWriter = require("csv-writer").createObjectCsvWriter;
const abi = require("../abi/daov2logic.json");

const contractAddr = "0x6f3E6272A167e8AcCb32072d08E0957F9c79223d";
const rpc = "<INSERT RPC HERE>";
const provider = new ethers.providers.JsonRpcProvider(rpc);
const contract = new ethers.Contract(contractAddr, abi, provider);

const startPropNum = 280;
const numProposals = 20;
const proposals = [];

async function getData() {
  for (let i = startPropNum; i > startPropNum - numProposals; i--) {
    const proposalData = await contract.proposals(i);
    proposals.push({
      id: proposalData.id.toString(),
      proposer: proposalData.proposer.toString(),
      proposalThreshold: proposalData.proposalThreshold.toString(),
      quorumVotes: proposalData.quorumVotes.toString(),
      forVotes: proposalData.forVotes.toString(),
      againstVotes: proposalData.againstVotes.toString(),
      abstainVotes: proposalData.abstainVotes.toString(),
      canceled: proposalData.canceled.toString(),
      totalSupply: proposalData.totalSupply.toString(),
      uncastVotes: (
        parseInt(proposalData.totalSupply.toString()) -
        (parseInt(proposalData.forVotes.toString()) +
          parseInt(proposalData.againstVotes.toString()) +
          parseInt(proposalData.abstainVotes.toString()))
      ).toString(),
    });
  }
  console.log(proposals);

  // write CSV
  const csvWriter = createCsvWriter({
    path: "proposal_data.csv",
    header: [
      { id: "id", title: "proposal_id" },
      { id: "proposer", title: "proposer_address" },
      { id: "proposalThreshold", title: "proposal_threshold" },
      { id: "quorumVotes", title: "quorum_votes" },
      { id: "forVotes", title: "for_votes" },
      { id: "againstVotes", title: "against_votes" },
      { id: "abstainVotes", title: "abstain_votes" },
      { id: "canceled", title: "canceled" },
      { id: "totalSupply", title: "total_supply" },
      { id: "uncastVotes", title: "uncast_votes" },
    ],
  });
  csvWriter
    .writeRecords(proposals)
    .then(() => console.log("Proposal data written to CSV file"))
    .catch((error) =>
      console.log(`Error writing proposal data to CSV file: ${error}`)
    );
}
getData();
