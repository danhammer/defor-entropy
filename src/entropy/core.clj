(ns entropy.core
  (:use [cascalog.api]
        [forma.postprocess.output :only (clean-probs)]
        [forma.source.gadmiso :only (gadm->iso)]))

(def path-map
  "Map of S3 sources"
  {:static-src "s3n://pailbucket/all-static-seq/all"
   :prob-src   "s3n://pailbucket/all-prob-series"})

(defn clean-series
  
  [prob-src static-src]
  (<- [?mod-h ?mod-v ?sample ?line ?lat ?lon ?gadm ?vcf ?hansen ?clean-series]
      (prob-src ?s-res ?mod-h ?mod-v ?s ?l ?prob-series)
      (static-src ?s-res ?mod-h ?mod-v ?sample ?line ?vcf ?gadm _ ?hansen _)
      (gadm->iso ?gadm :> ?iso)
      (clean-probs ?prob-series -9999.0 :> ?clean-series)))




