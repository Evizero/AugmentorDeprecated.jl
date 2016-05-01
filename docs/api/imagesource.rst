Image Sources
==============

Classes
--------

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

   .. attribute:: expand

      If ``true``, all the paths will be extended to absolute paths
      instead of being relative to the root directory specified by
      ``path``. It is generally recommended to set
      ``expand = false`` (default).

   .. attribute:: recursive

      If ``true``, then all the subdirectories of ``path``
      will be processed as well. That implies that if any
      subdirectory, or their subdirectories, contain any images of
      a format specified by ``formats``, then those images
      will be part of the :class:`DirImageSource`.
      Defaults to ``true``

   .. attribute:: formats

      Array of strings. Specifies which file endings should be
      considered an image. Any file of such ending will be available
      as part of the :class:`DirImageSource`

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

