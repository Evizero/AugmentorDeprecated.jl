Image Operations
==============

All the possible transformations that can be composed together in a
pipeline are subtypes of :class:`ImageOperation`. Each concrete
subclass defines a specific transformation that can be applied to an
image, or a set of images. Furthermore, Operations can also be lifted
into a :class:`ProbableOperation`, which have a random probability of
occurring, depending on the function parameters.


FlipX
------

FlipY
------

