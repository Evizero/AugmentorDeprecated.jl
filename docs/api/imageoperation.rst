Image Operations
==============

All the possible transformations that can be composed together in a
pipeline are subtypes of :class:`ImageOperation`.

.. class:: ImageOperation

   Abstract supertype for all image operation. Every subtype of
   :class:`ImageOperation` must implement the :func:`transform`
   and the :func:`multiplier` methods.

.. function:: transform(operation, image) -> Image

   Applies the transformation to the given Image or set of images.
   This function effectifely specifies the exact effect the
   operation has on the input it receives.

.. function:: multiplier(operation) -> Int

   Specifies how many unique output variations the operation can
   result in (counting the case of not being applied to the input).

Each concrete subclass defines a specific transformation that can
be applied to an image, or a set of images. Furthermore, operations
can also be lifted into a :class:`Either`, which have a
random probability of occurring, depending on the function parameters.

.. class:: FlipX

   Reverses the x-order of each pixel row. Another way of describing
   it would be to mirror the image on the y-axis, or to mirror the
   image horizontally.

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output                                         |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/FlipX.png         |
+------------------------------------------------+------------------------------------------------+

.. class:: FlipY

   Reverses the y-order of each pixel column. Another way of
   describing it would be to mirror the image on the x-axis, or to
   mirror the image vertically.

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output                                         |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/FlipY.png         |
+------------------------------------------------+------------------------------------------------+

.. class:: Rotate90

   Rotates the image upwards 90 degrees. This is a special case
   rotation because it can be performed very efficiently by simply
   rearranging the existing pixels. However, it is generally not the
   case that the output image will have the same size as the input
   image, which is something to be aware of.

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output                                         |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Rotate90.png      |
+------------------------------------------------+------------------------------------------------+

.. class:: Rotate180

   Rotates the image 180 degrees. This is a special case rotation
   because it can be performed very efficiently by simply rearranging
   the existing pixels. Furthermore, the output images is guaranteed
   to have the same dimensions as the input image.

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output                                         |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Rotate180.png     |
+------------------------------------------------+------------------------------------------------+

.. class:: Rotate270

   Rotates the image upwards 270 degrees, which can also be described
   as rotating the image downwards 90 degrees. This is a special case
   rotation, because it can be performed very efficiently by simply
   rearranging the existing pixels. However, it is generally not the
   case that the output image will have the same size as the input
   image, which is something to be aware of.

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output                                         |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Rotate270.png     |
+------------------------------------------------+------------------------------------------------+

.. class:: Resize

   Transforms the image into a fixed specified pixel size. This
   operation does not take any measures to preserve aspect ratio
   of the source image. Instead, the original image will simply be
   resized to the given dimensions. This is useful when one needs a
   set of images to all be of the exact same size.

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``Resize(160, 80)``                 |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Resize.png        |
+------------------------------------------------+------------------------------------------------+

.. class:: Zoom

   Multiplies the image height and image width equally by some
   constant factor. This means that the size of the output image
   depends on the size of the input image. If one wants to resize
   each dimension by a different factor, use :class:`Scale` instead.

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``Zoom(0.8)``                       |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Zoom08.png        |
+------------------------------------------------+------------------------------------------------+

.. class:: Scale

   Multiplies the image height and image width by individually specified
   constant factors. This means that the size of the output image
   depends on the size of the input image. If one wants to resize
   each dimension by the same factor, use :class:`Zoom` instead.

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``Scale(0.8, 1.2)``                 |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Scale_x.png       |
+------------------------------------------------+------------------------------------------------+

.. class:: CropRatio

   Crops out the biggest area around the center of the given image
   such that said sub-image satisfies the specified aspect ratio
   (i.e. width divided by height).

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``CropRatio(2)``                    |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/CropRatio2to1.png |
+------------------------------------------------+------------------------------------------------+

.. class:: CropSize

    Crops out the area of the specified pixel dimensions
    around the center of the given image

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``CropSize(64, 32)``                |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/CropSize.png      |
+------------------------------------------------+------------------------------------------------+

.. class:: Crop

    Crops out the area of the specified pixel dimensions starting
    at a specified position, which in turn denotes the top-left corner
    of the crop. A position of `x = 1`, and `y = 1` would mean that
    the crop is located in the top-left corner of the given image

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``Crop(45, 10, 64, 32)``            |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Crop.png          |
+------------------------------------------------+------------------------------------------------+

.. class:: RCropSize

    Crops out an area of the specified pixel dimensions
    at a randomized position of the given image

+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input                                          | Example gif for output of ``RCropSize(64, 32)``                                                                  |
+================================================+==================================================================================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: https://cloud.githubusercontent.com/assets/10854026/16313007/7cf77b18-3977-11e6-8677-7c465b18ea87.gif |
+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+

.. class:: RCropRatio

    Crops out the biggest possible area at some random position
    of the given image, such that said sub-image satisfies the
    specified aspect ratio (i.e. width divided by height).

+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input                                          | Example gif for output of ``RCropRatio(2)``                                                                      |
+================================================+==================================================================================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: https://cloud.githubusercontent.com/assets/10854026/16313006/7ceccc54-3977-11e6-9cef-e17f82f58c0f.gif |
+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+

.. class:: RandomDisplacement

   Distorts the given image using a randomly (uniform) generated
   :class:`DisplacementField` of the given grid size.
   This field will be streched over the given image and converted
   into a :class:`DisplacementMesh`, which in turn will morph the
   original image into a new image using piecewise affine
   transformations.

   .. attribute:: gridwidth

      The number of reference points along the horizontal dimension.

   .. attribute:: hidden

      The number of reference points along the vertical dimensions

   .. attribute:: scale

      The scaling factor applied to both components of all
      displacement vectors. This real number effectively controls
      the length of the vectors and as such the strength of the
      distortion. A number somewhere between 0 and 1 is usually
      the most reasonable choice. Defaults to 0.2

   .. attribute:: static_border

      If ``true``, then all reference points along the border/frame
      of the image will remain static during the transformation.
      In other words, they will remain in the same place in the
      output image as they were in the input image, an thus only
      the inner content of the image will be distorted.
      Default to true.

   .. attribute:: normalize

      If ``true``, then both components of all displacement vectors
      will be divided by the norm of the matrix representing the
      corresponding dimension. This will have the effect that the
      displacement vector will always be scaled appropriatly to the
      size of the grid. That means that if set to ``false``, one
      usually has to choose different :attribute:`scale` for
      different grid sizes. Defaults to true.

+------------------------------------------------+-----------------------------------------------------+
| Input                                          | Output for ``RandomDisplacement(4,5)``              |
+================================================+=====================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/RandomDisplacement.png |
+------------------------------------------------+-----------------------------------------------------+

.. class:: Either

    Allows for choosing between different ImageOperations at
    random. This is particularly useful if one for example wants
    to first either rotate the image 90 degree clockwise or
    anticlockwise (but never both) and then apply some other
    operation(s) afterwards.

    By default each specified image operation has the same
    probability of occurance. This default behaviour can be
    overwritten by specifying the parameter `chance` manually

+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input                                          | Example gif for output of ``Either(Rotate90(), Rotate270(), NoOp())``                                            |
+================================================+==================================================================================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: https://cloud.githubusercontent.com/assets/10854026/16313482/b01e2b2a-3979-11e6-9838-aba3cd910bb4.gif |
+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+

