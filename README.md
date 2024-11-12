# SEQ_BRUKER_a_MP2RAGE_CS_360

| **Documentation**         | **Paper**                   | **Build Status** |
|:------------------------- |:--------------------------- | :--------------------------- |
| [![][docs-img]][docs-url] | [![][paper-img]][paper-url] | [![Build Status](https://github.com/CRMSB/SEQ_BRUKER_a_MP2RAGE_CS_360/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/CRMSB/SEQ_BRUKER_a_MP2RAGE_CS_360/actions/workflows/CI.yml?query=branch%3Amain) |



Rawdata for tests are available here : https://zenodo.org/records/14046657


---


SEQ_BRUKER_a_MP2RAGE_CS_360.jl is a Julia package that implements a reconstruction for an accelerated MP2RAGE sequence for Bruker scanner (**PV360-3.5**). 
The reconstruction is performed using MRIReco.jl 

More information and examples are available in the article [![][paper-img]][paper-url] and in the  [![][docs-img]][docs-url]

![](./docs/src/img/fig_explain.png)

## How to give credit

If you use this package please acknowledge us by citing : https://doi.org/10.1002/mrm.27438

Additionally, if you use the sequence available in the MR sequence folder, please contact us to sign the sequence transfer agreement : aurelien.trotier@rmsb.u-bordeaux.fr

## Bruker sequence and protocol

The sequence, implemented for **Bruker Paravision PV-360.3.5**, and the corresponding protocol for fully-sampled  is available in the folder  `MR sequence/PV-360.3.5`. 

Compressed-sensing implementation is available through the standard Bruker tab `Resolution/Encoding`. If you want to perform a compressed-sensing experiment with an acceleration of 2 like the one used here : acceleration factor = 50% and use a calibration size of 5%
```
##$PVM_EncCSUndersampling=50
##$PVM_EncCSCenterRatio=5
```

Source code is available in this private directory : https://github.com/aTrotier/a_MP2RAGE_CS_360

## Julia Installation

To use the code, we recommend downloading Julia version 1.10 with `juliaup`.

<details>
<summary>Windows</summary>

#### 1. Install juliaup
```
winget install julia -s msstore
```
#### 2. Add Julia 1.10.4
```
juliaup add 1.10.4
```
#### 3. Make 1.10.4 default
```
juliaup default 1.10.4
```

<!---#### Alternative
Alternatively you can download [this installer](https://julialang-s3.julialang.org/bin/winnt/x64/1.7/julia-1.9.3-win64.exe).--->

</details>


<details>
<summary>Mac</summary>

#### 1. Install juliaup
```
curl -fsSL https://install.julialang.org | sh
```
You may need to run `source ~/.bashrc` or `source ~/.bash_profile` or `source ~/.zshrc` if `juliaup` is not found after installation.

Alternatively, if `brew` is available on the system you can install juliaup with
```
brew install juliaup
```
#### 2. Add Julia 1.10.4
```
juliaup add 1.10.4
```
#### 3. Make 1.10.4 default
```
juliaup default 1.10.4
```

<!---#### Alternative
Alternatively you can download [this installer](https://julialang-s3.julialang.org/bin/mac/x64/1.7/julia-1.9.3-mac64.dmg)--->

</details>

<details>
<summary>Linux</summary>

#### 1. Install juliaup

```
curl -fsSL https://install.julialang.org | sh
```
You may need to run `source ~/.bashrc` or `source ~/.bash_profile` or `source ~/.zshrc` if `juliaup` is not found after installation.

Alternatively, use the AUR if you are on Arch Linux or `zypper` if you are on openSUSE Tumbleweed.
#### 2. Add Julia 1.10.4
```
juliaup add 1.10.4
```
#### 3. Make 1.10.4 default
```
juliaup default 1.10.4
```
</details>

## Package Installation

You can install the package in any project with the following command :

- launch julia with the command `julia`
- enter the Julia package manager by typing `]` in the REPL. (the REPL should turn in blue)
- if you want to activate an environment, type : `activate .` (otherwise the package will be installed in the global environment)
- In order to add our unregistered package, type `add https://github.com/CRMSB/SEQ_BRUKER_a_MP2RAGE_CS_360`
- if you want to use the package in your script just add the following line : `using SEQ_BRUKER_a_MP2RAGE_CS_360`

## How to use the package

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


[docs-img]: https://img.shields.io/badge/docs-latest%20release-blue.svg
[docs-url]: https://crmsb.github.io/SEQ_BRUKER_a_MP2RAGE_CS_360/dev/

[paper-img]: https://img.shields.io/badge/doi-10.1002/mrm.27438-blue.svg
[paper-url]: https://doi.org/10.1002/mrm.27438