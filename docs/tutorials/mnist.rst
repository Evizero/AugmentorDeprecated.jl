.. _mnist_tut:

MNIST: Emulating Elastic Distortions
=====================================

In this example we are going to use ``Augmentor.jl`` on the famous
**MNIST database of handwritten digits** [MNIST1998]_ to reproduce
the elastic distortions discussed in [SIMARD2003]_.

.. note::

   The way Augmentor implements deformations is a little different
   than how it is described by the authors in the paper.
   This is for a couple of reasons, most notably that we want the
   parameters for our deformations to be intepended of the size of
   image it is applied on. As a consequence the parameter numbers
   specified in the paper are not 1-to-1 transferable to Augmentor

To start off with the first line of code, we import ``Augmentor.jl``

.. code-block:: julia

    using Augmentor

Loading the Trainingset
------------------------

To this end we employ the help of two additional Julia packages,
``Images.jl``, and ``MNIST.jl``.

.. code-block:: julia

    # We bring Images.jl into scope to visualize the data
    # see: https://github.com/timholy/Images.jl
    using Images

    # MNIST.jl will provide tools to access the dataset
    # see: https://github.com/johnmyleswhite/MNIST.jl
    using MNIST

Smoothed Displacement Fields
-----------------------------

.. image:: https://cloud.githubusercontent.com/assets/10854026/17645973/3894d2b0-61b6-11e6-8b10-1cb5139bfb6d.gif

Visualizing Displacement Parameters
---------------------------------

Before we apply a smoothed displacement field to our dataset and
train a network (see next tutorial), we should invest some time to
come up with a decent set of hyper parameters for the displacement.

.. code-block:: julia

    # These two package will provide us with the capabilities
    # to perform interactive visualisations in a jupyter notebook
    using Interact, Reactive

    # The manipulate macro will turn the parameters of the
    # loop into interactive widgets.
    @manipulate for
            unpaused = true,
            ticks = fpswhen(signal(unpaused), 5.),
            index = 1:50000,
            gridsize = 2:20,
            scale = .1:.1:.5,
            sigma = 1:5,
            iterations = 1:6
        op = SmoothedDisplacement(gridsize, gridsize, # equal width & height
                                  sigma = sigma,
                                  scale = scale,
                                  iterations = iterations)
        transform(op, grayim(train_images[:, :, index]))
    end

Executing the code above in a Juypter notebook will result in the
following interactive visualisation. You can now use the sliders
to investigate the effects that different parameters have on the
MNIST training set.

.. Tip::

   You should always use your **training** set to do this kind of
   visualisation (not the test test!). Otherwise you are likely to
   achieve overly optimistic (i.e. biased) results during training.


.. image:: https://cloud.githubusercontent.com/assets/10854026/17641720/5de6cd8c-612c-11e6-933f-b91d58cf2fde.gif

Congratulations! With just a few simple lines of code, you created a
simple interactive tool to visualize your image augmentation pipeline.
Once you found a set of parameters that you think are appropriate
for your dataset you can go ahead and train your model.

If you are interested on how we could use these parameters to
train a convolutional neural network in ``MXNet.jl``, you should
check out the tutorial for :ref:`mxnet_tut`


References
-----------

.. [MNIST1998] LeCun, Yan, Corinna Cortes, Christopher J.C. Burges. `"The MNIST database of handwritten digits" <http://yann.lecun.com/exdb/mnist/>`_ Website. 1998.

.. [SIMARD2003] Simard, Patrice Y., David Steinkraus, and John C. Platt. `"Best practices for convolutional neural networks applied to visual document analysis." <https://www.microsoft.com/en-us/research/publication/best-practices-for-convolutional-neural-networks-applied-to-visual-document-analysis/>`_ ICDAR. Vol. 3. 2003.


