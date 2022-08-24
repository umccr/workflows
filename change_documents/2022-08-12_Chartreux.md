## Background

The [Chartreux portal release](https://github.com/umccr/infrastructure/milestone/6?closed=1) updates our WTS workflow and the WGS post-processing workflow, umccrise, to address issues we have identified after our migration from [bcbio to DRAGEN](https://github.com/umccr/workflows/blob/master/change_documents/2022-06-08_bcbio-to-DRAGEN.md).

Workflows affected:

```
Can we have a list of workflow IDs/commits from https://github.com/umccr/cwl-ica/commit/e4195a6d7a51a965949717bc22540674cc8989fb?diff=unified here? 

I.e., with Chartreux what are the running? Is
    
   - name: 2.1.1--0
     path: 2.1.1--0/umccrise__2.1.1--0.cwl
     ica_workflow_version_name: 2.1.1--0
  
sufficient to identify a given workflow? For the ctTSO500 documentation we also list the ICA workflow ID, name and version.
```

### WTS



### umccrise

This release addesses the following issue:


**Hypermutated samples fail to postprocess in umccrise**: Samples with more than 500,000 variants are meant to be downsampled during the post-processing phase. The umccrise step relies on SnpEff-annotated VCF files; the new DRAGEN workflow does not utilize SnpEff

The fix changes the filtering approach by instructing PCGR to ignore intergenic regions (as defined by VEP) for hypermutated samples.

Issue: https://github.com/umccr/umccrise/issues/89, https://github.com/umccr/umccrise/issues/91
Fix: https://github.com/umccr/umccrise/pull/110
Deployed in: https://github.com/umccr/infrastructure/pull/245




### Other changes

* GPL
* Somalier



