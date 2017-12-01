#!python
# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: nil -*-
# vi: set ft=python sts=4 ts=4 sw=4 et:

from mvpa2.suite import *
from numpy import log
import sys
import numpy as N

sys.path.append('./lib')
#import searchlight_norm
from mvpa2.measures.searchlight import sphere_searchlight

#subjID=sys.argv[1]
#conName='ptval'
conName=sys.argv[1]
roi=sys.argv[2]

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
                mask=os.path.join(datapath, roi + '.nii.gz'))

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

all_acc=[]
ii=range(1,1001)
for i in ii:
    # shuffle within chunk to make sure all chunks are matched;
    seed=N.random.randint(10000);
    N.random.seed(seed)
    N.random.shuffle(dataset.sa.targets)
    N.random.seed(seed)
    N.random.shuffle(dataset.sa.chunks)

    err=cv(dataset)
    all_acc.append(1-cv.ca.stats.error)
    with open(conName + '_' + roi + '.txt','a') as f:
       f.write(str(1-N.mean(err.samples)) + '\n')
       f.close()

# print "Finished: %s %s %s %s." %(subjID,conName,slRad,tubeEps)
