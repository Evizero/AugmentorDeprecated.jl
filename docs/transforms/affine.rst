Affine Tranformations
======================

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

   .. attribute:: width

      The width in pixel of the output image

   .. attribute:: height

      The height in pixel of the output image

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

   .. attribute:: factor

      The constant factor that should be used to scale both width
      and height of the output image

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

   .. attribute:: width

      The constant factor that should be used to scale the width of
      the output image

   .. attribute:: height

      The constant factor that should be used to scale the height of
      the output image

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``Scale(0.8, 1.2)``                 |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Scale_x.png       |
+------------------------------------------------+------------------------------------------------+

.. class:: CropRatio

   Crops out the biggest area around the center of the given image
   such that said sub-image satisfies the specified aspect ratio
   (i.e. width divided by height).

   .. attribute:: ratio

      The ratio of image height to image width that the output image
      should satisfy

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``CropRatio(2)``                    |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/CropRatio2to1.png |
+------------------------------------------------+------------------------------------------------+

.. class:: CropSize

   Crops out the area of the specified pixel dimensions
   around the center of the given image.

   .. attribute:: width

      The desired width or the cropped out sub-image in pixels

   .. attribute:: height

      The desired height or the cropped out sub-image in pixels

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``CropSize(64, 32)``                |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/CropSize.png      |
+------------------------------------------------+------------------------------------------------+

.. class:: Crop

   Crops out the area of the specified pixel dimensions starting
   at a specified position, which in turn denotes the top-left corner
   of the crop. A position of ``x = 1``, and ``y = 1`` would mean that
   the crop is located in the top-left corner of the given image

   .. attribute:: x

      The horizontal offset of the top left corner of the window
      that should be cropped out

   .. attribute:: y

      The vertical offset of the top left corner of the window
      that should be cropped out

   .. attribute:: width

      The desired width or the cropped out sub-image in pixels

   .. attribute:: height

      The desired height or the cropped out sub-image in pixels

+------------------------------------------------+------------------------------------------------+
| Input                                          | Output for ``Crop(45, 10, 64, 32)``            |
+================================================+================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/Crop.png          |
+------------------------------------------------+------------------------------------------------+

.. class:: RCropSize

   Crops out an area of the specified pixel dimensions
   at a randomized position of the given image

   .. attribute:: width

      The desired width or the cropped out sub-image in pixels

   .. attribute:: height

      The desired height or the cropped out sub-image in pixels

+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input                                          | Example gif for output of ``RCropSize(64, 32)``                                                                  |
+================================================+==================================================================================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: https://cloud.githubusercontent.com/assets/10854026/16313007/7cf77b18-3977-11e6-8677-7c465b18ea87.gif |
+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+

.. class:: RCropRatio

   Crops out the biggest possible area at some random position
   of the given image, such that said sub-image satisfies the
   specified aspect ratio (i.e. width divided by height).

   .. attribute:: ratio

      The ratio of image height to image width that the output
      image should satisfy

+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input                                          | Example gif for output of ``RCropRatio(2)``                                                                      |
+================================================+==================================================================================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: https://cloud.githubusercontent.com/assets/10854026/16313006/7ceccc54-3977-11e6-9cef-e17f82f58c0f.gif |
+------------------------------------------------+------------------------------------------------------------------------------------------------------------------+

