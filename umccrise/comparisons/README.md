umccrise run comparisons
========================

- [umccrise run comparisons](#umccrise-run-comparisons)
  - [2022-Feb](#2022-feb)
    - [`2016.249.17.MH.P033`](#201624917mhp033)
    - [`2016.249.18.WH.P025`](#201624918whp025)
    - [`B_ALL_Case_10`](#b_all_case_10)
    - [`CUP-Pairs8`](#cup-pairs8)
    - [`DiploidNeverResponder`](#diploidneverresponder)
    - [`SBJ00303`](#sbj00303)
    - [`SEQC50`](#seqc50)
    - [`SFRC01073`](#sfrc01073)

## 2022-Feb

__DRAGEN 3.9.3 vs. bcbio 1.1.6__

### `2016.249.17.MH.P033`

- [Trello](https://trello.com/c/oUN2eWAL/1181-dragen-ica-validation-201624917mhp033)
- cancer report
  - HRD: increase in HRDetect/CHORD score in Dragen
  - SV: missing 2 Tier2 translocations in Dragen
  - CNVs: ~28 genes min CN diff > 1, max 3
- pcgr
  - 3 Tier4 diff between bcbio/Dragen
- cpsr
  - extra MSH2 VUS Indel in Dragen (Non-ClinVar)
- multiqc
  - same-ish
- cacao
  - (tumor) HLA-A/HLA-B a lot better in Dragen
  - (normal) a couple genes with higher coverage in bcbio

### `2016.249.18.WH.P025`

- [Trello](https://trello.com/c/QFNeOvqh/1182-dragen-ica-validation-201624918whp025)

- cancer report
  - TMB: increase (1.34 -> 2.24)
  - SVs: decrease (81 -> 24)
  - BNDs have.. completely vanished
  - CNVs: decrease (168 -> 88)
  - Kataegis detected in Dragen
- pcgr
  - TMB 9 -> 31
  - VUS 10 -> 20
  - big diffs in somatic calls as discussed, but no diffs in Tiers 1/2
  - funny that both bcbio and dragen PCGR results show kataegis
- cpsr
  - VUS goes from 114 to 110 in Dragen, but don't think this is reflected in woof report (cc. Stephen)
- multiqc
  - This one actually has ~1% Contamination from Conpair in both bcbio and dragen (other validation samples are around 0.05%).
  - Something is.. a bit wrong with bcftools stats Variant Quality in general.

### `B_ALL_Case_10`

- [Trello](https://trello.com/c/CSgQITzw/1180-dragen-ica-validation-ballcase10)

- cancer report
  - Signatures: same-ish
  - SNVs: few extra Tier4 indels detected in Dragen
  - CNVs: HEATR4/chr16/chr17 min CN diff is 2
  - SVs: Tier3 chr6 DEL detected in Dragen (chr6:162,198,360)
- pcgr
  - TMB higher in Dragen (0.85 -> 0.97)
  - 6 Tier4 extra indels in Dragen
- cpsr
  - 2 extra VUS in Dragen
- multiqc
  - General stats same-ish
  - BCFtools Variant Quality is.. empty for Dragen?
  - FastQC: need some kind of summary for Dragen (from BBowman branch maybe?)
- cacao
  - (tumor) HLA-A a bit better in Dragen
  - (normal) CDKN1C a bit better in Dragen



### `CUP-Pairs8`

- [Trello](https://trello.com/c/GTnAHUJ5/1173-dragen-ica-validation-cup-pairs8)

- QC: Identical
- Coverage Identical
- CPSR Identical
- PCGR Mostly identical. Difference in SNVs, expected (FFPE), nothing on the higher tiers.
- Reporter Pretty much identical. More confident CHORD score (likely driven by additinal SNVs), sig 3 still there; there is no way I am going to compare SV/CNVs for an FFPE sample.

### `DiploidNeverResponder`

- [Trello](https://trello.com/c/E6DvxrPs/1166-dragen-ica-validation-diploidneverresponder)

- QC: New report has the viral insertion (phew). Otherwise all identical except for the already noted MultiQC differences
- Coverage: Identical
- CPSR: Identical
- PCGR: Identical
- Reporter: Lost 3 inter-chromosomal SVs, going from 18 BND events to 2. I'd check the PUM2, CASC8 fusion event (2:20,251,798 to 8:127,306,881) as it has >80 reads in support in the old version to see why those have gotten filtered. Some CN shifts (lower CN difference only, can be ignored). HLA differences (!). Nice - going to trust DRAGEN on those.

### `SBJ00303`

- [Trello](https://trello.com/c/PTHuS2es/1164-dragen-ica-validation-sbj00303)

- QC: Lower filtering rate again (despite identical filtered variants); looks like DRAGEN is generating less noise for some of these samples. WGD event recognized by Purple.
- Coverage: Identical
- CPSR: Identical
- PCGR: Few extra tier 4 calls; nothing notable
- Reporter: Slight shift in lower tier signatures (2020); extra PTPRD BND call; Del/Dup/Ins identical for key genes with >10 reads support; sizeable # of genes with large CN differences (check LCE1D, MTX1, GBAP1, NTAN1)

### `SEQC50`

- [Trello](https://trello.com/c/KQ91VGX4/1168-dragen-ica-validation-seqc50)

- QC: Identical
- Coverage: Identical
- CPSR: Identical (3 more VUS, expected)
- PCGR: MSI status flipped (from high to stable); likely due to the shift in InDel to SNV calls. There's an MSH6 mutation to support it, could be worth running past the curation team to see if they would be okay with that change; Tier 3 TTN lost which is a good thing; otherwise identical
- Reporter: Contamination detected in both reports (!); unlike PCGR the reporter has both as MSS (Stable). Another likely point in favor of the Dragen data. Very similar high HRDetect/CHORD scores, reduced number of SV calls - some with high levels of support in old data included (e.g., RNGTT deletion); CN changes again in HLA (expected), general shift of 2 CN for large chunk of chr1 (from 2 to 4). I can see some of that in the Circos plot but given the CN Noise warning I'm happy to ignore

### `SFRC01073`

- [Trello](https://trello.com/c/Ed8aos1f/1163-dragen-ica-validation-sfrc01073)

- QC:
  - Lower SNP filtering rate? Hard to tell - the old report was % filtered, this is %SNP and %InDel.
  - Interesting to see that DRAGEN filters more in some of the reference samples (Bob, Chen) and less in others.
  - Higher MapQ0 rate which is expected since we align to the whole genome
  - bcbio blocked out ALTs, repeats
  - bcftools somatic is showing zero hom changes - likely a parsing error? They are present in bcftool stats germline
- Coverage Looks identical
- CPSR: Identical
- PCGR: Lost NDRG1 (Tier 3, 10% AF)
- Reporter: Looks good to me; biggest change in the SV/CNV space, everything else looks stable. Slight decrease in the number of CN segments (somatic), increase in germline; SV seems to be missing some relevant events (e.g., CREB1 BidFusG with >25 SR/PR support, NTRK1 deletions) - we need to check those. NTRK1 deletion is present in Del/Dup/Ins but not in BND - change of representation in Manta?
