package settings

import (
	"encoding/json"
	"io/ioutil"
)

const (
	//OptimizationReportCollection name
	OptimizationReportCollection string = "OptimizationReport"

	//OptimizationReportResultCollection name
	OptimizationReportResultCollection string = "OptimizationReportResults"

	WorkingModeLoadFiles = "load_files"
)

// Settings have all settings needed to run this program
type Settings struct {
	DatabaseDSN string `json:"database_dsn"`
}

// LoadSettings ...
func LoadSettings(file string) (*Settings, error) {
	var result *Settings
	// Open our xmlFile
	buffer, err := ioutil.ReadFile(file)
	// if we os.Open returns an error then handle it
	if err != nil {
		return nil, err
	}

	err = json.Unmarshal(buffer, &result)
	return result, err
}
