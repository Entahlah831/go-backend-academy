package shared

import "time"

type LevelSummary struct {
	ID             int    `json:"id"`
	LevelNumber    int    `json:"level_number"`
	Slug           string `json:"slug"`
	Title          string `json:"title"`
	Subtitle       string `json:"subtitle"`
	EstimatedHours int    `json:"estimated_hours"`
}

type ModuleSummary struct {
	ID         string `json:"id"`
	LevelID    int    `json:"level_id"`
	OrderIndex int    `json:"order_index"`
	Slug       string `json:"slug"`
	Title      string `json:"title"`
	Summary    string `json:"summary"`
}

type LessonSummary struct {
	ID           string `json:"id"`
	ModuleID     string `json:"module_id"`
	LevelID      int    `json:"level_id"`
	OrderIndex   int    `json:"order_index"`
	Slug         string `json:"slug"`
	Title        string `json:"title"`
	Summary      string `json:"summary"`
	Difficulty   string `json:"difficulty"`
	LastVerified string `json:"last_verified"`
}

type BookmarkRecord struct {
	UserID    string    `json:"user_id"`
	ItemType  string    `json:"item_type"`
	ItemID    string    `json:"item_id"`
	Note      string    `json:"note"`
	CreatedAt time.Time `json:"created_at"`
}
