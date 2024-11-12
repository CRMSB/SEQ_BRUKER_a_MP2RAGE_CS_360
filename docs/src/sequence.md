# Bruker sequence and protocol

The sequence, implemented for **Bruker Paravision PV-360.3.5**, and the corresponding protocol for fully-sampled  is available in the folder  `MR sequence/PV-360.3.5`. 

## Enable compressed-sensing acquisition

Compressed-sensing implementation is available through the standard Bruker tab `Resolution/Encoding`. If you want to perform a compressed-sensing experiment with an acceleration of 2 like the one used here : acceleration factor = 50% and use a calibration size of 5%
```
##$PVM_EncCSUndersampling=50
##$PVM_EncCSCenterRatio=5
```

## Source code

Source code is available in this private directory : https://github.com/aTrotier/a_MP2RAGE_CS_360

# Raw datasets

The rawdata used in the example are stored on zenodo : https://zenodo.org/records/14046657
- One is a fully sampled acquisition (128x128x96)
- The other one is accelerated by a factor of 2
```
##$PVM_EncCSUndersampling=50
##$PVM_EncCSCenterRatio=5
```

They are used for each merge to generate the figures used in examples.