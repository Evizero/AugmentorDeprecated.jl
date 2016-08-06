Getting Started
================

This section outlines the basic steps needed to start utilizing
the Augmentor.jl package.

Overview
---------

Augmentor's design is based around three basic building-blocks in
order to provide its functionality, namely an *image source*,
a number of *image transformations*, and an *image operation pipeline*.

.. class:: ImageSource

    Functionality to access images from some data source,
    such as a directory.

    Abstract supertype for all image sources. Every subtype of
    :class:`ImageSource` must implement the read-only functions of
    the array interface. Additionally, they must fully implement the
    iterator interface so that they can be used as for-loops to
    iterate over all the stored images.

.. class:: Pipeline

    A chain or tree of (probabilistic) transformations that should be
    applied to a given image, or set of images.

    Pipelines are container objects that define what kind of
    transformations are performed and in what order. They are designed
    for convenient user interaction and provide some information on
    what is going on.

.. class:: ImageTransformation

    As the name suggests concrete subclasses define a specific
    transformation that can be applied to an image, or a set of
    images. Transformations can also be lifted into a
    :class:`Either`, which have a random probability of
    occuring, depending on the hyperparameter.

Using Augmentor.jl
-------------------

Once installed the Augmentor package can be imported just as any
other Julia package.

.. code-block:: julia

    using Augmentor

To get help on specific functionality you can either look up the
information here, or if you prefer you can make use of Julia's
native docsystem.
The following example shows how to get additional information
on :class:`DirImageSource` within Julia's REPL:

.. code-block:: julia

    ?DirImageSource

Hello World
-------------

The following code shows how to create a simple probabilistic pipeline,
which can be sampled on the fly

.. code-block:: julia

    # load an example image
    using TestImages
    img = testimage("lena")

    # create empty pipeline
    pl = LinearPipeline()

    # add transformations to pipeline
    push!(pl, FlipX(0.5)) # lifted to Either(FlipX(), NoOp()). 50% chance of occuring
    push!(pl, FlipY())    # not lifted. will always occur
    push!(pl, Resize(64,64))

    # transform example image
    img_new = transform(pl, img)

.. code-block:: none

    RGBA Images.Image with:
    data: 64x64 Array{ColorTypes.RGBA{FixedPointNumbers.UFixed{UInt8,8}},2}
    properties:
        transformations:  Flip y-axis. Resize to 64x64.
        imagedescription: <suppressed>
        spatialorder:  x y
        pixelspacing:  1 1

You can also use an :class:`ImageSource` to sample input data from

.. code-block:: julia

    # define directory as an image source
    src = DirImageSource("path/to/images/")

    # randomly sample a few images from the source
    imgs = rand(src, 5) # Vector{Image}

    # transform each image independently
    imgs_new = transform(pl, imgs)

