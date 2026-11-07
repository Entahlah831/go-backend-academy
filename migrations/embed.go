// Package migrations embeds the versioned SQL schema files for every supported
// dialect so the server binary can apply them without depending on the current
// working directory. File naming: <dialect>/<version>.up.sql and <version>.down.sql.
package migrations

import "embed"

//go:embed sqlite/*.sql postgres/*.sql
var FS embed.FS
