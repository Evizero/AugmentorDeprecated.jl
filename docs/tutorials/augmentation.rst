Image Augmentation for Beginners
=================================

The term *data augmentation* is commonly used to describe the process
of applying label-preserving transformations on some dataset, with
the hope that their output (i.e. the newly generated observations)
bias the model towards learning better features.
Depending on the structure and semantics of the data, this is can
be a difficult problem by itself.

Images are a special class of data that have interesting some
properties in respect to their structure. For example do the
dimensions of an image (i.e. the pixel) have a spatial relationship
to each other.
Because images are such a popular and special case of data it
deserves its own sub category, which we will unsurprisingly refer
to as **image augmentation**.

The general idea is that if we want our model to generalize well,
we should try to design the learning process in such a way as to
bias the model into learning such properties.
One way to do this is via the design of the model itself, which
for example is was idea behind convolutional neural networks.

An orthogonal approach - and the focus of the rest if this tutorial
- to bias the model to learn about this information equi-variance is
by using label-preserving transformations


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

Example: MNIST Handwritten Digits
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider the following example from the MNIST database of
handwritten digits [MNIST1998]_. Our input image clearly represents
its associated label "6".
If we were to use the transformation :class:`Rotate180` in our
augmentation pipeline for the this type of images, we would end up
with the image on the right side.

.. code-block:: julia

    using MNIST
    img = grayim(MNIST.trainimage_raw(19))

+------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input: ``img``                                                                                                   | Output: ``trainsform(Rotate180(), img)``                                                                         |
+==================================================================================================================+==================================================================================================================+
| .. image:: https://cloud.githubusercontent.com/assets/10854026/17642518/228b4f42-614a-11e6-8524-543a1b2735b5.png | .. image:: https://cloud.githubusercontent.com/assets/10854026/17642519/22921a16-614a-11e6-9ac0-628d52a88dd4.png |
+------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------+

To a human, this newly transformed image clearly represents the
label "9" and not "6" like the original image did.
Augmentor, however, assumes that the output of the pipeline has the
same label as the input. That means that in this example we would
tell our model that the correct answer for the image on the right
side is "6", which is clearly undesirable for obvious reasons.

Thus, for the MNIST dataset, the transformation :class:`Rotate180`
is **not** label-preserving and should not be used for augmentation.

.. [MNIST1998] LeCun, Yan, Corinna Cortes, Christopher J.C. Burges. `"The MNIST database of handwritten digits" <http://yann.lecun.com/exdb/mnist/>`_ Website. 1998.


Example: ISIC Skin Lesions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On the order hand, the exact same transformation could very well
be label preserving for other types of images. Let us consider
a different type of data; this time from the medical domain.

The International Skin Imaging Collaboration [ISIC]_ hosts a large
collection of publicly available and labeled skin lesion images.
A subset of that data was used in 2016's ISBI challenge [ISBI2016]_
where a subtask was lesion classification.

Let's consider the following input image on the left side.
It shows a photo of a skin lesion that was taken from above.

Again applying the :class:`Rotate180` transformation on the input
image we end up with a transformed version shown on the right side.

.. code-block:: julia

    using ISICArchive
    img = get(ImageThumbnailRequest(id = "5592ac599fc3c13155a57a85"))

+------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Input: ``img``                                                                                                   | Output: ``trainsform(Rotate180(), img)``                                                                         |
+==================================================================================================================+==================================================================================================================+
| .. image:: https://cloud.githubusercontent.com/assets/10854026/17645934/6256652a-61b4-11e6-8c35-aa98d8c20043.png | .. image:: https://cloud.githubusercontent.com/assets/10854026/17645935/6272affa-61b4-11e6-9b65-447b5e29686c.png |
+------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------+

After looking at both images, one could argue that the orientation
of the camera is somewhat arbitrary as long as it points to the
lesion at an approximately orthogonal angle.
Thus, for the ISIC dataset, the transformation :class:`Rotate180`
could be considered as label-preserving and very well be tried for
augmentation. Note, however, that this does not guarantee that
it will improve the model.

.. [ISIC] https://isic-archive.com/

.. [ISBI2016] Gutman, David; Codella, Noel C. F.; Celebi, Emre; Helba, Brian; Marchetti, Michael; Mishra, Nabin; Halpern, Allan. "Skin Lesion Analysis toward Melanoma Detection: A Challenge at the International Symposium on Biomedical Imaging (ISBI) 2016, hosted by the International Skin Imaging Collaboration (ISIC)". eprint `arXiv:1605.01397 <https://arxiv.org/abs/1605.01397>`_. 2016.

