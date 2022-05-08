#! /bin/bash

set -e

echo ""
echo "Setting environment variables"
export SYNTH_HOME=$PWD
source $SYNTH_HOME/jetpack-envars.sh

echo ""
echo "Creating virtual desktop"
mkdir --parents \
  $SYNTH_LOGS \
  $SYNTH_PROJECTS \
  $SYNTH_NOTEBOOKS \
  $SYNTH_WHEELS

echo "Installing Mambaforge if necessary"
if [ ! -d $HOME/mambaforge ]
then
  echo "..Installing Mambaforge"
  /usr/bin/time $SYNTH_SCRIPTS/mambaforge.sh > $SYNTH_LOGS/mambaforge.log 2>&1
fi

echo "Enabling conda and mamba commands"
source $HOME/mambaforge/etc/profile.d/conda.sh
source $HOME/mambaforge/etc/profile.d/mamba.sh

echo "Creating pytorch-builder mamba environment if necessary"
if [ `mamba env list | grep "pytorch-builder" | wc -l` -le "0" ]
then
  echo "..Creating pytorch-builder"
  /usr/bin/time $SYNTH_SCRIPTS/pytorch-builder.sh > $SYNTH_LOGS/pytorch-builder.log 2>&1
fi

echo "Activating pytorch-builder"
mamba activate pytorch-builder

echo "Cloning PyTorch source"
/usr/bin/time $SYNTH_SCRIPTS/clone-pytorch.sh

echo "Building PyTorch wheel"
/usr/bin/time nice $SYNTH_SCRIPTS/build-pytorch.sh

echo "Testing PyTorch wheel"
$SYNTH_SCRIPTS/test-pytorch-wheel.sh
