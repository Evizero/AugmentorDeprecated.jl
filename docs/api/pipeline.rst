Pipelines
==========

The various pipelines provide the functionality to process images
from some :class:`ImageSource` or memory using a collection of
:class:`ImageOperation`. This section outlines the API details
of the currently available subclasses for :class:`Pipeline`

Pipeline
---------

:class:`Pipeline` is the abstract supertype for all pipelines.
As such it defines all functionality that is independent of the
concrete pipeline.

.. function:: Base.eltype(pipeline) -> Type

   :param Pipeline pipeline: The concrete pipeline
   :return: Always returns :class:`ImageOperation` unless explicitly
            overwritten.

LinearPipeline
---------------

.. class:: LinearPipeline

   Subtype of :class:`Pipeline` for linear chains of operations,
   which may or may not be probabilistic (i.e. have a random chance
   for occuring). The contained :class:`ImageOperation` s are stored
   as a vector, in which the first element will be the first
   operation applied to an image passed to :func:`transform`.
   The outcome of the first operation will then be fed as input to
   the second one, and so on, until all operations were applied. The
   outcome of the last operation will then be returned as the result.

   .. attribute:: operations

      Vector of :class:`ImageOperation`. The order of the operations
      within the vector denote the order of execution, meaning the
      first element will be applied to a given image first, then the
      second, and so on.

.. function:: LinearPipeline(operations)

   :param Vector operations: Vector of :class:`ImageOperation`.
          This variable can be used to initialize the pipeline
          with a specified sequence of image operations.

.. function:: LinearPipeline(operations...)

   :param Tuple operations: Tuple of :class:`ImageOperation`.
          This way the image operations can be specified using
          different distinct positional paramater. Its sole purpose
          is syntax convenience.


.. function:: transform(pipeline, image) -> Image

   Applies each :class:`ImageOperation` of the pipeline one after
   another to the given image and returns the transformed image(s).

   :param LinearPipeline pipeline: The concrete linear pipeline
   :param Image image: The image that should be transformed by the
          pipeline
   :return: A new :class:`Image`. The transformed version of the
            given parameter ``image``.

.. function:: transform(pipeline, images) -> Vector

   Applies each :class:`ImageOperation` of the pipeline one after
   another to the given set of images and returns the transformed
   image(s).

   :param LinearPipeline pipeline: The concrete linear pipeline
   :param Vector images: The images that should be transformed by the
          pipeline
   :return: A new vector of eltype :class:`Image`. The transformed
            versions of the corresponding element in the given
            parameter ``images``.


.. function:: Base.endof(pipeline) -> Int

   :param LinearPipeline pipeline: The concrete linear pipeline
   :return: The index of the last image operation in the pipeline.

.. function:: Base.getindex(pipeline, indicies) -> Vector

   :param LinearPipeline pipeline: The concrete linear pipeline
   :param Vector indicies: Vector of integers. Each element should
          be within ``1`` and ``endof(pipeline)``, and thus denote a
          concrete image operation in the pipeline.
   :return: A vector containing those :class:`ImageOperation` that
            are denoted by the parameter ``indicies``.

.. function:: Base.getindex(pipeline, index) -> ImageOperation

   :param LinearPipeline pipeline: The concrete linear pipeline
   :param Int index: Number denoting the single operation that should
          be returned. Must be within ``1`` and ``endof(pipeline)``
   :return: The :class:`ImageOperation` denoted by the given index

.. function:: Base.length(pipeline) -> Int

   :param LinearPipeline pipeline: The concrete linear pipeline
   :return: The total number of image operations in the pipelione.

.. function:: Base.start(pipeline) -> Int

   :param LinearPipeline pipeline: The concrete linear pipeline
   :return: ``1``, index of the first image operation

.. function:: Base.done(pipeline, state) -> Bool

   :param LinearPipeline pipeline: The concrete linear pipeline
   :param Int state: the state returned by either
          :function:`Base.start`, or :function:`Base.next`.
   :return: true, if all image operations have been iterated over

.. function:: Base.next(pipeline) -> (ImageOperation, Int)

   :param LinearPipeline pipeline: The concrete linear pipeline
   :return: A ``Tuple`` containing both, the operation of the current
            state (i.e. index), and the state for the next iteration.


.. function:: Base.append!(pipeline1, pipeline2) -> LinearPipeline

   :param LinearPipeline pipeline1: The concrete linear pipeline that
          is to be edited.
   :param LinearPipeline pipeline2: The concrete linear pipeline whose
          operation should be appended to the end of ``pipeline1``
   :return: ``pipeline1``

.. function:: Base.push!(pipeline, operation) -> LinearPipeline

   :param LinearPipeline pipeline: The concrete linear pipeline that
          is to be edited.
   :param ImageOperation operation: The new operation that should be
          added to the end of the pipeline.
   :return: Itself (``pipeline``)

.. function:: Base.insert!(pipeline, index, operation) -> LinearPipeline

   :param LinearPipeline pipeline: The concrete linear pipeline that
          is to be edited.
   :param Int index: The position at which the new operation should be
          inserted to.
   :param ImageOperation operation: The new operation that should be
          inserted into the pipeline at the given position.
   :return: Itself (``pipeline``)

.. function:: Base.deleteat!(pipeline, index) -> LinearPipeline

   :param LinearPipeline pipeline: The concrete linear pipeline that
          is to be edited.
   :param Int index: The position of the operation that should be
          removed from the pipeline.
   :return: Itself (``pipeline``)

Examples
---------

.. code-block:: julia

    # load an example image
    using TestImages
    img = testimage("lena")

    # create empty pipeline
    pl = LinearPipeline()

    # add operations to pipeline
    push!(pl, FlipX(0.5)) # lifted to ProbableOperation{FlipX}. 50% chance of occuring
    push!(pl, FlipY())    # not lifted. will always occur
    push!(pl, Resize(64,64))

    # transform example image
    img_new = transform(pl, img)

.. code-block:: julia

   # create complete pipeline in one line
   pl = LinearPipeline(FlipX(.5), FlipY(.5), Resize(32,32))

.. code-block:: none

   LinearPipeline
   - 3 operation(s):
       - 50% chance to: Flip x-axis. (factor: 2x)
       - 50% chance to: Flip y-axis. (factor: 2x)
       - Resize to 32x32. (factor: 1x)
   - total factor: 4x

