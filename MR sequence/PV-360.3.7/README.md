# a_MP2RAGE_CS_360 — ParaVision 360 v3.7

| | |
|:--|:--|
| **Method version** | 1.1.0 |
| **ParaVision** | PV-360.3.7 |
| **File** | `a_MP2RAGE_CS_360-1.1.0_360.3.7.PvUserBinMethod` |

## Credits

This binary was compiled for PV-360.3.7 by **Andrew Yung** (University of British Columbia), from the source code of the a_MP2RAGE_CS_360 method developed by Aurélien Trotier (CRMSB, Bordeaux). It is shared here with his agreement so that future users do not need to compile it themselves.

## Changes compared to the PV-360.3.6 version

The acquisition and reconstruction are unchanged. The only modification is an API adaptation required by PV-360.3.7:

- The call to `ATB_SetGrappaReco` was updated: in v3.7, its last input argument must be a string named exactly `"ParentDset"`.

## Notes

- No protocol file (`.PvProtocols`) is provided for v3.7 yet.
- As for the other versions, please contact us to sign the sequence transfer agreement before using this method (see the main [README](../../README.md)).
