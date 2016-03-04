context("hit_chance") do
    @fact typeof(Augmentor.hit_chance(0.2)) <: Bool --> true
    @fact typeof(Augmentor.hit_chance(Float32(0.2))) <: Bool --> true
    @fact typeof(Augmentor.hit_chance(Float32(1))) <: Bool --> true
    @fact typeof(Augmentor.hit_chance(rand(10,2))) <: BitArray{2} --> true
    @fact size(Augmentor.hit_chance(rand(10,2))) --> (10,2)
    @fact typeof(Augmentor.hit_chance(rand(5))) <: BitArray{1} --> true
    @fact size(Augmentor.hit_chance(rand(5))) --> (5,)
end

