package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestBasicSumHandler(t *testing.T) {
	testCases := []struct {
		name       string
		param1     string
		param2     string
		expected   string
		statusCode int
	}{
		{"ValidParams", "2", "3", "The sum value is: 5", http.StatusOK},
		{"MissingParam1", "", "3", "Param 1 is missing", http.StatusOK},
		{"MissingParam2", "2", "", "Param 2 is missing", http.StatusOK},
		{"InvalidParam1", "abc", "3", "Param 1 is not a number", http.StatusOK},
		{"InvalidParam2", "2", "xyz", "Param 2 is not a number", http.StatusOK},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/?param1="+tc.param1+"&param2="+tc.param2, nil)
			if err != nil {
				t.Fatal(err)
			}

			recorder := httptest.NewRecorder()
			handler := http.HandlerFunc(basicSumHandler)

			handler.ServeHTTP(recorder, req)

			if recorder.Code != tc.statusCode {
				t.Errorf("Expected status code %d, but got %d", tc.statusCode, recorder.Code)
			}

			if body := recorder.Body.String(); body != tc.expected {
				t.Errorf("Expected response body '%s', but got '%s'", tc.expected, body)
			}
		})
	}
}
