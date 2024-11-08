export reconstruction_MP2RAGE

function reconstruction_MP2RAGE(path_bruker;mean_NR::Bool = false,paramsCS=Dict())
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
    x_approx = mean(x_approx,dims=6)
  end
  x_approx = permutedims(x_approx,(1,2,3,5,6,4))

  ## process data to extract T1 maps
  MP2 = mp2rage_comb(x_approx[:,:,:,:,:,:])

  p = params_from_seq(b)

  T1,range_T1,LUT = mp2rage_T1maps(MP2,p)

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

