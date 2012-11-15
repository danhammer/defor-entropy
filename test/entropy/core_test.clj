(ns entropy.core-test
  (:use midje.cascalog
        [cascalog.api]
        [midje sweet]
        entropy.core))

(def sample-prob-src
  "A sample source for testing.  There are 3 pixels with GADM
identifiers in the Borneo set.  Of these, there are 2 hits at the 50%
confidence threshold"
  [["500" 28 8 0 0 [0.01 0.01 0.02 0.50 0.60 0.70 0.80]]
   ["500" 28 8 0 1 [0.01 0.01 0.02 0.02 0.60 0.70 0.80]]
   ["500" 28 8 0 2 [0.01 0.01 0.02 0.02 0.02 0.02 0.02]]
   ["500" 28 8 0 3 [0.01 0.01 0.02 0.50 0.60 0.70 0.80]]
   ["500" 28 8 0 4 [0.01 0.01 0.02 0.50 0.60 0.70 0.80]]])

(def sample-static-src
  "The static characteristics for the sample, test source.  We don't
need the fields that are place-held with the a, b, and c string
characters."
  [["500" 28 8 0 0 81 23119 1080 "b" "c"]
   ["500" 28 8 0 1 82 23119 1080 "b" "c"]
   ["500" 28 8 0 2 81 23119 1080 "b" "c"]
   ["500" 28 8 0 3 82 99999 1080 "b" "c"]
   ["500" 28 8 0 4 81 99999 1080 "b" "c"]])

(fact "Check that the long-tap query appropriately reshapes the data
in the sample sources, forming a time series in long format, grouped
by GADM ID."
  (long-tap 50 sample-prob-src sample-static-src)
  => (produces [[23119 "2006-03-06" 60]
                [23119 "2006-03-22" 140]
                [99999 "2006-03-06" 120]
                [99999 "2006-03-22" 140]]))
