Working with Image Data in Julia
=================================

The `Julia language <http://julialang.org/>`_ provides a rich syntax
as well as large set of highly-optimized functionality for working
with (multi-dimensional) arrays of bit types.
Because of this, the language lends itself particularly well
to the fairly simple idea of treating images as just plain arrays.
Even though this may sound as a rather tedious low-level approach,
Julia makes it possible to still allow for powerful abstraction layers
without the loss of generality that usually comes with that.
This is accomplished with help of Julia's flexible type system and
multiple dispatch (both of which are beyond the scope of this
tutorial).

While the array-view-treatment makes working with images in Julia
very performant, it has also been source of confusion to new
community members.
This beginner's guide is an attempt to provide a step-by-step
overview of how pixel data is handled in Julia.

.. Tip::

    To get a more detailed explanation on some particular concept
    involved, please take a look at the documentation of the
    main package `Images.jl <https://github.com/timholy/Images.jl>`_


Multi-dimensional Arrays
-------------------------

To wrap our heads around Julia's array-based treatment of images,
we first need to understand what Julia arrays are and how we can
work with them.

.. note::

   This section is only intended provide a simplified and thus
   partial overview of Julia's arrays capabilities in order to gain
   some intuition about pixel data.
   For a more detailed treatment of the topic please have a look at
   the `official documentation <http://docs.julialang.org/en/latest/manual/arrays/>`_

Whenever we work with arrays in which the elements are bit types
(e.g. ``Int64``, ``Float32``, ``UInt8``, etc), we can think of the
array as a continuous block of memory. This is useful for many
different reasons, such as cache locality and BLAS interaction.

.. Tip::

   If you are interested in more general information about the
   concept of arrays, take a look at the thoughts on
   `"What is an array" <https://gist.github.com/JeffBezanson/24b9e2820262cdeb74f96b81534a4d1f>`_
   by one of the language's co-creator.

The same block of memory can be interpreted in a number of ways.
Consider the following example in which we allocate a vector
(i.e. a one dimensional array) of ``UInt8`` (i.e. bytes)
with some ordered example values ranging from 1 to 6.
We will think of this as our physical memory block, since it is
a pretty close representation.

.. code-block:: julia

    julia> memory = [0x1, 0x2, 0x3, 0x4, 0x5, 0x6]
    6-element Array{UInt8,1}:
     0x01
     0x02
     0x03
     0x04
     0x05
     0x06

The same block of memory could also be interpreted differently.
For example we could think of this as a matrix with 3 rows and
2 columns instead (or even the other way around).
The function ``reinterpret`` allows us to do just that

.. code-block:: julia

    julia> A = reinterpret(UInt8, memory, (3,2))
    3x2 Array{UInt8,2}:
     0x01  0x04
     0x02  0x05
     0x03  0x06

Note how we specified the number of rows first. This is because
the Julia language follows the `column-major convention <http://docs.julialang.org/en/latest/manual/performance-tips/#access-arrays-in-memory-order-along-columns>`_
for multi dimensional arrays. What this means can be observed when
we compare our new matrix ``A`` with the initial vector ``memory``
and look at the element layout.
Both variables are using the same underlying memory (i.e the value
``0x01`` is physically stored right next to the value ``0x02`` in our
example, while ``0x01`` and ``0x04`` are quite far apart even though
the matrix interpretation makes it look like they are neighbors;
which they are not).

.. Tip::

    A quick and dirty way to check if two variables are representing
    the same block of memory is by comparing the output of
    ``pointer(myvariable)``. Note, however, that technically this only
    tells you where a variable starts in memory and thus has its
    limitations.

This idea can also be generalized for higher dimensions. For example
we can think of this as a 3D array as well.

.. code-block:: julia

    julia> reinterpret(UInt8, memory, (3,1,2))
    3x1x2 Array{UInt8,3}:
    [:, :, 1] =
     0x01
     0x02
     0x03

    [:, :, 2] =
     0x04
     0x05
     0x06

If you take a closer look at the dimension sizes, you can see that
all we did in that example was add a new dimension of size ``1``,
while not changing the other numbers. In fact we can add any number
of practically empty dimensions.

.. code-block:: julia

    reinterpret(UInt8, memory, (3,1,1,1,2))
    3x1x1x1x2 Array{UInt8,5}:
    [:, :, 1, 1, 1] =
     0x01
     0x02
     0x03

    [:, :, 1, 1, 2] =
     0x04
     0x05
     0x06

This is a useful property to have when we are confronted with greyscale
datasets that do not have a color channel, yet we still want to work
with a library that expects the images to have one (such as MXNet).
To see a practical example please take a look at the corresponding
tutorial for :ref:`mxnet_tut`.


Vertical-Major vs Horizontal-Major
-----------------------------------

There are a number on different conventions of how to store image
data into a binary format. The first question one has to address
is the order in which the image dimensions are transcribed.

We have seen before that Julia follows the column-major convention
for its arrays, which for images would lead to the corresponding
convention of being vertical-major.
In the image domain, however, it is fairly common to store the
pixels in a horizontal-major layout. In other words,
horizontal-major means that images are stored in memory (or file)
one pixel row after the other.

**todo** discuss permute dims array


Reinterpreting Elements
------------------------

Up to this point, all we talked about was how to reinterpreting
the dimensional layout of some continuous memory block.
If you look at the examples above you will see that all the arrays
have elements of type ``UInt8``, which just means that each element
is represented by a single byte in memory.

Now that we understand how to reinterpret dimensional layout, we can
take a step further and think about reinterpreting the element types
of the array. Let us consider our original vector ``memory`` again.

.. code-block:: julia

    julia> memory = [0x1, 0x2, 0x3, 0x4, 0x5, 0x6]
    6-element Array{UInt8,1}:
     0x01
     0x02
     0x03
     0x04
     0x05
     0x06

Note how each byte is thought of as an individual element.
One thing we could do instead, is think of this memory block as
a vector of 3 ``UInt16`` elements.

.. code-block:: julia

    julia> reinterpret(UInt16, memory)
    3-element Array{UInt16,1}:
     0x0201
     0x0403
     0x0605

Pay attention to where our original bytes ended up. In contrast to
just rearranging elements as we did before, we ended up with
significantly different element values.
One may ask why it would ever be practical to reinterpret a memory
block like this. The one word answer to this is **Colors**!
As we will see in the remainder of this tutorial, it turns out to
be a very useful thing to do when your arrays represent pixel data.


Introduction to Color Models
------------------------------

As we discussed before, there are a various number of conventions
on how to store pixel data into a binary format. That is not only
true for dimension priority, but also for color information.

One way color information can differ is in the
`color model <https://en.wikipedia.org/wiki/Color_model>`_ in which
they are described in. Two famous examples for color models are *RGB*
and *HSV*. They essentially define how colors are conceptually made
up in terms of some components.
Additionally, one can decide on how many bits to use to describe
each color component. By doing so one defines the available
`color depth <https://en.wikipedia.org/wiki/Color_depth>`_.

Before we look into using the actual implementation of Julia's color
models, let us prototype our own imperfect toy model in order
to get a better understanding of what is happening under the hood.

.. code-block:: julia

    # define our toy color model
    immutable MyRGB
        r::UInt8
        b::UInt8
        g::UInt8
    end

Note how we defined our new toy color model as ``immutable``.
Because of this and the fact that all its components are
bit types (in this case ``UInt8``), any instantiation of
our new type will be represented as a continuous block of memory
as well.

We can now apply our color model to our ``memory`` vector from above,
and interpret the underlying memory as a vector of to ``MyRGB``
values instead.

.. code-block:: julia

    julia> reinterpret(MyRGB, memory)
    2-element Array{MyRGB,1}:
     MyRGB(0x01,0x02,0x03)
     MyRGB(0x04,0x05,0x06)

Similar to the ``UInt16`` example, we now group neighboring bytes
into larger units (namely ``MyRGB``). In contrast to the ``UInt16``
example we are still able to access the individual components
underneath. This simple toy color model already allows us to do a lot
of useful things. We could define functions that work on ``MyRGB``
values in a color-space appropriate fashion. We could also define
other color models and implement function to convert between them.

However, our little toy color model is not yet optimal. For example
it hard-codes a predefined color depth of 24 bit. We may have
use-cases where we need a richer color space. One thing we could do
to achieve that would be to introduce a new type in similar fashion.
Still, because they have a different range of available numbers
per channel (because they have a different amount of bits per channel),
we would have to write a lot of specialized code to be able to
appropriately handle all color models and depth.

Luckily, the creators of ``ColorTypes.jl`` went a with a more generic
strategy: Using parameterized types and **fixed point numbers**.

.. Tip::

    If you are interested in how various color models are actually
    designed and/or implemented in Julia, you can take a look at the
    `ColorTypes.jl <https://github.com/JuliaGraphics/ColorTypes.jl>`_
    package

Fixed Point Numbers
-------------------

The idea behind using fixed point numbers for each color component
is fairly simple. No matter how many bits a component is made up of,
we always want the largest possible value of the component to be equal
to ``1.0`` and the smallest possible value to be equal to ``0``.
Of course, the amount of possible intermediate numbers still depends
on the number of underlying bits in the memory, but that is not much
of an issue.

.. code-block:: julia

    julia> reinterpret(UFixed8, 0xFF)
    UFixed8(1.0)

    julia> reinterpret(UFixed16, 0xFFFF)
    UFixed16(1.0)

Not only does this allow for simple conversion between different
color depths, it also allows us to implement generic algorithms,
that are completely agnostic to the utilized color depth.

It is worth pointing out again, that we get all these goodies
without actually changing or copying the original memory block.
Remember how during this whole tutorial we have only changed the
interpretation of some underlying memory, and have not had the
need to copy any data so far.

.. Tip::

    For pixel data we are mainly interested in **unsigned** fixed
    point numbers, but there are others too. Check out the package
    `FixedPointNumbers.jl <https://github.com/JeffBezanson/FixedPointNumbers.jl>`_
    for more information on fixed point numbers in general.

Let us now leave our toy model behind and use the actual
implementation of ``RGB`` on our example vector ``memory``.
With the first command we will interpret our data as two pixels
with 8 bit per color channel, and with the second command as a
single pixel of 16 bit per color channel

.. code-block:: julia

    julia> reinterpret(RGB{UFixed8}, memory)
    2-element Array{ColorTypes.RGB{FixedPointNumbers.UFixed{UInt8,8}},1}:
     RGB{UFixed8}(0.004,0.008,0.012)
     RGB{UFixed8}(0.016,0.02,0.024)

    julia> reinterpret(RGB{UFixed16}, memory)
    1-element Array{ColorTypes.RGB{FixedPointNumbers.UFixed{UInt16,16}},1}:
     RGB{UFixed16}(0.00783,0.01567,0.02351)

Note how the values are now interpreted as floating point numbers.


Beyond continuous Memory
-------------------------

The whole theme of this tutorial was build on the premise of working
with continuous memory blocks. Starting with Julia version 0.5,
however, all these ideas can now be generalized to arrays and array
views with non-continuous elements! The implications of this are
exciting, but I am afraid they are beyond this tutorial.


