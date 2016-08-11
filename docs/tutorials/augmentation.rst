Image Augmentation for Beginners
=================================


Label-preserving Transformations
---------------------------------

Before we go and train a model using some augmentation pipeline
we should invest some time to decide on an appropriate set of
transformations. Some of these transformations also have parameters
to tune. In that we we should also make sure that we settle on a
decent set of parameters for those.

What constitutes as "decent" depends on the dataset. In general we
want the augmented images to be fairly dissimilar to the originals.
However, we need to be careful that the augmented images still
visually represent the same concept (and thus label).
If a pipeline only produces output images that have this property
we call this pipeline **label-preserving**.

Consider the following example. Our input image clearly
represents its associated label "6". If we were to use the
transformation :class:`Rotate180` in our augmentation pipeline we would
end up with the image on the right side, which to a human clearly
represents the label "9". Thus for the MNIST dataset, the
transformation :class:`Rotate180` is **not** label-preserving

+------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input: ``img = grayim(MNIST.trainimage_raw(19))``                                                                | Output: ``trainsform(Rotate180(), img)``                                                                         |
+==================================================================================================================+==================================================================================================================+
| .. image:: https://cloud.githubusercontent.com/assets/10854026/17642518/228b4f42-614a-11e6-8524-543a1b2735b5.png | .. image:: https://cloud.githubusercontent.com/assets/10854026/17642519/22921a16-614a-11e6-9ac0-628d52a88dd4.png |
+------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------+


