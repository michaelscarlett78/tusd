package cli

import (
	"fmt"
)

var VersionName = "mike"
var GitCommit = "0.1"
var BuildDate = "10/07/2023"

func ShowVersion() {
	fmt.Printf("Version: %s\nCommit: %s\nDate: %s\n", VersionName, GitCommit, BuildDate)
}
