using MLDataUtils
using StatsBase

# Implement functions needed for DataSubset to work
MLDataUtils.getobs(s::ImageSource, idx) = s[idx]
StatsBase.nobs(s::ImageSource) = length(s)

