package main

import (
	"net/http"
	"log"
)

func main() {
	http.HandleFunc("/foo", func(w http.ResponseWriter, r *http.Request) {
		log.Println(r.Header)
		w.Write([]byte("hello world\n"))
	})

	log.Println("listening 19000")
	http.ListenAndServe(":19000", nil)
	return
}