MNIST: Using MXNet with Augmentor
=================================

In this example we are going to use ``Augmentor.jl`` on the famous
**MNIST database of handwritten digits** [MNIST1998]_ to reproduce
the elastic distortions discussed in [SIMARD2003]_.
We choose to follow this particular paper in this tutorial, because
the approach discussed in Simard et al. is both simple and effective.

If you haven't already check out the first tutorial in which
we explore appropriate displacement parameters for the data set

To start off with the first line of code, we import ``Augmentor.jl``

.. code-block:: julia

    using Augmentor

Creating the Pipeline
----------------------

Defining the Network
---------------------

References
-----------

.. [MNIST1998] LeCun, Yan, Corinna Cortes, Christopher J.C. Burges. `"The MNIST database of handwritten digits" <http://yann.lecun.com/exdb/mnist/>`_ Website. 1998.

.. [SIMARD2003] Simard, Patrice Y., David Steinkraus, and John C. Platt. `"Best practices for convolutional neural networks applied to visual document analysis." <https://www.microsoft.com/en-us/research/publication/best-practices-for-convolutional-neural-networks-applied-to-visual-document-analysis/>`_ ICDAR. Vol. 3. 2003.

