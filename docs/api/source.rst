ImageSource
============

The various image sources provide the functionality to access images
from different data sources. This section outlines the API details
of the currently available subclasses for :class:`ImageSource`

ImageSource
------------

:class:`ImageSource` is the abstract supertype for all image sources.
As such it defines all functionality that is independent of the
concrete image source.

.. function:: Base.rand(source, [n]) -> Image

   Allows to i.i.d. uniformly sample an image from the given
   datasource.

   :param ImageSource source: The concrete image source
   :param Int n: default ``1``, number of images to sample.
   :return: A randomly sampled image from the image source.

Every subtype of :class:`ImageSource` must implement the read-only
functions of the array interface. For the following functions
default implementations are provided and need not be specified by
the subtypes.

.. function:: Base.endof(source) -> Int

   :param ImageSource source: The concrete image source
   :return: The index of the last image in the image source.

.. function:: Base.getindex(source, indicies) -> Vector

   :param ImageSource source: The concrete image source
   :param Vector indicies: Vector of integers. Each element should
          be within ``1`` and ``endof(source)``, and thus denote a
          concrete image in the ImageSource.
   :return: A vector containing those images that are denoted by
            the parameter ``indicies``.

Additionally, they must fully implement the iterator interface so that
they can be used as for-loops to iterate over all the stored images.
For the following functions default implementations are provided and
need not be specified by the subtypes.

.. function:: Base.eltype(source) -> Type

   :param ImageSource source: The concrete image source
   :return: Always returns :class:`Image` unless explicitly
            overwritten.


DirImageSource
---------------

.. class:: DirImageSource

   Concrete implementation of :class:`ImageSource` for (nested)
   directories of a local filesystem. The purpose of
   :class:`DirImageSource` is to seamlessly load images from a
   directory and its subdirectories. Note that subdirectories will be
   treated as categories and their relative paths will be stored as
   metadata within the loaded image object.

   .. attribute:: path

      The directory that contains the desired images. This can also be
      just a container for subdirectories, in which the subdirectories
      contain the actual images. However, for this to work
      ``recursive`` has to be set to ``true``

   .. attribute:: files

      Vector of strings containing all image file-names found in path.
      Depending on the parameters used to create the object this
      vector may also contain the images in all the subdirectories.


.. function:: DirImageSource(path = "."; parameters...)

   :param bool hidden: default ``false``. If ``true``, all the
          hidden files within ``path`` will be processed as well.

   :param bool expand: default ``false``. If ``true``, all the
          paths will be extended to absolute paths instead of
          being relative to the root directory specified by
          ``path``. It is generally recommended to set
          ``expand = false``.

   :param bool recursive: default ``true``. If ``true``, then
          all the subdirectories of ``path`` will be processed
          as well. That implies that if any subdirectory, or
          their subdirectories, contain any images of a format
          specified by ``formats``, then those images will be
          part of the :class:`DirImageSource`.

   :param Vector formats: Array of strings. Specifies which file
          endings should be considered an image. Any file of
          such ending will be available as part of the
          :class:`DirImageSource`.

.. function:: Base.getindex(source, index) -> Image

   :param DirImageSource source: The image source bound to some
          local directory.
   :param Int index: Number denoting the single image that should
          be returned. Must be within ``1`` and ``endof(source)``
   :return: The :class:`Image` denoted by the given index

.. function:: Base.length(source) -> Int

   :param DirImageSource source: The image source bound to some
          local directory.
   :return: The total number of registered images in the image source.

.. function:: Base.start(source) -> Int

   :param DirImageSource source: The image source bound to some
          local directory.
   :return: ``1``, index of the first image

.. function:: Base.done(source, state) -> Bool

   :param DirImageSource source: The image source bound to some
          local directory.
   :param Int state: the state returned by either
          :function:`Base.start`, or :function:`Base.next`.
   :return: true, if all images have been iterated over

.. function:: Base.next(source) -> (Image, Int)

   :param DirImageSource source: The image source bound to some
          local directory.
   :return: A ``Tuple`` containing both, the image of the current
            state (i.e. index), and the state for the next iteration.

Examples
---------

.. code-block:: julia

   # create the image source by indexing the directory's content.
   # Note: this command won't actually load any images.
   src = DirImageSource("mydatadir/")

   # number of available images
   n = length(src)

   # images can be indexed like an array
   img1 = src[1]

   # loop through all images in the source
   for img in src
       println(img)
   end

