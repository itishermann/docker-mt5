package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"
	"strings"
)

func replaceText(folderPath, originalText, replacingText string) error {
	files, err := ioutil.ReadDir(folderPath)
	if err != nil {
		return err
	}

	for _, file := range files {
		if file.Mode().IsRegular() {
			filePath := filepath.Join(folderPath, file.Name())
			err := replaceInFile(filePath, originalText, replacingText)
			if err != nil {
				log.Printf("Error replacing text in file %s: %s", filePath, err)
			}
		}
	}

	return nil
}

func replaceInFile(filePath, originalText, replacingText string) error {
	input, err := ioutil.ReadFile(filePath)
	if err != nil {
		return err
	}

	output := strings.ReplaceAll(string(input), originalText, replacingText)

	err = ioutil.WriteFile(filePath, []byte(output), 0)
	if err != nil {
		return err
	}

	return nil
}

func main() {
	newFunction("036", "66345421", "Dark-Venus-MT5.Apple.H1.20220529.20230528-test-03.set")
	newFunction("037", "66345425", "Dark-Venus-MT5.Apple.H1.20220529.20230528-test-04.set")
	newFunction("038", "66345430", "Dark-Venus-MT5.Amazon.H1.20220529.20230528-test-01.set")
	newFunction("039", "66345432", "Dark-Venus-MT5.Amazon.H1.20220529.20230528-test-02.set")
	newFunction("040", "66345433", "Dark-Venus-MT5.Amazon.H1.20220529.20230528-test-03.set")
	newFunction("041", "66345437", "Dark-Venus-MT5.Google.H1.20220529.20230528-test-01.set")
	newFunction("042", "66345440", "Dark-Venus-MT5.Google.H1.20220529.20230528-test-02.set")
	newFunction("043", "66345443", "Dark-Venus-MT5.Google.H1.20220529.20230528-test-03.set")
	newFunction("044", "66345453", "Dark-Venus-MT5.Google.H1.20220529.20230528-test-04.set")
	newFunction("045", "66345455", "Dark-Venus-MT5.Microsoft.H1.20220529.20230528-test-01.set")
	newFunction("046", "66345456", "Dark-Venus-MT5.Microsoft.H1.20220529.20230528-test-02.set")
	newFunction("047", "66345457", "Dark-Venus-MT5.Microsoft.H1.20220529.20230528-test-03.set")
	newFunction("048", "66345461", "Dark-Venus-MT5.Microsoft.H1.20220529.20230528-test-02.set")
	newFunction("049", "66348143", "Dark-Venus-MT5.Microsoft.H1.20220529.20230528-test-02.set")
	newFunction("050", "66348149", "Dark-Venus-MT5.Microsoft.H1.20220529.20230528-test-02.set")
	newFunction("051", "66348150", "Dark-Venus-MT5.Facebook.H1.20220601.20230531-test-01.set")
	newFunction("052", "66348153", "Dark-Venus-MT5.Facebook.H1.20220601.20230531-test-02.set")
	newFunction("053", "66348154", "Dark-Venus-MT5.USDCAD.H1.20220601.20230531-test-01.set")
	newFunction("054", "66348161", "Dark-Venus-MT5.USDCAD.H1.20220601.20230531-test-02.set")
	newFunction("055", "66348165", "Dark-Venus-MT5.USDCAD.H1.20220601.20230531-test-03.set")
	newFunction("056", "66348167", "Dark-Venus-MT5.USDCAD.H1.20220601.20230531-test-04.set")
	newFunction("057", "66348169", "Dark-Venus-MT5.USDCAD.H1.20220601.20230531-test-05.set")
	newFunction("058", "66348172", "Dark-Venus-MT5.USDCAD.H1.20220601.20230531-test-06.set")
	fmt.Println("Text replacement complete.")
}

func newFunction(containerNumber, newAccountNumber, newSettings string) {
	oldContainerNumber := "033"
	oldAccountNumber := "66312433"
	path := fmt.Sprintf("mt5-%s", containerNumber)
	err := replaceText(path, oldAccountNumber, newAccountNumber)
	if err != nil {
		log.Fatal(err)
	}
	err = replaceText(path, fmt.Sprintf("mt5-%s", oldContainerNumber), fmt.Sprintf("mt5-%s", containerNumber))
	if err != nil {
		log.Fatal(err)
	}

	oldVncPort := "30033"
	newVncPort := fmt.Sprintf("30%s", containerNumber)
	err = replaceText(path, oldVncPort, newVncPort)
	if err != nil {
		log.Fatal(err)
	}

	oldSettings := "Dark-Venus-MT5.CADJPY.H1.20220523.20230522-test-03.set"
	err = replaceText(path, oldSettings, newSettings)
	if err != nil {
		log.Fatal(err)
	}
}
