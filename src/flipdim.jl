Base.flipdim(img::AbstractImage, dimname::ASCIIString) = shareproperties(img, flipdim(data(img), dimindex(img, dimname)))

flipx(img::AbstractImage) = flipdim(img, "x")
flipy(img::AbstractImage) = flipdim(img, "y")
flipz(img::AbstractImage) = flipdim(img, "z")

