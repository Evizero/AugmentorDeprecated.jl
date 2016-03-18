@testset "hit_chance" begin
    @test typeof(Augmentor.hit_chance(0.2)) <: Bool
    @test typeof(Augmentor.hit_chance(Float32(0.2))) <: Bool
    @test typeof(Augmentor.hit_chance(Float32(1))) <: Bool
    @test typeof(Augmentor.hit_chance(rand(10,2))) <: BitArray{2}
    @test size(Augmentor.hit_chance(rand(10,2))) == (10,2)
    @test typeof(Augmentor.hit_chance(rand(5))) <: BitArray{1}
    @test size(Augmentor.hit_chance(rand(5))) == (5,)
end

