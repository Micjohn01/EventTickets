import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MicjohnModule = buildModule("MicjohnModule", (m) => {

    const eventTickets = m.contract("EventTickets");

    return { eventTickets };
});

export default MicjohnModule;