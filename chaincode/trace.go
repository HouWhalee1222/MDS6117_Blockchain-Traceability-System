package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)


// Asset for tracibility system
type Asset struct{
    // batchId  e.g. ET0001, ET0345

	// creationTime: e.g. 2022-05-04 12:46:30 (GENERATE AUTOMATICALLY)

	// type {raw_material, battery, electric_tool}
	// name e.g. lithum, copper, CR123A
	// quality {bad, medium, good, perfect}
	// description e.g. lithium of high quality!!! 
	// ownerID: e.g. materialSupplier_01
	// ownerContact: e.g. 110

	// HistoryOwner: e.g. materialSupplier_01+channelPartner_01+logisticsProvider_01
}

func (t *Asset) Init(stub shim.ChaincodeStubInterface) peer.Response{
	//Get args from the instantiation proposal
	args := stub.GetStringArgs()
	attr_count := 7

	if len(args) != attr_count {
		return shim.Error("Incorrect arguments. Expecting a key and 6 values.")
	}

	value := time.Now().Format("2006-01-02 15:04:05")
	for i := 1; i < attr_count; i++ {
		value += "&" + args[i]
	}
	value += "&" + args[5]  // HistoryOwner, recorded automatically 

	err := stub.PutState(args[0], []byte(value))
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to create asset with ID %s", args[0]))
	}
	return shim.Success(nil)
}

func (t *Asset) Invoke(stub shim.ChaincodeStubInterface) peer.Response{
	fn, args := stub.GetFunctionAndParameters()

	var result string
	var err error
	if fn == "create" {
		result, err = create(stub, args)
	} else if fn == "query" {
		result, err = query(stub, args)
	} else if fn == "transfer" {
		result, err = transfer(stub, args)
	} else if fn == "convert" {
        result, err = convert(stub, args)
    } else {
		errMsg := "Unsupported functions: " + fn
		return shim.Error(errMsg)
	}
	
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success([]byte(result))
}

func create(stub shim.ChaincodeStubInterface, args []string) (string, error) {
	attr_count := 7
	if len(args) != attr_count {
		return "", fmt.Errorf("Incorrect arguments. Expecting 7 parameters.")
	}

	value := time.Now().Format("2006-01-02 15:04:05")
	for i := 1; i < attr_count; i++ {
		value += "&" + args[i]
	}
	value += "&" + args[5]  // HistoryOwner, recorded automatically 

	err := stub.PutState(args[0], []byte(value))
	if err != nil {
		return "", fmt.Errorf("Failed to create asset: %s", args[0])
	}

	return string(value), nil
}

// BatchID
func query(stub shim.ChaincodeStubInterface, args []string) (string, error) {
	if len(args) != 1 {
		return "", fmt.Errorf("Incorrect arguments. Expecting a key, which is the ID of the asset.")
	}

	value, err := stub.GetState(args[0])
	value_string := strings.Split(string(value), "&")

	receipt := "\n================== Receipt ==================\n"
	receipt += "Query Time: " + time.Now().Format("2006-01-02 15:04:05") + "\n"
    receipt += "\nYou are trying to query the information of Asset - " + args[0] + "\n";
    receipt += "The detailed information of this asset is as follows: \n\n";
	receipt += "ID: " + args[0] + "\n"
	receipt += "CreationTime: " + value_string[0] + "\n"
	receipt += "Type: " + value_string[1] + "\n"
	receipt += "Name: " + value_string[2] + "\n"
	receipt += "Quality: " + value_string[3] + "\n"
	receipt += "Description: " + value_string[4] + "\n"
	receipt += "Owner ID: " + value_string[5] + "\n"
	receipt += "Owner Contact: " + value_string[6] + "\n"
	receipt += "HistoryOwner: " + value_string[7] + "\n"
	receipt += "\n==================== End ====================\n\n"

	if err != nil {
		return "", fmt.Errorf("Failed to query asset: %s with error: %s", args[0], err)
	}

	if value == nil {
		return "", fmt.Errorf("Asset not found: %s", args[0])
	}

	return string(receipt), nil
}

// batchID, original ownerID, new ownerID, new ownerContact
func transfer(stub shim.ChaincodeStubInterface, args []string) (string, error) {
	if len(args) != 4 {
		return "", fmt.Errorf("Incorrect arguments. Expecting 4 parameters.")
	}
	value, err := stub.GetState(args[0])
	if err != nil {
		return "", fmt.Errorf("Failed to query asset: %s with error: %s", args[0], err)
	}
	if value == nil {
		return "", fmt.Errorf("Asset not found: %s", args[0])
	}
	value_string := strings.Split(string(value), "&")
	if args[1] != value_string[5] {
		return "", fmt.Errorf("Failed to transfer asset: %s with error: %s", args[0], "Incorrect ownership")
	}
	new_value := value_string[0]
	for i := 1; i <= 4; i++ {
		new_value += "&" + value_string[i]
	}
	new_value += "&" + args[2]  // New ownership
	new_value += "&" + args[3]  // New ownerContact
	new_value += "&" + args[2] + " <-- " + value_string[7]  // New history owner
	put_err := stub.PutState(args[0], []byte(new_value))
	if put_err != nil {
		return "", fmt.Errorf("Failed to transfer asset: %s", args[0])
	}
	return string(new_value), nil
}

// BatchID, ori type, new type, new_name, new_description
func convert(stub shim.ChaincodeStubInterface, args []string) (string, error) {
	if len(args) != 5 {
		return "", fmt.Errorf("Incorrect arguments. Expecting 3 parameters.")
	}

	value, err := stub.GetState(args[0])
	if err != nil {
		return "", fmt.Errorf("Failed to query asset: %s with error: %s", args[0], err)
	}

	if value == nil {
		return "", fmt.Errorf("Asset not found: %s", args[0])
	}

	value_string := strings.Split(string(value), "&")
	if args[1] != value_string[1] {
		return "", fmt.Errorf("Failed to convert asset: %s with error: %s", args[0], "Wrong initial type")
	}

	new_value := value_string[0]
	new_value += "&" + args[2] + "&" + args[3] + "&" + value_string[3] + "&" + args[4]
	for i := 5; i <= 7; i++ {
		new_value += "&" + value_string[i]
	}

	put_err := stub.PutState(args[0], []byte(new_value))
	if put_err != nil {
		return "", fmt.Errorf("Failed to convert asset: %s", args[0])
	}
	return string(new_value), nil
}

func main(){
	if err := shim.Start(new(Asset)); err != nil {
		fmt.Printf("Error starting Asset tracibility chaincode: %s", err)
	}
}
