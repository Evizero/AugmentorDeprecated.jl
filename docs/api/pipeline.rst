Pipelines
==========

Classes
--------

.. class:: LinearPipeline

    Subtype of :class:`Pipeline` for linear chains of operations,
    which may or may not be probabilistic (i.e. have a random chance
    for occuring).  The contained :class:`ImageOperation` s are stored
    as a vector, in which the first element will be the first
    operation applied to an image passed to :func:`transform`.
    The outcome of the first operation will then be fed as input to
    the second one, and so on, until all operations were applied. The
    outcome of the last operation will then be returned as the result.


Examples
---------

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

