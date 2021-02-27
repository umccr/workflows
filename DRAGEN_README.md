# DRAGEN Workflows

- [DRAGEN Workflows](#dragen-workflows)
  - [Reference Hash Tables](#reference-hash-tables)
    - [hg38](#hg38)
    - [GRCh37](#grch37)
  - [Alignment and FASTQ Input](#alignment-and-fastq-input)

## Reference Hash Tables

### hg38

- hg38 FASTA downloaded from [1000 Genomes][1000Genomes].  
  * One can also download the reference from [this s3 bucket][public_dragen_bucket]
  (see [this DRAGEN issue][genome_match_confirmation_issue].
- Parameters derived from [recommendations for mammalian genomes][dragen_tutorial].
- Built using command below in the "development" workgroup
  * wfl id: `wfl.704f1efddc864f88befdb1c9a6e42cf7`
  * wfl version: `3.7.5`
  * wfl run id: `wfr.348f44b92c834e51908c5c0e0e3274b2`  
  * Input body:
    
    <details>
    
    <summary>Click to expand!</summary>    

    ```json
    {
        "name": "build-reference-tarball-3.7.5",
        "input": {
            "ht_reference": {
                "class": "File",
                "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/hg38.fa"
            },
            "output_directory": "hg38_alt_ht_3_7_5",
            "ht_alt_liftover": "bwa-kit_hs38DH_liftover.sam",
            "ht_max_seed_freq": 16,
            "ht_seed_len": 27,
            "ht_num_threads": 40,
            "ht_methylated": true,
            "enable_cnv": true,
            "ht_build_rna_hashtable": true
        },
        "engineParameters": {
            "outputDirectory": "gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/"
        }
    }
    ```
    
    </details>
  
  * Outputs body:
    <details>
    
    <summary>Click to expand!</summary>
    
    ```json
    { 
        "dragen_reference_tar": {
            "basename": "hg38_alt_ht_3_7_5.tar.gz",
            "class": "File",
            "http://commonwl.org/cwltool#generation": 0,
            "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/hg38_alt_ht_3_7_5.tar.gz",
            "nameext": ".gz",
            "nameroot": "hg38_alt_ht_3_7_5.tar",
            "size": 15070552340
        }
    }
    ```
  
    </details>

  * Tarball entries: `gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/hg38_alt_ht_3_7_5.tar.gz`
    <details>
    <summary>Click to expand!</summary>
    
    ```text
    hg38_alt_ht_3_7_5
    ├── CT_converted
    │   ├── hash_table.cfg
    │   ├── hash_table.cfg.bin
    │   ├── hash_table.cmp
    │   ├── hash_table_stats.txt
    │   ├── reference.bin
    │   ├── ref_index.bin
    │   ├── repeat_mask.bin
    │   └── str_table.bin
    ├── dragen-replay.json
    ├── dragen.time_metrics.csv
    ├── GA_converted
    │   ├── hash_table.cfg
    │   ├── hash_table.cfg.bin
    │   ├── hash_table.cmp
    │   ├── hash_table_stats.txt
    │   ├── reference.bin
    │   ├── ref_index.bin
    │   ├── repeat_mask.bin
    │   └── str_table.bin
    ├── hash_table.cfg
    ├── hash_table.cfg.bin
    ├── hash_table.cmp
    ├── hash_table_stats.txt
    ├── kmer_cnv.bin
    ├── reference.bin
    ├── ref_index.bin
    ├── repeat_mask.bin
    ├── streaming_log_none(29178).csv
    └── str_table.bin
    ```
    </details>

    

### GRCh37

- Built using command below in the "development" workgroup
  * wfl id: `wfl.704f1efddc864f88befdb1c9a6e42cf7`
  * wfl version: `3.7.5`
  * wfl run id: `wfr.cb954ef8b3784d2f93a5878b9b697010`  
  * Input body:
    
    <details>
    
    <summary>Click to expand!</summary>    
    
    ```json
    {
        "name": "build-reference-tarball-3.7.5",
        "input": {
            "ht_reference": {
                "class": "File",
                "location": "gds://umccr-refdata-dev/dragen/hsapiens/GRCh37/GRCh37.fa"
            },
            "output_directory": "GRCh37_ht_3_7_5",
            "ht_max_seed_freq": 16,
            "ht_seed_len": 27,
            "ht_num_threads": 40,
            "ht_methylated": true,
            "enable_cnv": true,
            "ht_build_rna_hashtable": true
        },
        "engineParameters": {
            "outputDirectory": "gds://umccr-refdata-dev/dragen/genomes/GRCh37/3.7.5/"
        }
    }
    ```
    
    </details>    

  * Outputs body:
    
    <details>
    
    <summary>Click to expand!</summary>    

    ```json
    {
        "dragen_reference_tar": {
            "basename": "GRCh37_ht_3_7_5.tar.gz",
            "class": "File",
            "http://commonwl.org/cwltool#generation": 0,
            "location": "gds://umccr-refdata-dev/dragen/genomes/GRCh37/3.7.5/GRCh37_ht_3_7_5.tar.gz",
            "nameext": ".gz",
            "nameroot": "GRCh37_ht_3_7_5.tar",
            "size": 13378092328
        }
    }
    ```

    </details>    

  * Tarball entries:
    
    <details>
  
    <summary>Click to expand!</summary>
  
    ```text
    GRCh37_ht_3_7_5/
    ├── CT_converted
    │   ├── hash_table.cfg
    │   ├── hash_table.cfg.bin
    │   ├── hash_table.cmp
    │   ├── hash_table_stats.txt
    │   ├── reference.bin
    │   ├── ref_index.bin
    │   ├── repeat_mask.bin
    │   └── str_table.bin
    ├── dragen-replay.json
    ├── dragen.time_metrics.csv
    ├── GA_converted
    │   ├── hash_table.cfg
    │   ├── hash_table.cfg.bin
    │   ├── hash_table.cmp
    │   ├── hash_table_stats.txt
    │   ├── reference.bin
    │   ├── ref_index.bin
    │   ├── repeat_mask.bin
    │   └── str_table.bin
    ├── hash_table.cfg
    ├── hash_table.cfg.bin
    ├── hash_table.cmp
    ├── hash_table_stats.txt
    ├── kmer_cnv.bin
    ├── reference.bin
    ├── ref_index.bin
    ├── repeat_mask.bin
    ├── streaming_log_none(31111).csv
    └── str_table.bin
    ```
  
    </details>    


- GRCh37 FASTA downloaded from link in Hartwig [GRIDSS-PURPLE-LINX](https://github.com/hartwigmedical/gridss-purple-linx/blob/47e274459ee8ac760196f6c2ed753c2a83d230fb/README.md) repo.
  - md5sum: `be672f01428605881b2ec450d8089a62  Homo_sapiens.GRCh37.GATK.illumina.fasta`
  - Contains chromosomes 1-22, X, Y, MT. Their md5sums are identical to the
    main chromosomes in the `human_g1k_v37.fasta.gz`
    [reference](ftp://gsapubftp-anonymous:none@ftp.broadinstitute.org/bundle/b37/) used in bcbio (except chr3 for some reason). The GL contigs are also
    discarded.
  

## Alignment and FASTQ Input

The alignment and germline calling must be done 'per-sample'.  
This means that the output folder includes a single bam and germline vcf call. 

Here is an example run input / output of a germline workflow:  

### Input json

<details>

<summary>Click to expand!</summary>

```json
{
    "name": "dragen-germline-test-run",
    "input": {
        "fastq_list_rows": [
            {
                "rgid": "GTGTCGGA.GCTTGCGC.1",
                "rglb": "MDX200237_L2100008",
                "rgsm": "UnknownLibrary",
                "lane": 1,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L001_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L001_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.2",
                "rglb": "MDX200237_L2100008",
                "rgsm": "UnknownLibrary",
                "lane": 2,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L002_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L002_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.3",
                "rglb": "MDX200237_L2100008",
                "rgsm": "UnknownLibrary",
                "lane": 3,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L003_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L003_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.4",
                "rglb": "MDX200237_L2100008",
                "rgsm": "UnknownLibrary",
                "lane": 4,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L004_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L004_R2_001.fastq.gz"
                }
            }
        ],
        "output_file_prefix": "MDX200237_L2100008",
        "output_directory": "MDX200237_L2100008",
        "enable_map_align_output": true,
        "enable_duplicate_marking": true,
        "reference_tar": {
            "class": "File",
            "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/hg38_alt_ht_3_7_5.tar.gz"
        }
    },
    "engineParameters": {
        "outputSetting": "leave"
    }
}
```

</details>

### Output json \# TODO

<details>

<summary>Click to expand! </summary>

\# TODO
```json

```

</details>

## Somatic Calling

Uses similar schema to the germline caller with the additional parameter `tumor_fastq_list_rows`,  
while `fastq_list_rows` represents the 'normal' sample.  

Here's an example input json:

### Input json

<details>

<summary>Click to expand!</summary>

```json
{
    "name": "dragen-somatic-test-run",
    "input": {
        "fastq_list_rows": [
            {
                "rgid": "ACACTAAG.ATCCATAT.1",
                "rgsm": "MDX200236_L2100007",
                "rglb": "UnknownLibrary",
                "lane": 1,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L001_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L001_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "ACACTAAG.ATCCATAT.2",
                "rgsm": "MDX200236_L2100007",
                "rglb": "UnknownLibrary",
                "lane": 2,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L002_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L002_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "ACACTAAG.ATCCATAT.3",
                "rgsm": "MDX200236_L2100007",
                "rglb": "UnknownLibrary",
                "lane": 3,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L003_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L003_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "ACACTAAG.ATCCATAT.4",
                "rgsm": "MDX200236_L2100007",
                "rglb": "UnknownLibrary",
                "lane": 4,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L004_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200236_L2100007_S1_L004_R2_001.fastq.gz"
                }
            }
        ],
        "tumor_fastq_list_rows": [
            {
                "rgid": "GTGTCGGA.GCTTGCGC.1",
                "rgsm": "MDX200237_L2100008",
                "rglb": "UnknownLibrary",
                "lane": 1,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L001_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L001_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.2",
                "rgsm": "MDX200237_L2100008",
                "rglb": "UnknownLibrary",
                "lane": 2,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L002_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L002_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.3",
                "rgsm": "MDX200237_L2100008",
                "rglb": "UnknownLibrary",
                "lane": 3,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L003_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L003_R2_001.fastq.gz"
                }
            },
            {
                "rgid": "GTGTCGGA.GCTTGCGC.4",
                "rgsm": "MDX200237_L2100008",
                "rglb": "UnknownLibrary",
                "lane": 4,
                "read_1": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L004_R1_001.fastq.gz"
                },
                "read_2": {
                    "class": "File",
                    "location": "gds://umccr-fastq-data-prod/210108_A01052_0030_AHMKMCDSXY/Y151_I8_I8_Y151/PO/MDX200237_L2100008_S2_L004_R2_001.fastq.gz"
                }
            }
        ],
        "output_file_prefix": "MDX200237_L2100008",
        "output_directory": "MDX200237_L2100008",
        "enable_map_align_output": true,
        "enable_duplicate_marking": true,
        "enable_sv": true,
        "reference_tar": {
            "class": "File",
            "location": "gds://umccr-refdata-dev/dragen/genomes/hg38/3.7.5/hg38_alt_ht_3_7_5.tar.gz"
        }
    },
    "engineParameters": {
        "outputSetting": "leave"
    }
}
```

</details>

### Output json \# TODO

<details>

<summary>Click to expand!</summary>

```json
```

</details>

## Other useful links

### Hash table builder (v3.7.5) \# TODO

* CWL tool definition
* CWL tool documentation

### Germline workflow (v3.7.5) \# TODO

* CWL tool definition
* CWL tool documentation

* CWL workflow definition
* CWL workflow documentation

### Somatic workflow (v3.7.5) \# TODO

* CWL tool definition
* CWL tool documentation

* CWL workflow definition
* CWL workflow documentation


[1000Genomes]: http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/
[dragen_tutorial]: https://sapac.support.illumina.com/content/dam/illumina-support/help/Illumina_DRAGEN_Bio_IT_Platform_v3_7_1000000141465/Content/SW/FrontPages/DRAGENBioITPlatform.htm
[public_dragen_bucket]: https://s3.amazonaws.com/stratus-documentation-us-east-1-public/dragen/reference/Homo_sapiens/hg38.fa
[genome_match_confirmation_issue]: https://github.com/umccr-illumina/dragen/issues/8