(ns entropy.core
  (:use [cascalog.api]
        [forma.date-time]
        [forma.postprocess.output :only (clean-probs)]
        [forma.source.gadmiso :only (gadm->iso)])
  (:require [cascalog.ops :as c]))

(def path-map
  "Map of S3 sources"
  {:static-src "s3n://pailbucket/all-static-seq/all"
   :prob-src   "s3n://pailbucket/all-prob-series"})

(defn- clean-series
  "Accepts a source with the probability series for each pixel, as
  well as the static characteristics; returns a cleaned time series by
  pixel."
  [prob-src static-src]
  (<- [?mod-h ?mod-v ?sample ?line ?gadm ?clean-series]
      (prob-src ?s-res ?mod-h ?mod-v ?sample ?line ?prob-series)
      (static-src ?s-res ?mod-h ?mod-v ?sample ?line ?vcf ?gadm _ ?hansen _)
      (clean-probs ?prob-series -9999.0 :> ?clean-series)))

(defmapcatop explode-timeseries
  "Returns a series of tuples with the string representation of the
  interval and the probability of the pixel."
  [start-date series]
  (let [init-pd (datetime->period "16" start-date)
        idx-series (map-indexed vector series)]
    (for [[idx val] idx-series]
      [(period->datetime "16" (+ idx init-pd)) val])))

(defn long-tap
  "Reshapes the probability series, aggregating the pixel
  probabilities if they exceed the threshold."
  [threshold prob-src static-src]
  (let [clean-src (clean-series prob-src static-src)]
    (<- [?iso ?gadm ?date ?total-prob]
        (clean-src ?mod-h ?mod-v ?sample ?line ?gadm ?clean-series)
        (explode-timeseries "2005-12-19" ?clean-series :> ?date ?val)
        (>= ?val threshold)
        (gadm->iso ?gadm :> ?iso)
        (c/sum ?val :> ?total-prob))))

(defn reshape-series
  "Package the long-tap query, accepts a threshold (0-100) and a path
  on S3 to save the tab-delimited textfile"
  [threshold out-path]
  (let [static-src (hfs-seqfile (:static-src path-map))
        prob-src   (hfs-seqfile (:prob-src path-map))]
    (?- (hfs-textline out-path :sinkmode :replace)
        (long-tap threshold prob-src static-src))))


