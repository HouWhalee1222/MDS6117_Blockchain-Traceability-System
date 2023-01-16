package main

import (
	"fmt"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

// UsedCar implements a chaincode demo for trading used cars
type UsedCar struct{
}

func (t *UsedCar) Init(stub shim.ChaincodeStubInterface) peer.Response{
	//Get args from the instantiation proposal
	args := stub.GetStringArgs()
	if len(args) != 4{
		return shim.Error("Incorrect arguments. Expecting a key and three values.")
	}

	value := args[1] + "&" + args[2] + "&" + args[3]
	err := stub.PutState(args[0], []byte(value))
	if err != nil {
		return shim.Error(fmt.Sprintf("Failed to register used car with ID ", args[0]))
	}
	return shim.Success(nil)
}

func (t *UsedCar) Invoke(stub shim.ChaincodeStubInterface) peer.Response{
	fn, args := stub.GetFunctionAndParameters()

	var result string
	var err error
	if fn == "register" {
		result, err = register(stub, args)
	} else if fn == "query" {
		result, err = query(stub, args)
	} else if fn == "trade" {
		result, err = trade(stub, args)
	} else {
		errMsg := "Unsupported functions: " + fn
		return shim.Error(errMsg)
	}
	
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success([]byte(result))
}

func register(stub shim.ChaincodeStubInterface, args []string) (string, error) {
	if len(args) != 4 {
		return "", fmt.Errorf("Incorrect arguments. Expecting 4 parameters.")
	}

	value := args[1] + "&" + args[2] + "&" + args[3]
	err := stub.PutState(args[0], []byte(value))
	if err != nil {
		return "", fmt.Errorf("Failed to register used car: %s", args[0])
	}
	return value, nil
}

func query(stub shim.ChaincodeStubInterface, args []string) (string, error) {
	if len(args) != 1 {
		return "", fmt.Errorf("Incorrect arguments. Expecting a key, which is the ID of the used car.")
	}

	value, err := stub.GetState(args[0])
	if err != nil {
		return "", fmt.Errorf("Failed to query used car: %s with error: %s", args[0], err)
	}

	if value == nil {
		return "", fmt.Errorf("Used car not found: %s", args[0])
	}

	return string(value), nil
}

func trade(stub shim.ChaincodeStubInterface, args []string) (string, error) {
	if len(args) != 4 {
		return "", fmt.Errorf("Incorrect arguments. Expecting 4 parameters.")
	}

	value, err := stub.GetState(args[0])
	if err != nil {
		return "", fmt.Errorf("Failed to query used car: %s with error: %s", args[0], err)
	}

	if value == nil {
		return "", fmt.Errorf("Used car not found: %s", args[0])
	}

	value_string := strings.Split(string(value), "&")
	if args[1] != value_string[0] {
		return "", fmt.Errorf("Failed to trade used car: %s with error: %s", args[0], "no ownership")
	}

	new_value := args[2] + "&" + args[3] + "&" + value_string[2]
	put_err := stub.PutState(args[0], []byte(new_value))
	if put_err != nil {
		return "", fmt.Errorf("Failed to trade used car: %s", args[0])
	}
	return new_value, nil
}

func main(){
	if err := shim.Start(new(UsedCar)); err != nil {
		fmt.Printf("Error starting UsedCar chaincode: %s", err)
	}
}
