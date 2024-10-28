// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const VehicleModule = buildModule("VehicleModule", (m) => {


  const vehicle = m.contract("VehicleReg");

  return { vehicle };
});

export default VehicleModule;
