module SEQ_BRUKER_a_MP2RAGE_CS_360

# required module
using MRIReco
using MRIFiles
using MRICoilSensitivities
using QuantitativeMRI
using Statistics
using JSON
using NIfTI

# Write your package code here.
include("bruker_sequence.jl")
include("reconstruction.jl")
include("BIDS.jl")
end
