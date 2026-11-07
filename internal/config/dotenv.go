package config

import (
	"bufio"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"strings"
)

// LoadDotEnv reads KEY=VALUE pairs from a .env file and exports them into the
// process environment. It is intentionally small and dependency-free.
//
// Rules:
//   - A missing file is not an error (returns loaded=false, err=nil), so the
//     server still runs with real environment variables or built-in defaults.
//   - Variables that already exist in the real process environment are NOT
//     overwritten. Real environment (shell, systemd, Docker) always wins.
//   - Blank lines and lines starting with '#' are ignored; an optional
//     leading "export " is accepted.
//   - Values may be wrapped in single or double quotes. For unquoted values,
//     an inline comment that starts with " #" is stripped.
func LoadDotEnv(path string) (loaded bool, err error) {
	f, err := os.Open(path)
	if err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			return false, nil
		}
		return false, fmt.Errorf("opening env file %s: %w", path, err)
	}
	defer f.Close()

	sc := bufio.NewScanner(f)
	sc.Buffer(make([]byte, 0, 64*1024), 1024*1024)
	lineNo := 0
	for sc.Scan() {
		lineNo++
		line := strings.TrimSpace(sc.Text())
		if lineNo == 1 {
			line = strings.TrimPrefix(line, "\uFEFF") // tolerate UTF-8 BOM written by some Windows editors
		}
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		line = strings.TrimPrefix(line, "export ")
		key, value, ok := strings.Cut(line, "=")
		if !ok {
			return false, fmt.Errorf("%s:%d: expected KEY=VALUE", path, lineNo)
		}
		key = strings.TrimSpace(key)
		if key == "" || strings.ContainsAny(key, " \t") {
			return false, fmt.Errorf("%s:%d: invalid variable name %q", path, lineNo, key)
		}
		value = parseDotEnvValue(strings.TrimSpace(value))
		if _, exists := os.LookupEnv(key); exists {
			continue
		}
		if err := os.Setenv(key, value); err != nil {
			return false, fmt.Errorf("%s:%d: setting %s: %w", path, lineNo, key, err)
		}
	}
	if err := sc.Err(); err != nil {
		return false, fmt.Errorf("reading env file %s: %w", path, err)
	}
	return true, nil
}

func parseDotEnvValue(v string) string {
	if len(v) >= 2 {
		first, last := v[0], v[len(v)-1]
		if (first == '"' && last == '"') || (first == '\'' && last == '\'') {
			inner := v[1 : len(v)-1]
			if first == '"' {
				inner = strings.NewReplacer(`\n`, "\n", `\"`, `"`, `\\`, `\`).Replace(inner)
			}
			return inner
		}
	}
	if i := strings.Index(v, " #"); i >= 0 {
		v = strings.TrimSpace(v[:i])
	}
	return v
}
