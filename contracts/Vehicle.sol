// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract VehicleReg {
    address public owner;

    enum Status {
        None,
        Created,
        Transferred,
        Done
    }

    struct Vehicle {
        string vehicleName;
        string vehicleModel;
        Status status;
        address currentOwner;
        address[] ownershipHistory;
    }

    Vehicle[] public vehicles;

    mapping(uint256 => address) public vehicleToOwner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You're not allowed");
        _;
    }

    modifier onlyVehicleOwner(uint64 vehicleId) {
        require(
            vehicleToOwner[vehicleId] == msg.sender,
            "Only vehicle owner allowed"
        );
        _;
    }

    event VehicleDetailsAdded(string vehicleName, Status status);

    event VehicleOwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function addVehicleDetails(
        string memory _vehicleName,
        string memory _vehicleModel
    ) external onlyOwner returns (bool) {
        Vehicle memory newCar;
        newCar.vehicleName = _vehicleName;
        newCar.vehicleModel = _vehicleModel;
        newCar.status = Status.Created;
        newCar.currentOwner = msg.sender;

        vehicles.push(newCar);
        uint256 vehicleId = vehicles.length - 1;
        vehicles[vehicleId].ownershipHistory.push(msg.sender);
        vehicleToOwner[vehicleId] = msg.sender;

        emit VehicleDetailsAdded(_vehicleName, Status.Created);
        return true;
    }

    function getAllRegisteredVehicles() public view returns (Vehicle[] memory) {
        return vehicles;
    }

    function getVehicle(
        uint64 _vehicleId
    )
        external
        view
        returns (
            string memory vehicleName,
            string memory vehicleModel,
            Status status,
            address currentOwner,
            address[] memory ownershipHistory
        )
    {
        require(_vehicleId < vehicles.length, "Vehicle ID out of bounds");
        Vehicle storage singleVehicle = vehicles[_vehicleId];
        return (
            singleVehicle.vehicleName,
            singleVehicle.vehicleModel,
            singleVehicle.status,
            singleVehicle.currentOwner,
            singleVehicle.ownershipHistory
        );
    }

    function transferVehicleTo(
        uint64 _vehicleId,
        address _newOwner
    ) external onlyVehicleOwner(_vehicleId) {
        require(_newOwner != address(0), "New owner can't be zero address");

        Vehicle storage vehicle = vehicles[_vehicleId];
        address previousOwner = vehicle.currentOwner;
        vehicle.currentOwner = _newOwner;
        vehicle.status = Status.Transferred;
        vehicle.ownershipHistory.push(_newOwner);
        vehicleToOwner[_vehicleId] = _newOwner;

        emit VehicleOwnershipTransferred(previousOwner, _newOwner);
    }

    function getOwnershipHistory(
        uint64 _vehicleId
    ) external view returns (address[] memory) {
        require(_vehicleId < vehicles.length, "Vehicle ID out of bounds");
        return vehicles[_vehicleId].ownershipHistory;
    }
}
