#!python
# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: nil -*-
# vi: set ft=python sts=4 ts=4 sw=4 et:

from mvpa2.suite import *
from numpy import log
import sys

sys.path.append('./lib')
#import searchlight_norm
from mvpa2.measures.searchlight import sphere_searchlight

#subjID=sys.argv[1]
#conName='ptval'
conName=sys.argv[1]
cost=0.001
slRad=3
tubeEps=0.01

# enable debug output for searchlight call
if __debug__:
    debug.active += ["SLC"]

# attribute files 
attribfile=conName+'.txt'

datapath = os.path.join('.')

# source of class targets and chunks definitions
attr = SampleAttributes(os.path.join(datapath,attribfile))

dataset = fmri_dataset(
                samples=os.path.join(datapath, 'GM_mod_merg_s3.nii.gz'),
                targets=np.array(attr.targets,dtype='float32'),
                chunks=attr.chunks,
                mask=os.path.join(datapath, 'GM_mask.nii.gz'))

# normalize across condision within each run
#zscore(dataset,chunks_attr='chunks',dtype='float32')

# choose regression method
svmReg=SVM(svm_impl='EPSILON_SVR',C=cost,tube_epsilon=float(tubeEps))

# get ids of features that have a nonzero value
#center_ids = dataset.fa.wholeBrain.nonzero()[0]
center_ids=dataset.fa.voxel_indices.nonzero()[0]

#cv = CrossValidatedTransferError(TransferError(svmReg, CorrErrorFx()), NFoldSplitter())
cv = CrossValidation(svmReg, NFoldPartitioner(),errorfx=corr_error, enable_ca=['training_stats','stats'])

# cross-validated mean transfer using an N-fold dataset splitter

for radius in [int(slRad)]:
    # tell which one we are doing
    print "Running searchlight with radius: %i ..." % (radius)

    sl = sphere_searchlight(cv, radius=radius, space='voxel_indices',
    #                        center_ids=center_ids,
                            postproc=mean_sample())

    ds = dataset.copy(deep=False,
                      sa=['targets', 'chunks'],
                      fa=['voxel_indices'],
                      a=['mapper'])

    sl_map = sl(ds)
    sl_acc=sl_map.copy(deep=True)
    sl_acc.samples=1.0 - sl_acc.samples

    # save results
    niftiresults = map2nifti(sl_acc, imghdr=dataset.a.imghdr)
    resultspath = os.path.join('.')
    niftiresults.to_filename('accuracy_' + conName + '.nii.gz')

# print "Finished: %s %s %s %s." %(subjID,conName,slRad,tubeEps)
