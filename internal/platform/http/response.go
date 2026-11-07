package httpplatform

import (
	"encoding/json"
	"net/http"
)

type ProblemDetail struct {
	Type      string `json:"type"`
	Title     string `json:"title"`
	Status    int    `json:"status"`
	Code      string `json:"code"`
	Detail    string `json:"detail"`
	RequestID string `json:"request_id,omitempty"`
}

func WriteJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func WriteProblem(w http.ResponseWriter, r *http.Request, status int, code, title, detail string) {
	reqID := w.Header().Get("X-Request-ID")
	if reqID == "" && r != nil {
		reqID = r.Header.Get("X-Request-ID")
	}
	w.Header().Set("Content-Type", "application/problem+json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(ProblemDetail{
		Type:      "https://gobackendacademy.local/problems/" + code,
		Title:     title,
		Status:    status,
		Code:      code,
		Detail:    detail,
		RequestID: reqID,
	})
}
