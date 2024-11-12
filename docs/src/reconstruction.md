
# Package Installation

You can install the package in any project with the following command :

- launch julia with the command `julia`
- enter the Julia package manager by typing `]` in the REPL. (the REPL should turn in blue)
- if you want to activate an environment, type : `activate .` (otherwise the package will be installed in the global environment)
- In order to add our unregistered package, type `add https://github.com/CRMSB/SEQ_BRUKER_a_MP2RAGE_CS_360`
- if you want to use the package in your script just add the following line : `using SEQ_BRUKER_a_MP2RAGE_CS_360`


# How to use the package

Follow the example in the [documentation](https://crmsb.github.io/SEQ_BRUKER_a_MP2RAGE_CS_360/dev/generated/examples/simple_reco/) 

**Steps :**
- Define the path to the bruker dataset
```julia
path_bruker = joinpath(datadir, "MP2RAGE_FULLY")
```
- Perform the reconstruction 
```julia
d = reconstruction_MP2RAGE(path_bruker; mean_NR=true)
```
- write the results in the qBIDS format
```julia
subject_name = "sub_01"
dir_path = "" # directory path where the files will be create
write_bids_MP2RAGE(d,subject_name,dir_path)
```