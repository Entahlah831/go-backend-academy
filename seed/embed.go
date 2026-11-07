// Package seed embeds the curriculum seed data (levels, lessons, exercises,
// quizzes, case studies, database scenarios, diagnostic rules) per dialect.
package seed

import "embed"

//go:embed sqlite/*.sql postgres/*.sql
var FS embed.FS
