# defor-entropy

A project to analyze the dispersion of tropical deforestation over time.

## Notes

This project makes use of the
[`lein-emr`](https://github.com/dpetrovics/lein-emr) project.  To
start the cluster for this project, you'll first need to install
[Leinigen](https://github.com/technomancy/leiningen) and then type the
following at the command line:

```bash
lein emr -n "emp" -t "large" -s 10 -b 0.2 -m 4 -r 2 -bs bsaconfig.xml 
```

where `bsaconfig.xml` is a configuration script, as described in the
`lein-emr` readme.  Once the cluster is properly bootstrapped and
running, you will need to run the following commands in sequence:

```bash
curl https://raw.github.com/technomancy/leiningen/preview/bin/lein > ~/bin/lein
chmod 755 ~/bin/lein

git clone git@github.com:reddmetrics/forma-clj.git
cd forma-clj
lein do compile :all, install

cd
git clone git@github.com:danhammer/defor-entropy.git
cd defor-entropy/

lein do compile :all, uberjar

screen -Lm hadoop jar /home/hadoop/defor-entropy/target/entropy-0.1.0-SNAPSHOT-standalone.jar clojure.main
```

At this point, you will be in a REPL, and can launch a command from
within any available namespace.  Specifically, if you want to restrict
the data set to pixels within Borneo, you can run the `screen-borneo`
function from within the `empirics.core` namespace. 

```clojure
(use 'entropy.core)
(in-ns 'entropy.core)

(reshape-series 50 "s3n://forma-analysis/entropy/long-form")
```


## License

Copyright © 2012 FIXME

Distributed under the Eclipse Public License, the same as Clojure.
