Transformations
================

All the possible transformations that can be composed together in a
pipeline are subtypes of :class:`ImageTranformation`.

ImageTransformation
--------------------

.. class:: ImageTransformation

   Abstract supertype for all image operation. Every subtype of
   :class:`ImageTransformation` must implement the :func:`transform`
   and the :func:`multiplier` methods.

.. function:: transform(operation, image) -> Image

   Applies the transformation to the given Image or set of images.
   This function effectifely specifies the exact effect the
   operation has on the input it receives.

.. function:: multiplier(operation) -> Int

   Specifies how many unique output variations the operation can
   result in (counting the case of not being applied to the input).

Each concrete subclass defines a specific transformation that can
be applied to an image, or a set of images. Furthermore, transforms
can also be lifted into a :class:`Either`, which have a
random probability of occurring, depending on the function parameters.

Either
-------

.. class:: Either

    Allows for choosing between different ImageOperations at
    random. This is particularly useful if one for example wants
    to first either rotate the image 90 degree clockwise or
    anticlockwise (but never both) and then apply some other
    operation(s) afterwards.

    By default each specified image operation has the same
    probability of occurance. This default behaviour can be
    overwritten by specifying the parameter ``chance`` manually

+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input                                          | Example gif for output of ``Either(Rotate90(), Rotate270(), NoOp())``                                            |
+================================================+==================================================================================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: https://cloud.githubusercontent.com/assets/10854026/16313482/b01e2b2a-3979-11e6-9838-aba3cd910bb4.gif |
+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+

