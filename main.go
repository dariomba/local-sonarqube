package main

import (
	"io"
	"log"
	"net/http"
	"strconv"
)

func main() {
	// Hello world, the web server

	helloHandler := func(w http.ResponseWriter, req *http.Request) {
		param1 := req.URL.Query().Get("param1")
		if param1 == "" {
			io.WriteString(w, "Param 1 is missing")
			return
		}
		param2 := req.URL.Query().Get("param2")
		if param2 == "" {
			io.WriteString(w, "Param 2 is missing")
			return
		}

		sum1, err := strconv.Atoi(param1)
		if err != nil {
			io.WriteString(w, "Param 1 is not a number")
			return
		}

		sum2, err := strconv.Atoi(param2)
		if err != nil {
			io.WriteString(w, "Param 2 is not a number")
			return
		}

		io.WriteString(w, "The sum value is: "+strconv.Itoa(sum1+sum2))
	}

	http.HandleFunc("/", helloHandler)
	log.Println("Listing for requests at http://localhost:8080/")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
