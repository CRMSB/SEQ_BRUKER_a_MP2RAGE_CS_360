export reconstruction_MP2RAGE, params_from_seq

"""
    reconstruction_MP2RAGE(path_bruker::String; mean_NR::Bool = false, paramsCS::Dict = Dict())

Reconstructs MP2RAGE MRI data from a specified Bruker file path, returning images and T1 maps.

# Arguments
- `path_bruker::String`: Path to the Bruker file containing MRI acquisition data.
- `mean_NR::Bool`: If `true`, calculates the mean of the reconstructed data accross the repetition (default: `false`).
- `paramsCS::Dict`: Optional dictionary for customizing reconstruction parameters. These values override the default parameter dictionary (`params`).
- `slab_correction::Bool`: If `true`, applies slab correction to the T1 map reconstruction (default: `false`).

# Returns
A dictionary with the following key-value pairs:
- `"im_reco"`: Reconstructed MP2RAGE image array, permuted to match the expected order (x,y,z,number of Channel, Number of repetition)
- `"MP2RAGE"`: Combined MP2RAGE image data.
- `"T1map"`: Calculated T1 map from MP2RAGE images.
- `"params_reco"`: Dictionary of parameters used for reconstruction.
- `"params_MP2RAGE"`: Sequence parameters derived from the Bruker file.
- `"params_prot"`: Protocol parameters extracted from the Bruker file.
- `"LUT"`: Lookup table with T1 range and associated values.

# Description
The function performs the following steps:
1. Reads acquisition data from the Bruker file at `path_bruker`.
2. Constructs calibration data using an ESPIRiT sensitivity map from low-resolution data.
3. Sets reconstruction parameters, allowing for custom parameters specified in `paramsCS`.
4. Reconstructs the MP2RAGE image data and optionally averages across repeated measurements.
5. Permutes the resulting array dimensions for compatibility.
6. Extracts T1 maps from MP2RAGE images and constructs a lookup table (`LUT`).

# Example
```julia
d = reconstruction_MP2RAGE("path/to/bruker_data", mean_NR = true, paramsCS = Dict(:iterations => 5))
println(d["T1map"])
```

"""

function reconstruction_MP2RAGE(path_bruker;mean_NR::Bool = false, paramsCS=Dict(), slab_correction::Bool = false)
  b = BrukerFile(path_bruker)
  raw = RawAcquisitionData_MP2RAGE(b)
  acq = AcquisitionData(raw,OffsetBruker=true)

  ncalib = minimum(parse.(Int,b["PVM_EncCSNumRef"]))

  if ncalib > 24
    ncalib = 24
  end
  sens_fully = espirit(acq,eigThresh_2 = 0,(6,6,6),ncalib);
  
  params = Dict{Symbol, Any}()
  params[:reco] = "multiCoil"
  params[:reconSize] = acq.encodingSize
  params[:senseMaps] = sens_fully
  params[:iterations] = 1

  params = merge(params,paramsCS)

  x_approx = reconstruction(acq, params).data
  
  if mean_NR
    x_approx = mean(x_approx,dims=6) # average accross repetition
  end
  x_approx = permutedims(x_approx,(1,2,3,5,6,4)) # permute to put contrast in last dimension
  x_approx = x_approx[:,:,:,1,:,:] # remove coil dimension

  ## process data to extract T1 maps
  MP2 = mp2rage_comb(x_approx)

  p = params_from_seq(b)
  if slab_correction
    @info "Slab correction activated"
    angle_profile = extract_slab_profile(b)

    p_corr=deepcopy(p)
    T1 = similar(MP2)
    LUT = []
    range_T1 = []
    for i=1:size(MP2,3)
      p_corr.α₁ = angle_profile[i]
      p_corr.α₂ = angle_profile[i] ./ p.α₁ .* p.α₂

      T1[:,:,i,:],range_T1_tmp,LUT_tmp = SEQ_BRUKER_a_MP2RAGE_CS_360.mp2rage_T1maps(MP2[:,:,i,:],p_corr)
      push!(LUT,LUT_tmp)
      push!(range_T1,range_T1_tmp)
    end
    MP2,_ = QuantitativeMRI.T1maps_mp2rage(T1,p) 
  else
    T1,range_T1,LUT = mp2rage_T1maps(MP2,p)
  end
  d = Dict{Any,Any}()
  d["im_reco"] = x_approx
  d["MP2RAGE"] = MP2
  d["T1map"] = T1
  d["params_reco"] = params
  d["params_MP2RAGE"] = p
  d["params_prot"] = b
  d["LUT"] = [range_T1;;LUT]

  return d
end

"""
    params_from_seq(b::BrukerFile)

Extracts MP2RAGE sequence parameters from a Bruker file and returns them in a `ParamsMP2RAGE` structure.

# Arguments
- `b::BrukerFile`: Bruker file containing sequence parameter information.

# Returns
A `ParamsMP2RAGE` structure containing key sequence timings and settings for MP2RAGE reconstruction.
"""
function params_from_seq(b::BrukerFile)
  return ParamsMP2RAGE(
      parse(Float64,b["EffectiveTI"][1]),
      parse(Float64,b["EffectiveTI"][2]),
      parse(Float64,b["PVM_RepetitionTime"]),
      parse(Float64,b["MP2_RecoveryTime"]),
      parse(Int,b["MP2_EchoTrainLength"]),
      parse.(Float64,split(b["ExcPulse1"],", ")[3]),
      parse.(Float64,split(b["ExcPulse2"],", ")[3]) # for now only one pulse is used
  )
end

