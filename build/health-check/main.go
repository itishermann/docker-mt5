package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"golang.org/x/text/encoding/unicode"
	"golang.org/x/text/transform"
)

type Counter struct {
	Counter int       `json:"counter"`
	LastLog time.Time `json:"lastLog"`
}

const (
	EncodingUTF8      = "UTF-8"
	EncodingUTF16LE   = "UTF-16 LE"
	MaxWaitTime       = 20 * time.Second
	healthCheckString = "health-check alive"
)

var lastCheckedTime = time.Now()
var lastLog = time.Time{}
var lastCounter = 0

func main() {
	// Define the folder to monitor
	// const folderPath = "/path/to/your/logs" // Change this to your folder path
	//get from the environment variable
	folderPath := os.Getenv("LOG_FOLDER_PATH")
	if folderPath == "" {
		folderPath = "/root/metatrader5-monitor/MQL5/Files;../"
	}
	paths := strings.Split(folderPath, ";")
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		var err error
		var result bool
		for _, path := range paths {
			result, err = checkLatestLog(path)
			if result && err == nil {
				w.WriteHeader(http.StatusOK)
				response := Counter{
					Counter: lastCounter,
					LastLog: lastLog,
				}
				w.Header().Set("Content-Type", "application/json")
				json.NewEncoder(w).Encode(response)
				return
			}
		}
		// If the log file is not found or the entry is not recent, return 500 and the error message in the body
		http.Error(w, err.Error(), http.StatusInternalServerError)
	})

	http.HandleFunc("/i-am-alive", func(w http.ResponseWriter, r *http.Request) {
		// does the body contain the counter field that is bigger than the last counter?
		// reads the body
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			fmt.Println("Error reading body:", err)
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		// unmarshal the body
		var counter Counter
		err = json.Unmarshal(body, &counter)
		if err != nil {
			fmt.Println("Error unmarshalling body:", err)
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		// check if the counter is bigger than the last counter
		if counter.Counter > lastCounter {
			lastCounter = counter.Counter
			if lastCounter > 1000 {
				lastCounter = 0
			}
			lastCheckedTime = time.Now()
			//return 200 and the counter in the body
			response := Counter{
				Counter: lastCounter,
				LastLog: lastLog,
			}
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(response)
			return
		}
		w.WriteHeader(http.StatusBadRequest)
	})

	fmt.Println("Starting server at port 8000...")
	http.ListenAndServe(":8000", nil)
}

// checkLatestLog checks the most recent log file for the "health check-alive" entry.
func checkLatestLog(folder string) (bool, error) {
	files, err := ioutil.ReadDir(folder)
	if err != nil {
		fmt.Println("Error reading directory:", err)
		return false, fmt.Errorf("Error reading directory: %v", err)
	}

	// Filter and sort log files
	var logFiles []os.FileInfo
	for _, file := range files {
		if strings.HasSuffix(file.Name(), ".log") {
			logFiles = append(logFiles, file)
		}
	}
	sort.Slice(logFiles, func(i, j int) bool {
		return logFiles[i].ModTime().After(logFiles[j].ModTime())
	})

	// Check the most recent log file
	if len(logFiles) > 0 {
		return checkFileForHealthEntry(filepath.Join(folder, logFiles[0].Name()), EncodingUTF16LE)
	}
	if lastCheckedTime.After(time.Now().Add(-MaxWaitTime)) {
		return true, nil
	}
	return false, fmt.Errorf("No log files found in %s", folder)
}

// checkFileForHealthEntry checks a log file for the "health check-alive" entry within the last 2 minutes.
func checkFileForHealthEntry(filePath, encoding string) (bool, error) {
	var content []byte
	var err error
	var lines []string
	if encoding == EncodingUTF8 {
		content, err = ioutil.ReadFile(filePath)
		if err != nil {
			fmt.Println("Error reading file:", err)
			return false, fmt.Errorf("Error reading UFT-8 file: %v", err)
		}
		lines = strings.Split(string(content), "\n")
	} else {
		data, err := readFileUTF16(filePath)
		if err != nil {
			fmt.Println(err)
			return false, fmt.Errorf("Error reading UFT-16 LE file: %v", err)
		}
		content := strings.Replace(string(data), "\r\n", "\n", -1)
		lines = strings.Split(string(content), "\n")
	}
	occurrencies := 0
	for _, line := range lines {
		if strings.Contains(line, healthCheckString) && isEntryRecent(line) {
			occurrencies++
		}
	}
	if occurrencies > 0 {
		return true, nil
	}
	if encoding == EncodingUTF8 {
		return false, fmt.Errorf("No health check entry found in %s", filePath)
	}
	return checkFileForHealthEntry(filePath, EncodingUTF8)
}

// isEntryRecent checks if the log entry is within the last 2 minutes.
func isEntryRecent(line string) bool {
	const layout1 = "2006-01-02 15:04:05.000"
	const layout2 = "2006-01-02"
	const layout3 = "2006.01.02 15:04:05"
	parts := strings.Split(line, "\t")
	if len(parts) < 2 {
		return false
	}
	// prints current date
	t, err := time.Parse(layout3, parts[0])
	if err != nil {
		timeStr := fmt.Sprintf("%s %s", time.Now().UTC().Format(layout2), parts[0])
		t, err = time.Parse(layout1, timeStr)
		if err != nil {
			fmt.Println("Error parsing time:", err)
			return false
		}
	}
	if t.After(lastLog) {
		lastLog = t
		lastCheckedTime = time.Now()
		return true
	}
	if lastCheckedTime.After(time.Now().Add(-MaxWaitTime)) {
		return true
	}
	return false
}

func readFileUTF16(filename string) ([]byte, error) {
	// Read the file into a []byte:
	raw, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	// Make an tranformer that converts MS-Win default to UTF8:
	win16be := unicode.UTF16(unicode.BigEndian, unicode.IgnoreBOM)
	// Make a transformer that is like win16be, but abides by BOM:
	utf16bom := unicode.BOMOverride(win16be.NewDecoder())

	// Make a Reader that uses utf16bom:
	unicodeReader := transform.NewReader(bytes.NewReader(raw), utf16bom)

	// decode and print:
	decoded, err := ioutil.ReadAll(unicodeReader)
	return decoded, err
}
