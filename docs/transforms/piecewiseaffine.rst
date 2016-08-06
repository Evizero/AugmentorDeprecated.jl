Piecewise Affine Transformations
=================================

.. class:: RandomDisplacement

   Distorts the given image using a randomly (uniform) generated
   :class:`DisplacementField` of the given grid size.
   This field will be streched over the given image and converted
   into a :class:`DisplacementMesh`, which in turn will morph the
   original image into a new image using piecewise affine
   transformations.

   .. attribute:: gridwidth

      The number of reference points along the horizontal dimension.

   .. attribute:: gridheight

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
      usually has to choose different :attr:`scale` for
      different grid sizes. Defaults to true.

+------------------------------------------------+-----------------------------------------------------+
| Input                                          | Output for ``RandomDisplacement(4,5)``              |
+================================================+=====================================================+
| .. image:: ../../test/refimg/testimage.png     | .. image:: ../../test/refimg/RandomDisplacement.png |
+------------------------------------------------+-----------------------------------------------------+
