export extract_slab_profile, read_RF

using KomaMRI
function read_RF(path::String)
    # Open the file in the wave folder
    data = []
    reading = false
    open(path, "r") do io
        for line in eachline(io)
            # Start reading after the XYPOINTS header
            if occursin("##XYPOINTS=", line)
                reading = true
                continue
            end
            # Stop reading at the end marker
            if reading
                if startswith(line, "##END=") || startswith(line, "##")
                    break
                end
                # Skip empty lines
                if isempty(strip(line))
                    continue
                end
                # Parse the line as two floats
                vals = split(strip(line), ",")
                if length(vals) == 2
                    push!(data, [parse(Float64, strip(vals[1])), parse(Float64, strip(vals[2]))])
                end
            end
        end
    end
    s = hcat(data...)'
    s = s[:,1] .* exp.(im .* s[:,2]/360*2*pi)
    return s
end


function extract_slab_profile(b::BrukerFile)
gH = 267.513*1e6 # rad/T/s
gHbar = gH/(2*pi) # rad/T/s

## Global Param sequence
dz = parse(Float64,b["PVM_SliceThick"])*1e-3 # m
N = parse.(Int,b["PVM_Matrix"])
PVM_GradCalConst = parse(Float64,b["PVM_GradCalConst"]) # Hz/mm
Gmax = PVM_GradCalConst*1e3 / gHbar #gmax machine (T/m)

## excitation pulse parameters "ExcPulse1" and "ExcPulse2"
exc = split(b["ExcPulse1"][2:end],",")
wave_name = exc[end][3:end-2]
Trf =  parse(Float64,exc[1]) * 1e-3# s
df = parse(Float64,exc[2])# hz
alpha = parse(Float64,exc[3])# s
Gper = parse(Float64,b["ACQ_gradient_amplitude"][1]) # percent Gmax


if wave_name == "Calculated"
  wave = b["ExcPulse1Shape"]
  @assert isnothing(wave) "Impossible to reconstruct the T1 map with slab correction\n Use a version of sequence >  or perform the reconstruction with keyword : \n reconstruction_MP2RAGE(path_bruker; slab_correction::Bool = false)`"
  wave = reshape(wave,:,2)
  wave = wave[:,1] .* exp.(im .* wave[:,2]/360*2*pi)
else
  wave = read_RF(joinpath(@__DIR__,"wave",wave_name))
end

# Calculate B1peak
B1p = alpha/180*pi /(gH * Trf * cumsum(wave)[end]/length(wave))

## B1 and gradient
# Calculate Geff from delta F RF pulse + slice thickness
Geff = df*2*pi/(dz*gH) #

# check value from Gsinc
Gsl = Gmax * Gper/100

@assert isapprox(Geff,Gsl) "Geff should be equal to Gsl for this example"

## simu slab profile
zmax = dz # m
z = range(-zmax/2, zmax/2, N[3])
rf = RF((B1p*real(wave)),Trf)
seq = Sequence([Grad(0,Trf),Grad(0,Trf),Grad(Gsl,Trf)],[rf])
sim_params = Dict{String, Any}("Δt_rf" => Trf / length(seq.RF.A[1]))
M = simulate_slice_profile(seq; z, sim_params)

# convert magnetisation to angle (degrees)
angle_profile = asind.(abs.(M.xy))
return angle_profile
end

