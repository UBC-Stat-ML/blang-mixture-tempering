Summary
-------

An example of how to run blang as part of Nextflow execution workflow. 

Usage
-----

Requires Java 8, UNIX, and git.

```
git clone https://github.com/UBC-Stat-ML/blang-mixture-tempering.git
cd blang-mixture-tempering
./nextflow run compare-PT-MCMC.nf -resume
```

More info
---------

This demonstrates at the same time how useful parallel tempering is in practice using an example from the [PPL for hacker book](https://github.com/CamDavidsonPilon/Probabilistic-Programming-and-Bayesian-Methods-for-Hackers) but using Blang instead of pyMC to do the analysis.

Here is the model: [Mixture.bl](https://github.com/UBC-Stat-ML/blangExample/blob/master/src/main/java/demo/Mixture.bl)
which is just a simple normal mixture with two components. We will run it on this [synthetic data](https://github.com/UBC-Stat-ML/blangExample/blob/master/data/mixture_data.csv) 
which is just 300 synthetic observations that look like that: 
![image](https://user-images.githubusercontent.com/3318185/35456239-a7b5f29e-0289-11e8-8cb7-f71eeb91e36e.png)

With 1 chain you get the following trace plots for the two mean parameters:
![image](https://user-images.githubusercontent.com/3318185/35456338-f05a65e8-0289-11e8-90b0-53503f68127e.png)
You can see that the chain will not be able to discover the symmetric solution of switching the two labels.

With 8 chains now:
![image](https://user-images.githubusercontent.com/3318185/35456360-0734e0a4-028a-11e8-9c68-ba78c73db7db.png)
So we see that we do switch.