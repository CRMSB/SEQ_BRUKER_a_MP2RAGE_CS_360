```@meta
CurrentModule = SEQ_BRUKER_a_MP2RAGE_CS_360
```

# SEQ\_BRUKER\_A\_MP2RAGE\_CS\_360

SEQ\_BRUKER\_a\_MP2RAGE\_CS\_360.jl is a Julia package that implements a reconstruction for an accelerated MP2RAGE sequence for Bruker scanner (**PV360-3.5**). 
The reconstruction is performed using MRIReco.jl 

More information and examples are available in the initial [article](https://img.shields.io/badge/doi-10.1002/mrm.27438-blue.svg)

## Raw datasets

The rawdata used in the example are stored on zenodo : https://zenodo.org/records/14046657
- One is a fully sampled acquisition (128x128x96)
- The other one is accelerated by a factor of 2
```
##$PVM_EncCSUndersampling=50
##$PVM_EncCSCenterRatio=5
```

They are used for each merge to generate the figures used in examples.

## How to give credit

If you use this package please acknowledge us by citing : https://doi.org/10.1002/mrm.27438

Additionally, if you use the sequence available in the MR sequence folder, please contact us to sign the sequence transfer agreement : aurelien.trotier@rmsb.u-bordeaux.fr